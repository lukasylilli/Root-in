import 'dart:convert';
import 'dart:ui' show Locale;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../l10n/gen/app_localizations.dart';
import '../utils/platform_support.dart';
import '../l10n/app_language.dart' show fallbackLocale;

const String _channelId = 'habit_reminders';
const String _snoozeActionId = 'snooze';
const String _snoozeCategoryId = 'habit_reminder_category';
const Duration _snoozeDuration = Duration(minutes: 10);

/// Eigener Kanal für den Tagesstand (siehe PLAN.md Phase 23). Bewusst
/// **getrennt** von den Erinnerungen: Android lässt den Nutzer Kanäle einzeln
/// abschalten, und wer den dauerhaften Hinweis nicht will, soll deshalb nicht
/// zugleich die Erinnerungen verlieren.
const String _statusChannelId = 'habit_daily_status';

/// Feste ID der Tagesstand-Meldung. Weit weg von den Habit-IDs, die als
/// Notification-ID der Erinnerungen dienen.
const int _statusNotificationId = 2000000;

/// Was in der Tagesstand-Meldung steht — **und ob überhaupt eine erscheint**
/// (siehe PLAN.md Phase 23).
///
/// Bewusst als eigenes, reines Wertobjekt herausgezogen (dieselbe Bauart wie
/// `StreakCalculator` und `AchievementEvaluator`): Die Entscheidung „mahnen
/// oder abräumen" ist die eigentliche Logik, und sie lässt sich so ohne
/// Plattform-Kanal prüfen. `FlutterLocalNotificationsPlugin` ist eine
/// konkrete Klasse mit privatem Konstruktor — sie im Test zu ersetzen geht
/// nicht, und der echte Kanal ist im Dart-VM-Test nicht auflösbar.
class DailyStatusMessage {
  const DailyStatusMessage({required this.title, required this.body});

  final String title;
  final String body;

  /// `null` heißt: **keine Meldung** — entweder ist alles erledigt oder es
  /// gibt gar keine Gewohnheiten. Ein „0 von 0 erledigt" in der Leiste wäre
  /// kein Ansporn, sondern Rauschen.
  static DailyStatusMessage? forProgress({
    required int done,
    required int total,
    required AppLocalizations l10n,
  }) {
    if (total == 0 || done >= total) return null;
    return DailyStatusMessage(
      title: l10n.notificationStatusTitle(done, total),
      body: l10n.notificationStatusBody(total - done),
    );
  }
}

/// Payload-Schlüssel der Sprache — der Snooze-Handler läuft ggf. in einer
/// frischen Isolate ohne App-Zustand und kann die eingestellte Sprache
/// nirgends sonst herbekommen.
const String _payloadLanguageKey = 'lang';

/// Einzige Stelle, die mit `flutter_local_notifications` spricht (siehe
/// PLAN.md Phase 7). Kapselt Initialisierung, Berechtigungen und das
/// Planen/Abbrechen täglicher Erinnerungen pro Gewohnheit. Der Snooze-Button
/// auf der Notification wird über Top-Level-Funktionen behandelt (siehe
/// unten) — Android/iOS können den Antwort-Callback in einer eigenen
/// Hintergrund-Isolate ausführen, die keinen Zugriff auf App-Zustand
/// (Riverpod/DB) hat, daher trägt der Payload Habit-ID, -Name **und**
/// Sprache.
///
/// Notification-Texte entstehen außerhalb des Widget-Baums: es gibt keinen
/// `BuildContext`, aus dem `AppLocalizations.of(...)` lesen könnte. Alle
/// Methoden nehmen daher die Sprache entgegen und lösen sie über
/// [lookupAppLocalizations] auf (siehe `resolvedLocaleProvider`).
class NotificationService {
  NotificationService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  /// [locale] wird für die iOS-Notification-Kategorie gebraucht, die einmalig
  /// beim Start registriert wird. Ein späterer Sprachwechsel greift dort erst
  /// nach einem Neustart der App — Android-Aktionen hängen dagegen an der
  /// einzelnen Notification und folgen der Sprache sofort.
  Future<void> initialize(Locale locale) async {
    // PLAN.md Phase 26.1: Im Browser gibt es keine geplanten
    // Erinnerungen. Der Aufrufer muss das nicht wissen.
    if (!supportsReminders) return;
    final l10n = lookupAppLocalizations(locale);
    tz.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // Zeitzone nicht auflösbar — Fallback bleibt UTC; betrifft nur die
      // angezeigte Uhrzeit der Erinnerung, nicht die App-Funktion.
    }

