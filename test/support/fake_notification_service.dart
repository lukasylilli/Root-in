import 'dart:ui' show Locale;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:root_in/core/services/notification_service.dart';

/// Test-Ersatz für [NotificationService]: berührt nie den echten
/// Plattform-Kanal (in Widget-Tests nicht verfügbar) und protokolliert die
/// geplanten/abgebrochenen Erinnerungen, damit Tests sie prüfen können.
/// Jeder Test, der über das Repository Gewohnheiten anlegt/löscht oder eine
/// Erinnerung setzt, überschreibt `notificationServiceProvider` hiermit.
class FakeNotificationService extends NotificationService {
  FakeNotificationService() : super(FlutterLocalNotificationsPlugin());

  final Map<int, int> scheduled = {};
  final List<int> cancelled = [];
  bool permissionGranted = true;

  /// Sprache, mit der zuletzt eine Erinnerung geplant wurde — so lässt sich
  /// prüfen, dass die Notification-Texte der App-Sprache folgen (Phase 11).
  Locale? lastLocale;

  /// Serie, die zuletzt in eine Erinnerung geschrieben wurde (Phase 23).
  final Map<int, int> lastStreak = {};

  /// Zuletzt gesetzter Tagesstand — `null`, wenn die Meldung abgeräumt wurde.
  ({int done, int total})? dailyStatus;

  /// Wie oft [cancelDailyStatus] gerufen wurde. Getrennt von [dailyStatus],
  /// weil „nie gesetzt" und „bewusst abgeräumt" zwei verschiedene Dinge sind.
  int dailyStatusCancelled = 0;

  @override
  Future<void> initialize(Locale locale) async {}

  @override
  Future<bool> requestPermission() async => permissionGranted;

  @override
  Future<void> scheduleForHabit({
    required int habitId,
    required String habitName,
    required int minuteOfDay,
    required Locale locale,
    int streak = 0,
  }) async {
    scheduled[habitId] = minuteOfDay;
    lastStreak[habitId] = streak;
    lastLocale = locale;
  }

  @override
  Future<void> cancelForHabit(int habitId) async {
    scheduled.remove(habitId);
    cancelled.add(habitId);
  }

  @override
  Future<void> showDailyStatus({
    required int done,
    required int total,
    required Locale locale,
  }) async {
    // Dieselbe Regel wie im echten Dienst — sonst prüften die Tests eine
    // Abkürzung statt des Verhaltens.
    if (total == 0 || done >= total) return cancelDailyStatus();
    dailyStatus = (done: done, total: total);
    lastLocale = locale;
  }

  @override
  Future<void> cancelDailyStatus() async {
    dailyStatus = null;
    dailyStatusCancelled++;
  }
}
