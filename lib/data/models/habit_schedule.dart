import '../../core/utils/date_utils.dart';
import '../local/database.dart' show Habit;

/// Wie eine Gewohnheit über die Woche verteilt ist (siehe PLAN.md Phase 32).
enum ScheduleMode {
  /// Jeden Tag — der Zustand aller Gewohnheiten vor Phase 32.
  everyDay,

  /// Nur an bestimmten Wochentagen, z. B. Dienstag und Donnerstag.
  specificDays,

  /// Eine feste Anzahl Erledigungen pro Woche, an **beliebigen** Tagen.
  countPerWeek,
}

/// Der Wochenplan einer Gewohnheit — reines Dart, ohne Datenbankzugriff, damit
/// jede Regel einzeln testbar bleibt.
///
/// **Gespeichert wird er in zwei bereits vorhandenen bzw. neuen Spalten der
/// Tabelle `habits`** (kein zweites Format):
///
/// | Modus        | `scheduleDays`        | `timesPerWeek`      |
/// |--------------|-----------------------|---------------------|
/// | everyDay     | 127 (alle sieben Bits)| 7                   |
/// | specificDays | Bitmaske, Mo = Bit 0  | Anzahl gesetzter Bits |
/// | countPerWeek | 127                   | 1–6                 |
///
/// ⚠️ `timesPerWeek` bleibt also in **allen** Modi das Wochen-Soll. Die
/// Statistik (`targetCount = timesPerWeek × Wochen`) muss deshalb nichts über
/// Wochenpläne wissen. Aus den beiden Spalten wird der Modus wieder abgelesen
/// ([HabitSchedule.fromColumns]) — ein dritter Wert, der auseinanderlaufen
/// könnte, existiert nicht.
class HabitSchedule {
  const HabitSchedule._(this.mode, this.dayMask, this.weeklyTarget);

  /// Jeden Tag. `const`, damit es als Standardwert taugt.
  const HabitSchedule.everyDay()
    : mode = ScheduleMode.everyDay,
      dayMask = allDaysMask,
      weeklyTarget = 7;

  /// Alle sieben Wochentags-Bits gesetzt (Montag = Bit 0 … Sonntag = Bit 6).
  static const int allDaysMask = 127;

  /// Ab so vielen Terminen pro Woche gilt die Frei-Tag-Regel der Serie (siehe
  /// [allowsFreeDay]). Darunter würde ein Frei-Tag einen Großteil der Woche
  /// erlassen — bei **einem** Termin pro Woche wäre die Serie unbrechbar.
  static const int minDaysForFreeDay = 4;

  /// Nur an den [weekdays] (1 = Montag … 7 = Sonntag). Alle sieben Tage
  /// ergeben [HabitSchedule.everyDay]. Wirft bei einer leeren Menge oder einem
  /// ungültigen Wochentag — das Formular lässt beides nicht zu.
  factory HabitSchedule.onDays(Iterable<int> weekdays) {
    var mask = 0;
    for (final weekday in weekdays) {
      if (weekday < DateTime.monday || weekday > DateTime.sunday) {
        throw ArgumentError.value(
          weekday,
          'weekdays',
          'muss zwischen 1 (Montag) und 7 (Sonntag) liegen',
        );
      }
      mask |= 1 << (weekday - 1);
    }
    if (mask == 0) {
      throw ArgumentError.value(weekdays, 'weekdays', 'mindestens ein Tag');
    }
    return _fromMask(mask);
  }

  /// [count]-mal pro Woche an beliebigen Tagen (1–7). Sieben ergibt
  /// [HabitSchedule.everyDay].
  factory HabitSchedule.countPerWeek(int count) {
    if (count < 1 || count > 7) {
      throw ArgumentError.value(count, 'count', 'muss zwischen 1 und 7 liegen');
    }
    if (count == 7) return const HabitSchedule.everyDay();
    return HabitSchedule._(ScheduleMode.countPerWeek, allDaysMask, count);
  }

  /// Liest den Plan aus den beiden Spalten der Tabelle `habits`.
  ///
  /// **Nachsichtig, wirft nie:** Die Werte kommen aus einer Datenbank oder
  /// einer Sicherungsdatei, und eine kaputte Zeile darf die Heute-Seite nicht
  /// zum Absturz bringen. Was nicht zu deuten ist, wird zu „jeden Tag".
  factory HabitSchedule.fromColumns({
    required int scheduleDays,
    required int timesPerWeek,
  }) {
    final mask = scheduleDays & allDaysMask;
    if (mask != 0 && mask != allDaysMask) return _fromMask(mask);
    if (timesPerWeek >= 1 && timesPerWeek < 7) {
      return HabitSchedule._(ScheduleMode.countPerWeek, allDaysMask, timesPerWeek);
    }
    return const HabitSchedule.everyDay();
  }

  static HabitSchedule _fromMask(int mask) {
    if (mask == allDaysMask) return const HabitSchedule.everyDay();
    var bits = 0;
    for (var i = 0; i < 7; i++) {
      if (((mask >> i) & 1) == 1) bits++;
    }
    return HabitSchedule._(ScheduleMode.specificDays, mask, bits);
  }

