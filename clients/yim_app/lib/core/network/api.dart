// HTTP 网关客户端: Dio + Bearer 注入 + 401 统一处理。
// 响应走网关 protojson (UseProtoNames): snake_case + int64 是 JSON 字符串,
// 统一用 Map<String,dynamic> + G.i() 归一化, 不引入 pb 反序列化。

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import '../config/app_config.dart';
import '../storage/session_store.dart';

/// 401 → 跳登录 (router 监听)
class UnauthorizedError implements Exception {
  const UnauthorizedError();
}

/// 业务错误: 网关 4xx 带 {"error": "..."} 或 pb Error.msg
class ApiError implements Exception {
  final int code; // 网关业务码 (20 已是好友 / 22 非好友 / 23 非群主 ...)
  final String msg;
  ApiError(this.msg, [this.code = 0]);
  @override
  String toString() => msg;
}

/// int64 兼容取值: protojson 输出 "123", 手写 JSON 是 123
class G {
  static int i(dynamic v, [int def = 0]) {
    if (v == null) return def;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? def;
  }

  static String s(dynamic v, [String def = '']) => v?.toString() ?? def;
  static bool b(dynamic v) => v == true || v == 'true' || v == '1';
  static List<dynamic> l(dynamic v) => v is List ? v : const [];
  static Map<String, dynamic> m(dynamic v) =>
      v is Map<String, dynamic> ? v : const {};
}

class Api {
  Api._() {
    _dio.options
      ..baseUrl = AppConfig.apiBase
      ..connectTimeout = const Duration(seconds: 5)
      ..receiveTimeout = const Duration(seconds: 10);
    // 自签证书 (YIM_TLS): 默认链校验必挂, 这里按 pin 语义放行 (见 AppConfig)
    if (AppConfig.useTls) {
      _dio.httpClientAdapter = IOHttpClientAdapter(createHttpClient: () {
        final c = HttpClient();
        c.badCertificateCallback =
            (cert, host, port) => AppConfig.acceptServerCert(cert);
        return c;
      });
    }
    _dio.interceptors.add(InterceptorsWrapper(onRequest: (o, h) async {
      final t = await sessionStore.token();
      if (t != null && t.isNotEmpty) o.headers['Authorization'] = 'Bearer $t';
      h.next(o);
    }, onError: (e, h) async {
      final code = e.response?.statusCode;
      if (code == 401) {
        await sessionStore.setToken(null);
        throw const UnauthorizedError();
      }
      // 统一收敛: 任何 DioException 都不外漏, 调用方只会看到短句 ApiError
      if (e.response == null) {
        throw ApiError(_netMsg(e));
      }
      final data = e.response?.data;
      if (data is Map && data['error'] is Map) {
        final err = data['error'] as Map;
        throw ApiError(G.s(err['msg']), G.i(err['code']));
      }
      throw ApiError(code != null ? '服务器错误 ($code)' : '网络错误');
    }));
  }