    await _plugin.initialize(
      settings: InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          notificationCategories: [
            DarwinNotificationCategory(
              _snoozeCategoryId,
              actions: [
                DarwinNotificationAction.plain(
                  _snoozeActionId,
                  l10n.notificationSnoozeAction,
                ),
              ],
            ),
          ],
        ),
      ),
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          _onBackgroundNotificationResponse,
    );
  }

  /// Fragt die Benachrichtigungs-Berechtigung an (Android 13+, iOS/macOS).
  Future<bool> requestPermission() async {
    // Ohne Erinnerungen gibt es auch keine Berechtigung zu holen.
    if (!supportsReminders) return false;
    final androidGranted = await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    final iosGranted = await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    return (androidGranted ?? true) && (iosGranted ?? true);
  }

  /// Plant eine tägliche Erinnerung für [habitId] um [minuteOfDay] (Minuten
  /// seit Mitternacht). Ersetzt eine ggf. bereits geplante Erinnerung für
  /// dieselbe Gewohnheit (gleiche Notification-ID).
  ///
  /// [streak] ist die laufende Serie **zum Zeitpunkt des Planens**. Ist sie
  /// größer als 0, nennt der Text sie — „deine Serie von 12 Tagen endet um
  /// Mitternacht" wirkt, wo „vergiss deine Gewohnheit nicht" verpufft (siehe
  /// PLAN.md Phase 23). Der Wert kann veralten: Der Text steht beim Planen
  /// fest, nicht beim Anzeigen. Deshalb wird bei jedem Anlass neu geplant
  /// (App-Start, Sprachwechsel, Abhaken) — und deshalb gibt es daneben die
  /// stets aktuelle Tagesstand-Meldung.
  Future<void> scheduleForHabit({
    required int habitId,
    required String habitName,
    required int minuteOfDay,
    required Locale locale,
    int streak = 0,
  }) async {
    if (!supportsReminders) return;

    final l10n = lookupAppLocalizations(locale);
    final scheduled = _nextInstanceOf(minuteOfDay);
    await _plugin.zonedSchedule(
      id: habitId,
      scheduledDate: scheduled,
      title: l10n.notificationTitle(habitName),
      body: streak > 0
          ? l10n.notificationStreakAtRisk(streak)
          : l10n.notificationBody,
      payload: jsonEncode({
        'habitId': habitId,
        'name': habitName,
        _payloadLanguageKey: locale.languageCode,
      }),
      notificationDetails: _detailsFor(l10n),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelForHabit(int habitId) async {
    if (!supportsReminders) return;
    await _plugin.cancel(id: habitId);
  }

  /// Dauerhafte Meldung „Heute: 2 von 5 erledigt" (siehe PLAN.md Phase 23).
  ///
  /// Sie steht in der Leiste und auf dem Sperrbildschirm, solange etwas offen
  /// ist, und verschwindet, sobald alles erledigt ist — [done] `>=` [total]
  /// räumt sie ab, ebenso `total == 0` (nichts angelegt, nichts zu mahnen).
  ///
  /// **Bewusst leise** (`Importance.low`): Sie ist dauernd da; ein Ton bei
  /// jeder Änderung wäre nicht eindringlich, sondern unerträglich. Der Druck
  /// kommt aus der Zahl, nicht aus dem Geräusch.
  Future<void> showDailyStatus({
    required int done,
    required int total,
    required Locale locale,
  }) async {
    if (!supportsReminders) return;

    final l10n = lookupAppLocalizations(locale);
    final message = DailyStatusMessage.forProgress(
      done: done,
      total: total,
      l10n: l10n,
    );
    if (message == null) return cancelDailyStatus();

    await _plugin.show(
      id: _statusNotificationId,
      title: message.title,
      body: message.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _statusChannelId,
          l10n.notificationStatusChannelName,
          channelDescription: l10n.notificationStatusChannelDescription,
          importance: Importance.low,
          priority: Priority.low,
          // Bleibt liegen, bis der Tag erledigt ist — ein Wisch soll ihn
          // nicht wegräumen, das ist der Punkt der Sache.
          ongoing: true,
          autoCancel: false,
          onlyAlertOnce: true,
          // Sonst steht auf dem Sperrbildschirm nur „Benachrichtigung".
          visibility: NotificationVisibility.public,
          showWhen: false,
        ),
        iOS: const DarwinNotificationDetails(presentSound: false),
      ),
    );
  }

  Future<void> cancelDailyStatus() async {
    if (!supportsReminders) return;
    await _plugin.cancel(id: _statusNotificationId);
  }

  tz.TZDateTime _nextInstanceOf(int minuteOfDay) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      minuteOfDay ~/ 60,
      minuteOfDay % 60,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}

