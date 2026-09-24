// 系统通知: 非当前会话来消息时弹系统级 toast (Android/Windows 单包双端)。
// 触发点在 ConvListNotifier.onPush 的未读 bump —— 正在看的会话不弹。
// 手机后台进程被系统冻结时收不到通知属平台限制 (无 FCM 通道): 回前台由
// lifecycle 恢复连接 + SYNC 补齐, 消息不丢, 只是通知晚到。
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService I = NotificationService._();
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    try {
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // AUMI/GUID 标识通知来源: 首次运行会在开始菜单建同名快捷方式,
        // Windows toast 依赖它归组 (guid 任意但需终生不变)
        windows: WindowsInitializationSettings(
          appName: 'YIM',
          appUserModelId: 'com.yim.desktop.YIM',
          guid: '8f3a1c6e-4b7d-49a2-b5f0-2d81c9e07a34',
        ),
      );
      await _plugin.initialize(settings: settings);
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      // Android 13+: 通知运行时权限 (manifest 已声明 POST_NOTIFICATIONS)
      await android?.requestNotificationsPermission();
      // 渠道 (Android 8+): 消息通知, 高优先级出横幅
      await android?.createNotificationChannel(const AndroidNotificationChannel(
          'messages', '消息通知', importance: Importance.high));
      _ready = true;
    } catch (e) {
      debugPrint('notification init: $e');
    }
  }

  /// 按会话弹通知: id = convId, 同会话新消息覆盖旧 toast 不堆积
  Future<void> showMessage(int convId, String title, String body) async {
    if (!_ready) return;
    try {
      await _plugin.show(
        id: convId,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails('messages', '消息通知',
              importance: Importance.high, priority: Priority.high),
          windows: WindowsNotificationDetails(),
        ),
      );
    } catch (e) {
      debugPrint('notification show: $e');
    }
  }
}
