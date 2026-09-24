// 帧编解码: 与 internal/comet/protocol.go 完全对齐的线格式。
//   | body_len: 4B BE | version: 1B (=1) | flag: 1B (=0) | cmd: 2B BE | body: protobuf Frame |
import 'dart:typed_data';

import '../../gen/protocol.pb.dart' as pb;

const int frameHeaderSize = 8;
const int maxBodySize = 64 << 10;

Uint8List encodeFrame(pb.Frame f) {
  final body = f.writeToBuffer();
  if (body.length > maxBodySize) {
    throw StateError('frame body too large: ${body.length}');
  }
  final b = ByteData(frameHeaderSize);
  b.setUint32(0, body.length, Endian.big);
  b.setUint8(4, 1); // version
  b.setUint8(5, 0); // flag
  b.setUint16(6, f.cmd.value, Endian.big);
  final out = Uint8List(frameHeaderSize + body.length)
    ..setAll(0, b.buffer.asUint8List())
    ..setAll(frameHeaderSize, body);
  return out;
}

/// 流式解码器: 处理粘包/半包 (feed 任意长度字节块, 吐出完整帧)。
class FrameDecoder {
  Uint8List _pending = Uint8List(0);
  int _off = 0;

  /// 喂一段字节, 返回能解出的全部完整帧。
  List<pb.Frame> feed(List<int> data) {
    final merged = Uint8List(_pending.length - _off + data.length);
    merged.setRange(0, _pending.length - _off,
        Uint8List.sublistView(_pending, _off));
    merged.setRange(_pending.length - _off, merged.length, data);
    _pending = merged;
    _off = 0;

    final frames = <pb.Frame>[];
    while (true) {
      final avail = _pending.length - _off;
      if (avail < frameHeaderSize) break;
      final hdr = ByteData.sublistView(_pending, _off, _off + frameHeaderSize);
      final bodyLen = hdr.getUint32(0, Endian.big);
      final version = hdr.getUint8(4);
      final flag = hdr.getUint8(5);
      if (version != 1) throw StateError('bad frame version $version');
      if (flag != 0) throw StateError('bad frame flag $flag');
      if (bodyLen > maxBodySize) throw StateError('frame body too large');
      if (avail < frameHeaderSize + bodyLen) break; // 半包, 等更多
      final body = Uint8List.sublistView(
          _pending, _off + frameHeaderSize, _off + frameHeaderSize + bodyLen);
      frames.add(pb.Frame.fromBuffer(body));
      _off += frameHeaderSize + bodyLen;
    }
    return frames;
  }
}
