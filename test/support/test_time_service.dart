import 'package:root_in/core/services/time_service.dart';

/// Test-Ersatz für [TimeService]: liefert ein festes Datum ohne echten
/// Netzwerkzugriff. Im echten Betrieb macht `TimeService` bewusst eine
/// Online-Verifikation (Anti-Cheat gegen Uhr-Manipulation, siehe PLAN.md
/// Abschnitt 3) — in Widget-Tests ist das weder gewünscht noch zuverlässig:
/// ein echter `HttpClient`-Timeout lässt einen Timer über das Testende
/// hinaus offen (`!timersPending`-Fehler). Jeder Widget-Test, der eine
/// datumsabhängige Seite rendert, überschreibt `timeServiceProvider` hiermit.
class TestTimeService extends TimeService {
  const TestTimeService(this.fixedToday);

  final DateTime fixedToday;

  @override
  Future<DateTime> today() async => fixedToday;
}
