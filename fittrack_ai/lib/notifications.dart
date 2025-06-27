import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _fln =
      FlutterLocalNotificationsPlugin();

  /* ─────────────  INITIALISATION  ───────────── */
  Future<void> init() async {
    tz.initializeTimeZones();
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _fln.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse r) {
        // TODO: handle notification tap if needed
      },
    );

    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (!Platform.isAndroid) return;
    final android = _fln
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    try {
      await android?.requestNotificationsPermission(); // Android 13+
    } catch (e) {
      debugPrint('requestNotificationsPermission not available: $e');
    }
  }

  /* ─────────────  INTERNAL ANDROID DETAILS  ───────────── */
  AndroidNotificationDetails _androidDetails({
    required String channelId,
    required String channelName,
    String? sound,
    String? groupKey,
    String? smallIcon,
  }) {
    return AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'Custom reminder channel',
      importance: Importance.max,
      priority: Priority.high,
      sound: sound == null ? null : RawResourceAndroidNotificationSound(sound),
      groupKey: groupKey,
      icon: smallIcon,
      setAsGroupSummary: false,
    );
  }

  /* ─────────────  PUBLIC HELPERS  ───────────── */

  /// Instant preview / test notification
  Future<void> showInstantNotification({
    required String title,
    required String body,
    required String channelId,
    required String channelName,
    String? sound,
    String? groupKey,
    String? smallIcon,
  }) async {
    await _fln.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // unique ID
      title,
      body,
      NotificationDetails(
        android: _androidDetails(
          channelId: channelId,
          channelName: channelName,
          sound: sound,
          groupKey: groupKey,
          smallIcon: smallIcon,
        ),
      ),
    );
  }

  /// General daily scheduler (supports custom sound / icon / group key)
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    required String channelId,
    required String channelName,
    String? sound,
    String? groupKey,
    String? smallIcon,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var sched = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (sched.isBefore(now)) sched = sched.add(const Duration(days: 1));

    await _fln.zonedSchedule(
      id,
      title,
      body,
      sched,
      NotificationDetails(
        android: _androidDetails(
          channelId: channelId,
          channelName: channelName,
          sound: sound,
          groupKey: groupKey,
          smallIcon: smallIcon,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Convenience wrapper for the default workout reminder at 8 PM
  Future<void> scheduleDailyWorkoutReminder({
    TimeOfDay? time,
    String sound = 'workout_chime', // file workout_chime.mp3 in res/raw
  }) async {
    final t = time ?? const TimeOfDay(hour: 20, minute: 0);
    await scheduleDailyNotification(
      id: 0,
      title: '🏋️ Time to Move!',
      body: 'Log your workout or take a walk 💪',
      time: t,
      channelId: 'workout_channel_id',
      channelName: 'Workout Reminders',
      sound: sound,
      groupKey: 'group_workout',
      smallIcon: 'ic_workout',
    );
  }

  /* ─────────────  QUERY / CANCEL / UPDATE  ───────────── */

  /// List all pending scheduled notifications
  Future<List<PendingNotificationRequest>> pending() =>
      _fln.pendingNotificationRequests();

  Future<void> cancelNotification(int id) => _fln.cancel(id);
  Future<void> cancelAllNotifications() => _fln.cancelAll();
  Future<void> cancelWorkoutReminder() => cancelNotification(0);

  Future<void> updateNotification({
    required int id,
    required String newTitle,
    required String newBody,
    required TimeOfDay newTime,
    String? newSound,
    String? newGroupKey,
    String? newSmallIcon,
  }) async {
    await cancelNotification(id);
    await scheduleDailyNotification(
      id: id,
      title: newTitle,
      body: newBody,
      time: newTime,
      channelId: 'daily_reminder_channel',
      channelName: 'Daily Reminders',
      sound: newSound,
      groupKey: newGroupKey,
      smallIcon: newSmallIcon,
    );
  }
}
