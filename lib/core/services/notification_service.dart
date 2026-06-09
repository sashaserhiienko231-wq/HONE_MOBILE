import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Initialize timezone
    tz.initializeTimeZones();

    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combined initialization settings
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels for Android
    await _createNotificationChannels();
  }

  static Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel optimizationChannel =
        AndroidNotificationChannel(
      'optimization_channel',
      'Optimization Notifications',
      description: 'Notifications for system optimizations and boosts',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    const AndroidNotificationChannel performanceChannel =
        AndroidNotificationChannel(
      'performance_channel',
      'Performance Monitoring',
      description: 'Real-time performance alerts and warnings',
      importance: Importance.defaultImportance,
      enableVibration: false,
      playSound: true,
    );

    const AndroidNotificationChannel gameChannel =
        AndroidNotificationChannel(
      'game_channel',
      'Game Optimizations',
      description: 'Game-specific optimization notifications',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    const AndroidNotificationChannel systemChannel =
        AndroidNotificationChannel(
      'system_channel',
      'System Alerts',
      description: 'Important system alerts and warnings',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(optimizationChannel);

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(performanceChannel);

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(gameChannel);

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(systemChannel);
  }

  static Future<void> _onNotificationTapped(
      NotificationResponse notificationResponse) async {
    // Handle notification tap
    debugPrint('Notification tapped: ${notificationResponse.payload}');
  }

  static Future<void> showOptimizationNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'optimization_channel',
        'Optimization Notifications',
        channelDescription: 'Notifications for system optimizations and boosts',
        importance: Importance.high,
        priority: Priority.high,
        color: Color(0xFF00FF88),
        ledColor: Color(0xFF00FF88),
        enableLights: true,
        enableVibration: true,
        playSound: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  static Future<void> showPerformanceAlert({
    required String title,
    required String body,
    String? payload,
  }) async {
    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'performance_channel',
        'Performance Monitoring',
        channelDescription: 'Real-time performance alerts and warnings',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        color: Color(0xFFFF6B35),
        ledColor: Color(0xFFFF6B35),
        enableLights: true,
        enableVibration: false,
        playSound: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: true,
      ),
    );

    await _notificationsPlugin.show(
      1,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  static Future<void> showGameOptimizationNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'game_channel',
        'Game Optimizations',
        channelDescription: 'Game-specific optimization notifications',
        importance: Importance.high,
        priority: Priority.high,
        color: Color(0xFF00D4FF),
        ledColor: Color(0xFF00D4FF),
        enableLights: true,
        enableVibration: true,
        playSound: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notificationsPlugin.show(
      2,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  static Future<void> showSystemAlert({
    required String title,
    required String body,
    String? payload,
  }) async {
    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'system_channel',
        'System Alerts',
        channelDescription: 'Important system alerts and warnings',
        importance: Importance.high,
        priority: Priority.high,
        color: Color(0xFFE74C3C),
        ledColor: Color(0xFFE74C3C),
        enableLights: true,
        enableVibration: true,
        playSound: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notificationsPlugin.show(
      3,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'optimization_channel',
          'Optimization Notifications',
          channelDescription: 'Notifications for system optimizations and boosts',
          importance: Importance.high,
          priority: Priority.high,
          color: Color(0xFF00FF88),
          ledColor: Color(0xFF00FF88),
          enableLights: true,
          enableVibration: true,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }

  static Future<void> requestPermissions() async {
    // Android permissions are handled in AndroidManifest.xml
    // iOS permissions can be requested here if needed
    if (Platform.isIOS) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }
}
