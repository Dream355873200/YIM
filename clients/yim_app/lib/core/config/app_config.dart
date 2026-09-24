// 运行时配置: 网关 HTTP 与 comet TCP 地址。
// 默认本机开发拓扑; 打包时用 --dart-define 覆盖。
import 'dart:io';

import 'package:crypto/crypto.dart';

//
// TLS 全开形态 (--dart-define):
//   YIM_API=https://127.0.0.1:8080   (服务端 YIM_TLS_CERT/KEY 已配)
//   YIM_TLS=1                        (长连接走 SecureSocket)
//   YIM_TLS_PIN=<证书 sha256 hex>    (自签证书 pin; 留空 = 放行任意证书, 仅限内网)
class AppConfig {
  static const apiBase = String.fromEnvironment(
    'YIM_API',
    defaultValue: 'http://127.0.0.1:8080',
  );
  static const tcpHost = String.fromEnvironment('YIM_TCP_HOST',
      defaultValue: '127.0.0.1');
  static const tcpPort = int.fromEnvironment('YIM_TCP_PORT', defaultValue: 8900);

  static const useTls = bool.fromEnvironment('YIM_TLS');
  static const tlsPin = String.fromEnvironment('YIM_TLS_PIN');

  static const filesBase = apiBase; // 头像等静态文件同源

  /// 自签证书校验: pin 已配则比对证书 sha256 (hex, 不分大小写);
  /// pin 空 = 开发态放行任意证书 (生产必须配 pin, 否则 TLS 只防被动窃听)。
  static bool acceptServerCert(X509Certificate cert) {
    final pin = tlsPin;
    if (pin.isEmpty) return true;
    final hex = sha256.convert(cert.der).toString();
    return hex == pin.toLowerCase();
  }
}