NotificationDetails _detailsFor(AppLocalizations l10n) => NotificationDetails(
  android: AndroidNotificationDetails(
    _channelId,
    l10n.notificationChannelName,
    channelDescription: l10n.notificationChannelDescription,
    // Phase 23: Eine Erinnerung, die lautlos in der Leiste landet, erinnert
    // niemanden. `high` bringt sie als Einblendung — einmal, zur gewählten
    // Uhrzeit. `public` sorgt dafür, dass auf dem Sperrbildschirm der echte
    // Text steht und nicht „Benachrichtigung".
    importance: Importance.high,
    priority: Priority.high,
    visibility: NotificationVisibility.public,
    actions: [
      AndroidNotificationAction(
        _snoozeActionId,
        l10n.notificationSnoozeAction,
        showsUserInterface: false,
        cancelNotification: true,
      ),
    ],
  ),
  iOS: const DarwinNotificationDetails(categoryIdentifier: _snoozeCategoryId),
);

/// Notification-ID der Snooze-Wiedervorlage — versetzt gegenüber der
/// Habit-ID, damit sie die reguläre tägliche Erinnerung nicht überschreibt.
int _snoozeNotificationId(int habitId) => 1000000 + habitId;

void _onNotificationResponse(NotificationResponse response) {
  if (response.actionId == _snoozeActionId) {
    unawaited(_snooze(response));
  }
}

@pragma('vm:entry-point')
void _onBackgroundNotificationResponse(NotificationResponse response) {
  if (response.actionId == _snoozeActionId) {
    unawaited(_snooze(response));
  }
}

/// Schreibt eine einmalige Wiedervorlage-Notification in [_snoozeDuration].
/// Läuft ggf. in einer frischen Hintergrund-Isolate (kein App-Zustand
/// verfügbar) — Habit-ID/-Name kommen daher direkt aus dem Payload, nicht
/// aus der Datenbank.
Future<void> _snooze(NotificationResponse response) async {
  final payload = response.payload;
  if (payload == null) return;

  final Map<String, dynamic> data;
  try {
    data = jsonDecode(payload) as Map<String, dynamic>;
  } catch (_) {
    return;
  }
  final habitId = data['habitId'] as int?;
  final habitName = data['name'] as String?;
  if (habitId == null || habitName == null) return;

  // Sprache aus dem Payload: in einer Hintergrund-Isolate gibt es weder
  // Riverpod noch `shared_preferences`-Zustand der App.
  final languageCode = data[_payloadLanguageKey] as String?;
  final l10n = lookupAppLocalizations(
    languageCode == null ? fallbackLocale : Locale(languageCode),
  );

  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
  );

  await plugin.zonedSchedule(
    id: _snoozeNotificationId(habitId),
    scheduledDate: tz.TZDateTime.from(
      DateTime.now().add(_snoozeDuration),
      tz.UTC,
    ),
    title: l10n.notificationTitle(habitName),
    body: l10n.notificationSnoozedBody(_snoozeDuration.inMinutes),
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        l10n.notificationChannelName,
        channelDescription: l10n.notificationChannelDescription,
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
  );
}

void unawaited(Future<void> future) {}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(FlutterLocalNotificationsPlugin());
});
