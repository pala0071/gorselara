import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();
  bool ready = false;
  Future<void> init() async {
    try {
      await plugin.initialize(const InitializationSettings(android: AndroidInitializationSettings('ic_notification')));
      ready = true;
    } catch (_) { ready = false; }
  }
  Future<void> request() async {
    try { await Permission.notification.request(); } catch (_) { /* Downloads do not depend on notifications. */ }
  }
  Future<void> show(int id, String title, String body, {int? percent, bool ongoing = false}) async {
    if (!ready) return;
    try {
      await plugin.show(id, title, body, NotificationDetails(android: AndroidNotificationDetails(
        'gorselara_downloads', 'GörselAra downloads', channelDescription: 'Download progress and results',
        importance: Importance.low, priority: Priority.low, onlyAlertOnce: true,
        showProgress: ongoing, maxProgress: 100, progress: percent ?? 0,
        indeterminate: ongoing && percent == null, ongoing: ongoing, autoCancel: !ongoing,
      )));
    } catch (_) { /* A denied notification permission must not abort a download. */ }
  }
}
