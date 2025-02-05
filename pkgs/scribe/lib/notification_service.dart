import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void onDidReceiveNotificationResponse(
  NotificationResponse notificationResponse,
) async {
  final String? payload = notificationResponse.payload;
  if (notificationResponse.payload != null) {
    // debugPrint("notification payload: $payload");
  }
  // await Navigator.push(
  //   context,
  //   MaterialPageRoute<void>(builder: (context) => SecondScreen(payload)),
  // );
}

class Notifications {
  static late Notifications _instance;
  factory Notifications() => _instance;

  static Future<void> ensureInitialized() async {
    final plugin = FlutterLocalNotificationsPlugin();
    const initializationSettingsAndroid = AndroidInitializationSettings(
      "ic_launcher_monochrome",
    );
    const initializationSettingsDarwin = DarwinInitializationSettings();
    const initializationSettingsLinux = LinuxInitializationSettings(
      defaultActionName: "Open notification",
    );
    const initializationSettingsWindows = WindowsInitializationSettings(
      appName: "Scribe",
      appUserModelId: "dev.deminearchiver.scribe",
      guid: "712a2821-516a-43b5-bfa0-767cf30bcdb0",
    );
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
      windows: initializationSettingsWindows,
    );
    await plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );

    _instance = Notifications._(plugin: plugin);
  }

  const Notifications._({required FlutterLocalNotificationsPlugin plugin})
    : _plugin = plugin;

  final FlutterLocalNotificationsPlugin _plugin;
  FlutterLocalNotificationsPlugin get plugin => _plugin;

  T? platform<T extends FlutterLocalNotificationsPlatform>() {
    return plugin.resolvePlatformSpecificImplementation<T>();
  }

  Future<void> showNotification({
    required int id,
    String? title,
    String? body,
    NotificationDetails? details,
    String? payload,
  }) async {
    await plugin.show(id, title, body, details, payload: payload);
  }

  Future<void> scheduleNotification({
    required int id,
    String? title,
    String? body,
  }) async {
    // plugin.zonedSchedule(id, title, body, scheduledDate, notificationDetails, androidScheduleMode: androidScheduleMode)
  }
}
