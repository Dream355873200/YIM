// 长连接: 状态机 disconnected→connecting→syncing→ready / suspended(退避)。
// CONNECT(token+device) → CONNECT_RSP(user_sync_seq) → SYNC(各会话水位) →
// SYNC_RSP 增量; PUSH(max_seq>本地水位) 单会话拉取; 心跳 30s×3 判死重连;
// 指数退避 1s→30s+jitter, 断网恢复立即重试。
//
// 服务端零改动约束 (与 comet 协议契约一致): PUSH 只带轻通知, 消息体一律
// HTTP PullHistory 补 —— 推保证实时, 拉保证可靠。
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fixnum/fixnum.dart';

import '../../gen/common.pb.dart' as pb;
import '../../gen/message.pb.dart' as pb;
import '../../gen/protocol.pb.dart' as pb;
import '../config/app_config.dart';
import 'frame_codec.dart';

// int64 字段 (fixnum Int64) ↔ Dart int 转换快捷
Int64 i64(int v) => Int64(v);

enum SocketState { disconnected, connecting, syncing, ready, suspended }

/// 上层消费的事件
sealed class SocketEvent {
  SocketEvent();
}

class PushEvent extends SocketEvent {
  final int convId;
  final int maxSeq;
  final int fromUid;
  PushEvent(this.convId, this.maxSeq, this.fromUid);
}

class UpAckEvent extends SocketEvent {
  final int clientMsgId;
  final int msgId;
  final int seq;
  UpAckEvent(this.clientMsgId, this.msgId, this.seq);
}

class SyncDoneEvent extends SocketEvent {
  SyncDoneEvent();
}

class StateEvent extends SocketEvent {
  final SocketState state;
  StateEvent(this.state);
}

class KickedEvent extends SocketEvent {
  final String reason;
  KickedEvent(this.reason);
}

/// 业务事件通知 (好友/群/在线), 事件只带"发生了什么", 客户端按需局部重拉
class RelationEventNotice extends SocketEvent {
  final String type; // FRIEND_REQUEST / FRIEND_HANDLED / FRIEND_DELETED / GROUP_CHANGED / PRESENCE / TYPING / READ
  final int uid;
  final int convId;
  final bool online;
  final int seq; // READ: 对方已读到的水位
  RelationEventNotice(this.type, this.uid, this.convId, this.online,
      {this.seq = 0});
}

class YimSocket {
  YimSocket({String? token}) : _token = token;

  String? _token;
  SocketState state = SocketState.disconnected;
  final _events = StreamController<SocketEvent>.broadcast();
  Stream<SocketEvent> get events => _events.stream;
  SocketEvent? _lastEvent;
  SocketEvent? get lastEvent => _lastEvent;

  Socket? _sock;
  final _dec = FrameDecoder();
  StreamSubscription? _sub;
  Timer? _hbTimer;
  Timer? _backoff;
  int _hbMissed = 0;
  int _frameId = 0;
  int _backoffSec = 1;

  // 各会话本地推送水位 (用于 PUSH 去重 + ACK 累积语义)
  final _wm = <int, int>{};
  // 重连后需要恢复的水位快照 (SYNC 用)
  Map<int, int> watermarks = {};
  // SYNC 前向宿主取最新水位的回调 (会话列表 lastSeq 即服务端 last_seq)。
  // 不注入则退回 watermarks 快照 —— 空水位会让服务端重放近期消息。
  Map<int, int> Function()? watermarkSource;

  Future<void> connect(String token, int uid) async {
    _token = token;
    await _dial();
    _watchNetwork();
  }

  void setWatermarks(Map<int, int> w) => watermarks = Map.of(w);

  void _setState(SocketState s) {
    state = s;
    _emit(StateEvent(s));
  }

  void _emit(SocketEvent e) {
    _lastEvent = e;
    _events.add(e);
  }

  Future<void> _dial() async {
    if (_token == null) return;
    _teardown();
    _setState(SocketState.connecting);
    try {
      final sock = AppConfig.useTls
          ? await SecureSocket.connect(AppConfig.tcpHost, AppConfig.tcpPort,
              timeout: const Duration(seconds: 3),
              onBadCertificate: AppConfig.acceptServerCert)
          : await Socket.connect(AppConfig.tcpHost, AppConfig.tcpPort,
              timeout: const Duration(seconds: 3));
      sock.setOption(SocketOption.tcpNoDelay, true);
      _sock = sock;
      _sub = sock.listen(_handleData, onError: (_) => _onDead(),
          onDone: _onDead, cancelOnError: true);

      // CONNECT
      final dev = pb.DeviceInfo()
        ..type = pb.DeviceType.DEVICE_DESKTOP
        ..deviceId = 'flutter-${Platform.operatingSystem}';
      _send(pb.Frame()
        ..frameId = ++_frameId
        ..cmd = pb.Command.CMD_CONNECT
        ..connect = (pb.ConnectReq()
          ..token = _token!
          ..device = dev));
    } catch (e) {
      debugPrint('yim socket dial: $e');
      _scheduleReconnect();
    }
  }

  void _handleData(List<int> data) {
    try {
      for (final f in _dec.feed(data)) {
        _handleFrame(f);
      }
    } catch (e) {
      debugPrint('yim socket decode: $e');
      _onDead();
    }
  }