  /// 网络层失败 → 用户可读的一句话
  String _netMsg(DioException e) => switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout =>
          '连接服务器超时, 请检查网络',
        DioExceptionType.connectionError => '无法连接服务器 (${AppConfig.apiBase})',
        DioExceptionType.badCertificate => '证书校验失败',
        DioExceptionType.cancel => '请求已取消',
        _ => '网络错误',
      };
  static final Api I = Api._();
  final _dio = Dio();

  dynamic _unwrap(Response r) {
    final data = r.data;
    if (data is Map) {
      final err = data['error'];
      if (err is Map) throw ApiError(G.s(err['msg']), G.i(err['code']));
      if (err is String && data.keys.length == 1) throw ApiError(err);
    }
    return data;
  }

  Future<Map<String, dynamic>> _get(String path,
      [Map<String, dynamic>? q]) async {
    final r = await _dio.get(path, queryParameters: q);
    return G.m(_unwrap(r));
  }

  Future<Map<String, dynamic>> _post(String path, [Object? body]) async {
    final r = await _dio.post(path, data: body);
    return G.m(_unwrap(r));
  }

  Future<Map<String, dynamic>> _delete(String path) async {
    final r = await _dio.delete(path);
    return G.m(_unwrap(r));
  }

  // ---------- 认证 ----------
  Future<Map<String, dynamic>> register(String nick, String pwd) =>
      _post('/api/v1/register', {'nickname': nick, 'password': pwd});
  Future<Map<String, dynamic>> login(String nick, String pwd) =>
      _post('/api/v1/login', {'nickname': nick, 'password': pwd});

  // ---------- 消息/会话 ----------
  Future<Map<String, dynamic>> sendText(
          int clientMsgId, int convId, String text) =>
      sendMessage(clientMsgId, convId, {'type': 'MSG_TEXT', 'text': text});

  /// 通用发消息: content 即 protojson 的 ConvMsgContent (文本/图片共用)
  Future<Map<String, dynamic>> sendMessage(
          int clientMsgId, int convId, Map<String, dynamic> content) =>
      _post('/api/v1/messages', {
        'client_msg_id': clientMsgId.toString(),
        'conv_id': convId.toString(),
        'content': content,
      });

  /// 聊天图片上传 → {url, size} (url 为相对路径, 展示时经 fileUrl 补全)
  Future<Map<String, dynamic>> uploadImage(String filePath) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final r = await _dio.post('/api/v1/files/image', data: form);
    return G.m(r.data);
  }
  Future<Map<String, dynamic>> revokeMessage(int convId, int msgId) =>
      _post('/api/v1/messages/revoke',
          {'conv_id': convId.toString(), 'msg_id': msgId.toString()});
  Future<Map<String, dynamic>> createConv(String type, List<int> uids,
          {String name = ''}) =>
      _post('/api/v1/conversations', {
        'type': type,
        'member_uids': uids.map((e) => e.toString()).toList(),
        if (name.isNotEmpty) 'name': name,
      });
  Future<Map<String, dynamic>> listConversations(
          [int page = 1, int pageSize = 50]) =>
      _get('/api/v1/conversations', {'page': page, 'page_size': pageSize});
  Future<Map<String, dynamic>> pullHistory(int convId, int beforeSeq,
          [int limit = 50]) =>
      _get('/api/v1/conversations/$convId/messages',
          {'before_seq': beforeSeq, 'limit': limit});
  Future<Map<String, dynamic>> searchMessages(String keyword) =>
      _get('/api/v1/messages/search', {'keyword': keyword});
  Future<Map<String, dynamic>> markRead(int convId, int readSeq) =>
      _post('/api/v1/conversations/$convId/read',
          {'read_seq': readSeq.toString()});
  Future<Map<String, dynamic>> getReadStates(int convId) =>
      _get('/api/v1/conversations/$convId/read-states');

  // ---------- 好友 ----------
  Future<void> sendFriendRequest(int toUid, [String msg = '']) =>
      _post('/api/v1/friend/requests',
          {'to_uid': toUid.toString(), 'message': msg});
  Future<void> handleFriendRequest(int fromUid, bool accept) =>
      _post('/api/v1/friend/requests/$fromUid',
          {'action': accept ? 'accept' : 'reject'});
  Future<Map<String, dynamic>> listFriendRequests({bool incoming = true}) =>
      _get('/api/v1/friend/requests',
          {'direction': incoming ? 'in' : 'out'});
  Future<Map<String, dynamic>> listFriends() => _get('/api/v1/friends');
  Future<void> deleteFriend(int uid) => _delete('/api/v1/friends/$uid');

  // ---------- 群 ----------
  Future<void> addGroupMembers(int convId, List<int> uids) => _post(
      '/api/v1/groups/$convId/members',
      {'member_uids': uids.map((e) => e.toString()).toList()});
  Future<void> removeGroupMember(int convId, int uid) =>
      _delete('/api/v1/groups/$convId/members/$uid');
  Future<void> quitGroup(int convId) => _post('/api/v1/groups/$convId/quit');
  Future<Map<String, dynamic>> listGroupMembers(int convId) =>
      _get('/api/v1/groups/$convId/members');
  Future<void> updateGroupInfo(int convId, {String name = '', String avatar = ''}) =>
      _patch('/api/v1/groups/$convId/info', {
        if (name.isNotEmpty) 'name': name,
        if (avatar.isNotEmpty) 'avatar': avatar,
      });

  // ---------- 资料/在线 ----------
  Future<Map<String, dynamic>> getProfiles(List<int> uids) => _get(
      '/api/v1/users/profiles', {'uids': uids.join(',')});
  Future<Map<String, dynamic>> searchUsers(String keyword) =>
      _get('/api/v1/users/search', {'keyword': keyword});
  Future<Map<String, dynamic>> updateMe(String nickname) =>
      _patch('/api/v1/users/me', {'nickname': nickname});
  Future<Map<String, dynamic>> getPresence(List<int> uids) =>
      _get('/api/v1/presence', {'uids': uids.join(',')});

  Future<Map<String, dynamic>> _patch(String path, Object body) async {
    final r = await _dio.patch(path, data: body);
    return G.m(_unwrap(r));
  }

  // ---------- 头像上传 (multipart, 魔数白名单由服务端校验) ----------
  Future<Map<String, dynamic>> uploadAvatar(String filePath) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final r = await _dio.post('/api/v1/files/avatar', data: form);
    return G.m(_unwrap(r));
  }

  /// 文件 (头像/聊天图片) 完整 URL, DB 存相对路径 /files/...
  static String fileUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return AppConfig.filesBase + path;
  }

  static String avatarUrl(String avatar) => fileUrl(avatar);
}
