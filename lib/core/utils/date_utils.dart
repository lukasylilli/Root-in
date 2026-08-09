/// Einzige Stelle für Datums-Normalisierung. Andere Dateien importieren
/// diese Funktionen, statt `DateTime(d.year, d.month, d.day)` zu wiederholen.
library;

/// Normalisiert ein [DateTime] auf Mitternacht (ohne Uhrzeit-Anteil).
DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

/// Verschiebt [date] um [days] Kalendertage. Nutzt Konstruktor-Arithmetik
/// statt `Duration`, damit Sommerzeit-Umstellungen (23-/25-Stunden-Tage)
/// das Ergebnis nicht um eine Stunde verschieben.
DateTime addDays(DateTime date, int days) =>
    DateTime(date.year, date.month, date.day + days);

/// Montag der Kalenderwoche, in der [date] liegt.
DateTime weekStartOf(DateTime date) {
  final normalized = dateOnly(date);
  return addDays(normalized, -(normalized.weekday - 1));
}