  final ScheduleMode mode;

  /// Wochentags-Bits, Montag = Bit 0. Bei [ScheduleMode.everyDay] und
  /// [ScheduleMode.countPerWeek] alle sieben gesetzt.
  final int dayMask;

  /// Soll pro Woche — in **jedem** Modus, siehe Klassendoku.
  final int weeklyTarget;

  /// Ist [weekday] (1 = Montag … 7 = Sonntag) im Plan enthalten? Bei
  /// [ScheduleMode.countPerWeek] immer wahr: Dort ist kein Tag vorgegeben.
  bool includesWeekday(int weekday) => ((dayMask >> (weekday - 1)) & 1) == 1;

  /// Die gewählten Wochentage, aufsteigend (1 = Montag).
  List<int> get weekdays => [
    for (var weekday = 1; weekday <= 7; weekday++)
      if (includesWeekday(weekday)) weekday,
  ];

  /// Darf pro Woche ein verpasster Termin die Serie erhalten (Frei-Tag-Regel,
  /// siehe `StreakCalculator`)? Bei „jeden Tag" ja — wie immer. Bei festen
  /// Tagen nur, wenn es mindestens [minDaysForFreeDay] sind.
  bool get allowsFreeDay =>
      mode == ScheduleMode.everyDay ||
      (mode == ScheduleMode.specificDays && weeklyTarget >= minDaysForFreeDay);

  /// **Steht die Gewohnheit an [day] an?** — die eine Regel, aus der die
  /// Heute-Seite, die Tages-Prozente und die Heatmap-Intensität folgen.
  ///
  /// - **Jeden Tag:** immer.
  /// - **Bestimmte Tage:** an diesen Wochentagen.
  /// - **Anzahl pro Woche:** an jedem Tag, bis das Wochen-Soll voll ist —
  ///   danach ist der Rest der Woche frei.
  ///
  /// ⚠️ **Wer an einem Tag etwas erledigt hat, für den steht es dort auch an**
  /// ([doneOnDay]), gleich was der Plan sagt: Ein gesetztes Häkchen darf nie
  /// aus der Liste verschwinden, sonst ließe es sich nicht mehr zurücknehmen —
  /// und ein Nachtrag außerhalb des Plans wäre unsichtbar.
  ///
  /// [doneDates] sind die Erledigungstage **dieser** Gewohnheit (auf Mitternacht
  /// normalisiert); für [ScheduleMode.countPerWeek] genügt die Woche bis
  /// [day], mehr schadet nicht.
  bool isDueOn({
    required DateTime day,
    required bool doneOnDay,
    required Set<DateTime> doneDates,
  }) {
    if (doneOnDay) return true;
    final date = dateOnly(day);
    switch (mode) {
      case ScheduleMode.everyDay:
        return true;
      case ScheduleMode.specificDays:
        return includesWeekday(date.weekday);
      case ScheduleMode.countPerWeek:
        var doneBefore = 0;
        for (
          var d = weekStartOf(date);
          d.isBefore(date);
          d = addDays(d, 1)
        ) {
          if (doneDates.contains(d)) doneBefore++;
        }
        return doneBefore < weeklyTarget;
    }
  }

  @override
  bool operator ==(Object other) =>
      other is HabitSchedule &&
      other.mode == mode &&
      other.dayMask == dayMask &&
      other.weeklyTarget == weeklyTarget;

  @override
  int get hashCode => Object.hash(mode, dayMask, weeklyTarget);

  @override
  String toString() => 'HabitSchedule($mode, days: $weekdays, target: $weeklyTarget)';
}

/// Welche Tage zählen für eine **gemeinsame** Serie über mehrere Gewohnheiten
/// (die Gesamt-Serie auf der Konto-Seite)?
///
/// Haben **alle** Gewohnheiten feste Wochentage, sind es genau deren
/// Vereinigung — ein Mittwoch, an dem nichts ansteht, bricht die Serie nicht.
/// Sobald auch nur eine Gewohnheit „jeden Tag" oder „x-mal pro Woche" ist (oder
/// es gar keine gibt), zählt **jeder** Tag: Dann ist kein Tag von vornherein
/// frei, und die Serie verhält sich wie vor Phase 32.
bool Function(DateTime day) requiredDaysOf(Iterable<HabitSchedule> schedules) {
  var mask = 0;
  var any = false;
  for (final schedule in schedules) {
    any = true;
    if (schedule.mode != ScheduleMode.specificDays) return (_) => true;
    mask |= schedule.dayMask;
  }
  if (!any) return (_) => true;
  return (day) => ((mask >> (day.weekday - 1)) & 1) == 1;
}

/// Der Wochenplan einer gespeicherten Gewohnheit.
extension HabitScheduleOfHabit on Habit {
  HabitSchedule get schedule => HabitSchedule.fromColumns(
    scheduleDays: scheduleDays,
    timesPerWeek: timesPerWeek,
  );
}
