import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/date_utils.dart';

/// Liefert das aktuelle Datum. Versucht bei Internet-Verfügbarkeit eine
/// Online-Verifikation über den HTTP-Date-Header (Anti-Cheat gegen eine
/// manuell verstellte Geräteuhr bei Streaks); ohne Internet wird auf die
/// lokale Systemzeit zurückgefallen.
class TimeService {
  const TimeService();

  Future<DateTime> today() async {
    final verified = await _verifiedNow();
    return dateOnly(verified ?? DateTime.now());
  }

  Future<DateTime?> _verifiedNow() async {
    final client = HttpClient();
    try {
      final request = await client
          .headUrl(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 3));
      final response = await request.close().timeout(
        const Duration(seconds: 3),
      );
      final headerDate = response.headers.value(HttpHeaders.dateHeader);
      if (headerDate != null) {
        return HttpDate.parse(headerDate).toLocal();
      }
      return null;
    } catch (_) {
      return null; // kein Internet / Timeout – Offline-Fallback in today()
    } finally {
      client.close(force: true);
    }
  }
}

final timeServiceProvider = Provider<TimeService>((ref) => const TimeService());
