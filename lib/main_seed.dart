import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/services/settings_service.dart';
import 'core/utils/date_utils.dart';
import 'data/models/habit_goal_type.dart';
import 'data/repositories/habit_repository.dart';
import 'main.dart' as app;

/// **Nur für Store-Screenshots** (siehe PLAN.md Phase 15.2), nie für einen
/// Release-Build. Start mit:
///
/// ```
/// flutter run -t lib/main_seed.dart                          # deutsch
/// flutter run -t lib/main_seed.dart --dart-define=SEED_LANG=en   # englisch
/// ```
///
/// Die Sprache muss **beim Säen** feststehen, nicht erst in den
/// Einstellungen: Namen von Gewohnheiten und Kategorien sind Nutzerdaten und
/// bleiben bei einem späteren Sprachwechsel bewusst unverändert (siehe
/// `core/constants/habit_templates.dart`). Ein bloßes Umschalten der
/// Oberfläche ergäbe also englische Menüs mit deutschen Gewohnheiten.
///
/// Legt einen realistischen Bestand aus rund vier Monaten an und startet
/// danach die ganz normale App. Ohne diesen Bestand wären Matrix-Grid,
/// Diagramme und Serien auf den Screenshots leer — und ein leeres Jahresraster
/// verkauft die App nicht.
///
/// Bewusst **kein** kopierter App-Start: gesät wird in einem eigenen
/// Container, der danach wieder geschlossen wird (`appDatabaseProvider` gibt
/// die Datenbank in seinem `onDispose` frei), erst dann übernimmt das echte
/// [app.main]. So gibt es keine zweite offene DB-Verbindung und keine
/// Duplikate der Startlogik (siehe PLAN.md Abschnitt 9, „Puzzling"/DRY).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  try {
    await _seed(container, prefs);
  } finally {
    container.dispose();
  }

  await app.main();
}