  void _handleFrame(pb.Frame f) {
    switch (f.cmd) {
      case pb.Command.CMD_CONNECT_RSP:
        if (f.hasError() && f.error.code != 0) {
          // token 无效等: 不重连, 置 disconnected
          _teardown();
          _setState(SocketState.disconnected);
          return;
        }
        _hbMissed = 0;
        _backoffSec = 1;
        _setState(SocketState.syncing);
        // SYNC: 带本地水位; 新设备/无水位 = 全量
        final req = pb.SyncReq()..userSyncSeq = i64(0);
        final wm = watermarkSource?.call() ?? watermarks;
        watermarks = Map.of(wm); // 存回快照, 供回调缺席的下一次重连使用
        wm.forEach((conv, seq) {
          req.watermarks.add(pb.ConvWatermark()
            ..convId = i64(conv)
            ..lastSeq = i64(seq));
        });
        _send(pb.Frame()
          ..frameId = ++_frameId
          ..cmd = pb.Command.CMD_SYNC
          ..sync = req);
        _startHeartbeat();
      case pb.Command.CMD_SYNC_RSP:
        _setState(SocketState.ready);
        _emit(SyncDoneEvent());
        // 增量消息: 直接以 PUSH 语义上抛 (conv 缺口由 PullHistory 补);
        // 顺带灌 _wm, 防止紧随其后的 PUSH 对已同步消息重复上抛
        for (final m in f.syncRsp.messages) {
          final conv = m.convId.toInt(), seq = m.seq.toInt();
          if (seq > (_wm[conv] ?? 0)) _wm[conv] = seq;
          _emit(PushEvent(conv, seq, m.fromUid.toInt()));
        }
      case pb.Command.CMD_MESSAGE_PUSH:
        final p = f.messagePush;
        final conv = p.convId.toInt(), maxSeq = p.maxSeq.toInt();
        final known = _wm[conv] ?? 0;
        if (maxSeq > known) {
          _wm[conv] = maxSeq;
          _emit(PushEvent(conv, maxSeq, p.fromUid.toInt()));
          // 累积 ACK (服务端 <=ack_seq 全删): 每推即报当前水位
          _send(pb.Frame()
            ..frameId = ++_frameId
            ..cmd = pb.Command.CMD_ACK
            ..ack = (pb.Ack()
              ..convId = i64(conv)
              ..ackSeq = i64(maxSeq)
              ..target = pb.AckTarget.ACK_FOR_PUSH));
        }
      case pb.Command.CMD_MESSAGE_UP_RSP:
        final r = f.messageUpRsp;
        _emit(UpAckEvent(
            r.clientMsgId.toInt(), r.msgId.toInt(), r.seq.toInt()));
      case pb.Command.CMD_HEARTBEAT:
        // 服务端心跳应答 → 复位超时
        _hbMissed = 0;
      case pb.Command.CMD_KICK:
        _teardown();
        _setState(SocketState.disconnected);
        _emit(KickedEvent(f.kick.reason));
      case pb.Command.CMD_EVENT:
        final e = f.event;
        _emit(RelationEventNotice(
            e.type, e.uid.toInt(), e.convId.toInt(), e.online,
            seq: e.seq.toInt()));
      case pb.Command.CMD_DISCONNECT:
        _scheduleReconnect(); // 排水: 立即重连其他实例
      default:
        break;
    }
  }

  void _startHeartbeat() {
    _hbTimer?.cancel();
    _hbTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _hbMissed++;
      if (_hbMissed >= 3) {
        _onDead();
        return;
      }
      _send(pb.Frame()
        ..frameId = ++_frameId
        ..cmd = pb.Command.CMD_HEARTBEAT
        ..heartbeat = (pb.Heartbeat()..lastFrameId = Int64(_frameId)));
    });
  }

  Future<void> sendTextUp(int clientMsgId, int convId, String text) async {
    final content = pb.ConvMsgContent()
      ..type = pb.MsgType.MSG_TEXT
      ..text = text;
    _send(pb.Frame()
      ..frameId = ++_frameId
      ..cmd = pb.Command.CMD_MESSAGE_UP
      ..messageUp = (pb.MessageUpReq()
        ..clientMsgId = i64(clientMsgId)
        ..convId = i64(convId)
        ..content = content));
  }

  /// 输入中提示 (即发即弃, 服务端不回帧不落库): 文本变化时节流调用
  void sendTyping(int convId) {
    _send(pb.Frame()
      ..frameId = ++_frameId
      ..cmd = pb.Command.CMD_TYPING
      ..typing = (pb.Typing()..convId = i64(convId)));
  }

  void _send(pb.Frame f) {
    final sock = _sock;
    if (sock == null) return;
    try {
      sock.add(encodeFrame(f));
    } catch (_) {
      _onDead();
    }
  }

  void _onDead() {
    if (state == SocketState.disconnected) return;
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _teardown();
    _setState(SocketState.suspended);
    final jitter = Random().nextInt(500);
    final delay = min(_backoffSec * 1000 + jitter, 30000);
    _backoffSec = min(_backoffSec * 2, 30);
    _backoff?.cancel();
    _backoff = Timer(Duration(milliseconds: delay), _dial);
  }

  void _watchNetwork() {
    Connectivity().onConnectivityChanged.listen((_) {
      if (state == SocketState.suspended && _token != null) {
        _backoff?.cancel();
        _dial(); // 断网恢复立即重试
      }
    });
  }

  /// App 回前台 (lifecycle resumed): 退避等待/断连状态下立即拨号,
  /// 不用等剩余退避秒数; 连接健康则不动 (15s 轮询兜底增量)。
  void resume() {
    if (_token == null) return;
    if (state == SocketState.suspended || state == SocketState.disconnected) {
      _backoff?.cancel();
      _dial();
    }
  }

  void _teardown() {
    _hbTimer?.cancel();
    _sub?.cancel();
    _sub = null;
    try {
      _sock?.destroy();
    } catch (_) {}
    _sock = null;
  }

  Future<void> logout() async {
    _token = null;
    _backoff?.cancel();
    _teardown();
    _setState(SocketState.disconnected);
    _wm.clear();
    watermarks.clear();
  }
}
