import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/core/utils/date_utils.dart';
import 'package:root_in/data/models/habit_schedule.dart';

/// PLAN.md Phase 32: Die Regeln des Wochenplans — was gespeichert wird und
/// wann eine Gewohnheit an einem Tag „ansteht". Reines Dart, keine Datenbank.
void main() {
  // Eine feste Woche: Montag 20.07.2026 bis Sonntag 26.07.2026.
  final monday = DateTime(2026, 7, 20);
  DateTime day(int offset) => addDays(monday, offset); // 0 = Montag … 6 = Sonntag

  group('Aufbau', () {
    test('jeden Tag: alle sieben Bits, Soll 7', () {
      const schedule = HabitSchedule.everyDay();

      expect(schedule.mode, ScheduleMode.everyDay);
      expect(schedule.dayMask, 127);
      expect(schedule.weeklyTarget, 7);
      expect(schedule.weekdays, [1, 2, 3, 4, 5, 6, 7]);
    });

    test('bestimmte Tage: Maske und Soll folgen aus den Tagen', () {
      final schedule = HabitSchedule.onDays([
        DateTime.tuesday,
        DateTime.thursday,
      ]);

      expect(schedule.mode, ScheduleMode.specificDays);
      // Dienstag = Bit 1 (2), Donnerstag = Bit 3 (8).
      expect(schedule.dayMask, 10);
      expect(schedule.weeklyTarget, 2);
      expect(schedule.weekdays, [2, 4]);
    });

    test('alle sieben Tage ergeben „jeden Tag"', () {
      expect(
        HabitSchedule.onDays([1, 2, 3, 4, 5, 6, 7]),
        const HabitSchedule.everyDay(),
      );
    });

    test('x-mal pro Woche: alle Tage erlaubt, Soll = x', () {
      final schedule = HabitSchedule.countPerWeek(3);

      expect(schedule.mode, ScheduleMode.countPerWeek);
      expect(schedule.dayMask, 127);
      expect(schedule.weeklyTarget, 3);
    });

    test('siebenmal pro Woche ist „jeden Tag"', () {
      expect(HabitSchedule.countPerWeek(7), const HabitSchedule.everyDay());
    });

    test('ungültige Eingaben werfen', () {
      expect(() => HabitSchedule.onDays(const []), throwsArgumentError);
      expect(() => HabitSchedule.onDays([0]), throwsArgumentError);
      expect(() => HabitSchedule.onDays([8]), throwsArgumentError);
      expect(() => HabitSchedule.countPerWeek(0), throwsArgumentError);
      expect(() => HabitSchedule.countPerWeek(8), throwsArgumentError);
    });
  });

  group('aus den Spalten der Tabelle lesen', () {
    test('127 und 7 sind „jeden Tag" — der Zustand aller alten Gewohnheiten', () {
      expect(
        HabitSchedule.fromColumns(scheduleDays: 127, timesPerWeek: 7),
        const HabitSchedule.everyDay(),
      );
    });

    test('eine Maske mit fehlenden Tagen sind bestimmte Tage', () {
      final schedule = HabitSchedule.fromColumns(
        scheduleDays: 10,
        timesPerWeek: 2,
      );

      expect(schedule.mode, ScheduleMode.specificDays);
      expect(schedule.weekdays, [2, 4]);
    });

    test('alle Tage, aber Soll unter 7, ist „x-mal pro Woche"', () {
      final schedule = HabitSchedule.fromColumns(
        scheduleDays: 127,
        timesPerWeek: 3,
      );

      expect(schedule, HabitSchedule.countPerWeek(3));
    });

    test('bei festen Tagen zählt die Maske, nicht ein abweichendes Soll', () {
      // Ein widersprüchlicher Bestand darf die Anzeige nicht kippen: Die
      // Maske ist die Wahrheit, das Soll folgt aus ihr.
      final schedule = HabitSchedule.fromColumns(
        scheduleDays: 10,
        timesPerWeek: 99,
      );

      expect(schedule.weeklyTarget, 2);
    });

    test('nicht Deutbares wird „jeden Tag" und wirft nie', () {
      // Die Werte stammen aus einer Datenbank oder Sicherungsdatei. Eine
      // kaputte Zeile darf die Heute-Seite nicht zum Absturz bringen.
      for (final (days, times) in [(0, 7), (0, 0), (127, 0), (127, -1), (255, 7)]) {
        expect(
          HabitSchedule.fromColumns(scheduleDays: days, timesPerWeek: times),
          const HabitSchedule.everyDay(),
          reason: 'scheduleDays=$days, timesPerWeek=$times',
        );
      }
    });

    test('was gespeichert wird, kommt unverändert zurück', () {
      final schedules = [
        const HabitSchedule.everyDay(),
        HabitSchedule.onDays([2, 4]),
        HabitSchedule.onDays([1, 2, 3, 4, 5]),
        HabitSchedule.onDays([7]),
        HabitSchedule.countPerWeek(1),
        HabitSchedule.countPerWeek(6),
      ];
      for (final schedule in schedules) {
        expect(
          HabitSchedule.fromColumns(
            scheduleDays: schedule.dayMask,
            timesPerWeek: schedule.weeklyTarget,
          ),
          schedule,
        );
      }
    });
  });

  group('isDueOn — steht die Gewohnheit an diesem Tag an?', () {
    test('jeden Tag: immer', () {
      const schedule = HabitSchedule.everyDay();
      for (var i = 0; i < 7; i++) {
        expect(
          schedule.isDueOn(day: day(i), doneOnDay: false, doneDates: const {}),
          isTrue,
        );
      }
    });

    test('bestimmte Tage: nur an diesen Wochentagen', () {
      final schedule = HabitSchedule.onDays([DateTime.tuesday, DateTime.thursday]);

      bool due(int offset) => schedule.isDueOn(
        day: day(offset),
        doneOnDay: false,
        doneDates: const {},
      );

      expect(due(0), isFalse); // Montag
      expect(due(1), isTrue); // Dienstag
      expect(due(2), isFalse); // Mittwoch
      expect(due(3), isTrue); // Donnerstag
      expect(due(6), isFalse); // Sonntag
      // Eine Woche später gilt dasselbe.
      expect(due(8), isTrue); // Dienstag
    });

    test('ein gesetztes Häkchen steht immer an — auch außerhalb des Plans', () {
      // Sonst verschwände es aus der Liste und ließe sich nicht mehr
      // zurücknehmen; ein Nachtrag an einem freien Tag wäre unsichtbar.
      final schedule = HabitSchedule.onDays([DateTime.tuesday]);

      expect(
        schedule.isDueOn(day: day(2), doneOnDay: true, doneDates: {day(2)}),
        isTrue,
      );
    });

    test('x-mal pro Woche: bis das Soll voll ist, danach frei', () {
      final schedule = HabitSchedule.countPerWeek(2);

      bool due(int offset, Set<DateTime> done) => schedule.isDueOn(
        day: day(offset),
        doneOnDay: done.contains(day(offset)),
        doneDates: done,
      );

      // Noch nichts getan: jeder Tag steht an.
      expect(due(0, {}), isTrue);
      // Ein Mal getan (Montag): Dienstag steht noch an.
      expect(due(1, {day(0)}), isTrue);
      // Zweimal getan (Montag, Dienstag): der Mittwoch ist frei …
      expect(due(2, {day(0), day(1)}), isFalse);
      // … der Sonntag auch.
      expect(due(6, {day(0), day(1)}), isFalse);
    });

    test('x-mal pro Woche: der Tag, an dem das Soll voll wird, bleibt sichtbar', () {
      // Am Dienstag ist die zweite Erledigung eingetragen. Der Eintrag muss
      // dort stehen bleiben, sonst könnte man das Häkchen nicht zurücknehmen.
      final schedule = HabitSchedule.countPerWeek(2);
      final done = {day(0), day(1)};

      expect(
        schedule.isDueOn(day: day(1), doneOnDay: true, doneDates: done),
        isTrue,
      );
    });

    test('x-mal pro Woche: mit dem Montag beginnt das Soll von vorn', () {
      final schedule = HabitSchedule.countPerWeek(2);
      // Die Vorwoche war voll — sie darf die neue Woche nicht berühren.
      final lastWeek = {day(-7), day(-6)};

      expect(
        schedule.isDueOn(day: day(0), doneOnDay: false, doneDates: lastWeek),
        isTrue,
      );
      // Auch der Sonntag der Vorwoche zählt nicht in die neue Woche.
      expect(
        schedule.isDueOn(
          day: day(1),
          doneOnDay: false,
          doneDates: {day(-1)},
        ),
        isTrue,
      );
    });
  });

  group('Frei-Tag-Regel und gemeinsame Serie', () {
    test('Frei-Tag: jeden Tag ja, feste Tage erst ab vier, x-mal pro Woche nie', () {
      expect(const HabitSchedule.everyDay().allowsFreeDay, isTrue);
      expect(HabitSchedule.onDays([1, 3, 5]).allowsFreeDay, isFalse);
      expect(HabitSchedule.onDays([1, 2, 3, 4]).allowsFreeDay, isTrue);
      expect(HabitSchedule.countPerWeek(4).allowsFreeDay, isFalse);
    });

    test('ohne Gewohnheiten zählt jeder Tag', () {
      final required = requiredDaysOf(const []);
      for (var i = 0; i < 7; i++) {
        expect(required(day(i)), isTrue);
      }
    });

    test('haben alle feste Tage, zählt deren Vereinigung', () {
      final required = requiredDaysOf([
        HabitSchedule.onDays([DateTime.tuesday, DateTime.thursday]),
        HabitSchedule.onDays([DateTime.saturday]),
      ]);

      expect(required(day(0)), isFalse); // Montag
      expect(required(day(1)), isTrue); // Dienstag
      expect(required(day(3)), isTrue); // Donnerstag
      expect(required(day(5)), isTrue); // Samstag
      expect(required(day(6)), isFalse); // Sonntag
    });

    test('eine Gewohnheit „jeden Tag" oder „x-mal" macht jeden Tag zählend', () {
      for (final other in [
        const HabitSchedule.everyDay(),
        HabitSchedule.countPerWeek(3),
      ]) {
        final required = requiredDaysOf([
          HabitSchedule.onDays([DateTime.tuesday]),
          other,
        ]);
        for (var i = 0; i < 7; i++) {
          expect(required(day(i)), isTrue);
        }
      }
    });
  });
}
