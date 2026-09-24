// 会话持久化: token 进 secure storage (Windows DPAPI / iOS Keychain),
// device_id / uid / nickname 进 SharedPreferences (非敏感)。
import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionStore {
  static const _tokenKey = 'yim.token';
  static const _pwdKey = 'yim.saved_password';
  final _secure = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true));
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<String?> token() => _secure.read(key: _tokenKey);
  Future<void> setToken(String? v) => (v == null
      ? _secure.delete(key: _tokenKey)
      : _secure.write(key: _tokenKey, value: v));

  // 记住的密码 (secure storage): 免登已关闭, 打开 App 停在登录页预填,
  // 用户点一下"登录"才进入 —— 静默恢复会话会让换号/失效难以察觉
  Future<String?> savedPassword() => _secure.read(key: _pwdKey);
  Future<void> setSavedPassword(String? v) => (v == null
      ? _secure.delete(key: _pwdKey)
      : _secure.write(key: _pwdKey, value: v));

  int? get uid => _prefs?.getInt('yim.uid');
  String? get nickname => _prefs?.getString('yim.nickname');

  // 主题模式: system/light/dark (跟随系统默认)
  String? get themeMode => _prefs?.getString('yim.theme_mode');
  Future<void> setThemeMode(String v) async {
    await _prefs?.setString('yim.theme_mode', v);
  }

  Future<void> setIdentity(int uid, String nickname) async {
    await _prefs?.setInt('yim.uid', uid);
    await _prefs?.setString('yim.nickname', nickname);
  }

  Future<void> clearIdentity() async {
    await _prefs?.remove('yim.uid');
    await _prefs?.remove('yim.nickname');
  }

  // 设备唯一标识: 首次生成持久化, 重装前的安装周期内不变
  String deviceId() {
    var id = _prefs?.getString('yim.device_id');
    if (id == null || id.isEmpty) {
      final rnd = Random.secure();
      id = base64UrlEncode(List.generate(12, (_) => rnd.nextInt(256)));
      _prefs?.setString('yim.device_id', id);
    }
    return id;
  }
}

final sessionStore = SessionStore();