Future<void> _seed(ProviderContainer container, SharedPreferences prefs) async {
  final repository = container.read(habitRepositoryProvider);

  // Nicht doppelt säen: ein zweiter Start soll den Bestand nicht verdoppeln.
  // Für einen frischen Durchlauf vorher `adb shell pm clear com.rootin.app`.
  final existing = await repository.watchActiveHabits().first;
  if (existing.isNotEmpty) return;

  // Erklärungs-Seite überspringen und einen Profilnamen setzen — beides
  // gehört zu einem glaubwürdigen Screenshot.
  await prefs.setBool('onboarding_seen', true);
  await prefs.setString('profile_name', 'Saleh');

  // Sprache des gesamten Durchlaufs — siehe Klassendoku oben.
  const isEnglish = String.fromEnvironment('SEED_LANG') == 'en';
  await prefs.setString('app_language', isEnglish ? 'english' : 'german');

  // PHASE 20 (2026-08-01): Werbung deaktiviert — die Zeile bleibt trotzdem
  // stehen. Sie schadet nicht (der Merker wird derzeit von niemandem gelesen)
  // und ist beim Wiedereinschalten sofort wieder nötig: Ein Release-Build
  // würde sonst **echte** Anzeigen anfordern — Emulator-Aufrufe auf die
  // eigenen Ad-Units kann AdMob als ungültigen Traffic werten und das Konto
  // sperren; ein Debug-Build hätte ein „Test Ad"-Banner quer über jedem
  // Screenshot.
  await prefs.setBool('remove_ads_purchased', true);

  const languages = isEnglish ? 'Language learning' : 'Sprachenlernen';
  const sports = isEnglish ? 'Sports' : 'Sport';
  const mindfulness = isEnglish ? 'Mindfulness' : 'Achtsamkeit';

  await repository.ensureDefaultCategories(<String>[languages]);

  // `weekdays` (1 = Montag … 7 = Sonntag) hat zwei Aufgaben in einem Wert:
  // es bestimmt, an welchen Tagen überhaupt gesät wird, **und** daraus folgt
  // `timesPerWeek` der Gewohnheit. Getrennte Felder würden sonst auseinander-
  // laufen — dann stünde auf der Übersicht ein Wochen-Ziel, das zum Bestand
  // nicht passt (leere Liste = jeden Tag, also 7×).
  final seeds = <({
    String name,
    int color,
    String category,
    HabitGoalType goal,
    int? minutes,
    double rate,
    List<int> weekdays,
  })>[
    (
      name: isEnglish ? 'Vocabulary 10 min daily' : 'Wörter 10 Min täglich',
      color: 0xFF2E7D5B,
      category: languages,
      goal: HabitGoalType.duration,
      minutes: 10,
      rate: 0.88,
      weekdays: const [],
    ),
    (
      name: isEnglish ? 'Coursebook' : 'Kursbuch',
      color: 0xFF3B6EA5,
      category: languages,
      goal: HabitGoalType.checkbox,
      minutes: null,
      rate: 0.72,
      weekdays: const [1, 2, 4, 5],
    ),
    (
      name: isEnglish ? 'Reading' : 'Lesen',
      color: 0xFF7A5AA8,
      category: languages,
      goal: HabitGoalType.duration,
      minutes: 20,
      rate: 0.66,
      weekdays: const [1, 2, 3, 4, 5],
    ),
    (
      name: isEnglish ? 'Running' : 'Joggen',
      color: 0xFFE0A82E,
      category: sports,
      goal: HabitGoalType.checkbox,
      minutes: null,
      rate: 0.58,
      weekdays: const [1, 3, 6],
    ),
    (
      name: 'Meditation',
      color: 0xFF2F9C95,
      category: mindfulness,
      goal: HabitGoalType.duration,
      minutes: 10,
      rate: 0.80,
      weekdays: const [],
    ),
    (
      name: isEnglish ? 'Journaling' : 'Tagebuch',
      color: 0xFFD64545,
      category: mindfulness,
      goal: HabitGoalType.checkbox,
      minutes: null,
      rate: 0.63,
      weekdays: const [3, 7],
    ),
  ];

  // Fester Startwert: derselbe Bestand bei jedem Durchlauf, damit sich
  // Screenshots reproduzieren lassen.
  final random = Random(42);
  final today = dateOnly(DateTime.now());

  // Etwas mehr als ein Jahr: Der Jahr-Tab zeigt die letzten 12 Monate. Mit
  // weniger Bestand bliebe zwei Drittel des Matrix-Grids grau — als Werbebild
  // wertlos.
  const days = 400;

  for (final seed in seeds) {
    final habitId = await repository.addHabit(
      name: seed.name,
      colorValue: seed.color,
      iconKey: 'task_alt',
      category: seed.category,
      goalType: seed.goal,
      targetMinutes: seed.minutes,
      timesPerWeek: seed.weekdays.isEmpty ? 7 : seed.weekdays.length,
    );

    for (var back = days; back >= 0; back--) {
      final date = addDays(today, -back);

      // Gewohnheiten mit festen Tagen nur an diesen Tagen säen — sonst sähe
      // die Übersicht ein Wochen-Ziel von 3, aber Erledigungen an sieben
      // Tagen, und die Spalte „Offen" wäre dauerhaft 0.
      if (seed.weekdays.isNotEmpty && !seed.weekdays.contains(date.weekday)) {
        continue;
      }

      // Jüngere Tage etwas dichter — das ergibt im Matrix-Grid einen
      // sichtbaren Aufwärtstrend statt gleichförmigem Rauschen.
      final recency = 1 - (back / days);
      final chance = (seed.rate * (0.75 + 0.35 * recency)).clamp(0.0, 0.97);
      if (random.nextDouble() > chance) continue;

      await repository.setCompletion(
        habitId,
        date,
        true,
        valueMinutes: seed.goal == HabitGoalType.duration
            ? seed.minutes! + random.nextInt(15)
            : null,
      );
    }
  }
}
