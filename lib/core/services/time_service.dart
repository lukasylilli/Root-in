import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../utils/date_utils.dart';
import '../utils/platform_support.dart';

/// Liefert das aktuelle Datum. Versucht bei Internet-Verfügbarkeit eine
/// Online-Verifikation über den HTTP-Date-Header (Anti-Cheat gegen eine
/// manuell verstellte Geräteuhr bei Streaks); ohne Internet wird auf die
/// lokale Systemzeit zurückgefallen.
///
/// ⚠️ **Kein `dart:io` hier** (PLAN.md Phase 26.11, Lehre 30). `HttpClient`
/// übersetzt für den Browser zwar anstandslos, wirft dort aber schon beim
/// Erzeugen `UnsupportedError` — und weil das *vor* dem `try` geschah, riss
/// es den ganzen Datums-Provider mit sich: Heute- und Ansicht-Seite blieben
/// in der veröffentlichten Web-Fassung leer.
class TimeService {
  const TimeService();

  /// Länger warten lohnt nicht — es gibt einen brauchbaren Ersatz (die
  /// Geräteuhr), und die App wartet in dieser Zeit auf ihr Datum.
  static const Duration timeout = Duration(seconds: 3);

  Future<DateTime> today() async {
    final verified = await _verifiedNow();
    return dateOnly(verified ?? DateTime.now());
  }

  /// Adresse, deren `Date`-Kopfzeile die Uhr prüft.
  ///
  /// Auf Android/iOS eine beliebige fremde Adresse. Im Browser **die eigene**:
  /// Fremde Kopfzeilen sind dort nicht lesbar (siehe
  /// [canReadForeignResponseHeaders]), die eigene Herkunft dagegen vollständig.
  /// Damit bleibt die Prüfung auch in der Web-Fassung erhalten, statt still zu
  /// entfallen — der Verlauf soll überall gleich schwer zu fälschen sein.
  ///
  /// Der Zeitstempel in der Adresse ist **kein Schmuck**: Ohne ihn dürfte der
  /// Browser eine gespeicherte Antwort ausliefern, und deren `Date` ist die
  /// Uhrzeit von damals. Ein alter Wert wäre hier schlimmer als gar keiner —
  /// er sähe geprüft aus und zeigte womöglich den Vortag.
  static Uri _clockUrl() {
    if (canReadForeignResponseHeaders) {
      return Uri.parse('https://www.google.com');
    }
    return Uri.base.replace(
      queryParameters: {
        ...Uri.base.queryParameters,
        '_': DateTime.now().millisecondsSinceEpoch.toString(),
      },
      fragment: '',
    );
  }

  Future<DateTime?> _verifiedNow() async {
    try {
      final response = await http.head(_clockUrl()).timeout(timeout);
      final headerDate = response.headers['date'];
      if (headerDate == null) return null;
      return parseHttpDate(headerDate).toLocal();
    } catch (_) {
      return null; // kein Internet / Timeout – Offline-Fallback in today()
    }
  }
}

final timeServiceProvider = Provider<TimeService>((ref) => const TimeService());
