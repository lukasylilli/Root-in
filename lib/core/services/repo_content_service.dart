import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_service.dart';

/// Antwort eines Abrufs: HTTP-Status und — bei Erfolg — der Text.
typedef RepoFetchResult = ({int status, String? body});

/// Holt eine Adresse. Als Funktion herausgezogen, damit Tests den Netzzugriff
/// ersetzen können, ohne dass ein HTTP-Paket dazukommt (dieselbe Bauart wie
/// `time_service.dart`, das ebenfalls direkt `dart:io` nutzt).
typedef RepoFetcher = Future<RepoFetchResult> Function(Uri url);

/// Lädt Textdateien aus dem öffentlichen Inhalts-Repository und legt sie
/// lokal ab (siehe PLAN.md Phase 17.1 und 22).
///
/// **Einziger** Weg an Repository-Inhalte. Zwei Rubriken nutzen ihn: die
/// „Root-in Anleitung" (vier feste Themen je Sprache) und „موارد دیگر"
/// (Ordner und Texte, deren Struktur aus einer `index.json` kommt). Ein
/// zweiter Dienst daneben wäre genau die Doppelung, die PLAN.md Abschnitt 9
/// verbietet — beide brauchen dasselbe Zwischenspeichern, dieselbe
/// 404-Behandlung und dieselbe Nachlade-Regel.
///
/// Ablauf beim Öffnen einer Seite:
///
/// 1. Liegt ein gespeicherter Stand vor, wird **sofort** dieser angezeigt —
///    kein Ladekreis für Text, den das Gerät schon hat. Parallel läuft ein
///    Abruf; hat sich der Text geändert, meldet der Dienst das über
///    [onUpdated], und die Seite baut sich mit dem neuen Stand neu auf.
/// 2. Ohne gespeicherten Stand wird geladen (Ladekreis) und danach abgelegt.
/// 3. Ohne Netz und ohne gespeicherten Stand kommt eine Ausnahme — die Seite
///    zeigt dann ihren Fehler-Zustand mit „Erneut versuchen".
///
/// Antwortet der Server mit 404, gibt es die Datei (noch) nicht: Der Dienst
/// liefert `null`, die Seite zeigt „Inhalt folgt".
class RepoContentService {
  RepoContentService(this._prefs, {RepoFetcher? fetcher})
    : _fetch = fetcher ?? _download;

  final SharedPreferences _prefs;
  final RepoFetcher _fetch;

  /// Basis der Rohdateien im Repository. Einzige Stelle mit dieser Adresse.
  ///
  /// Bewusst `raw.githubusercontent.com` und **nicht** die GitHub-API: Die
  /// API könnte Ordner von selbst auflisten, erlaubt ohne Anmeldung aber nur
  /// 60 Abrufe pro Stunde und IP-Adresse — mehrere Nutzer hinter derselben
  /// Mobilfunk-Adresse sähen die Rubrik zeitweise leer (PLAN.md Phase 22).
  static const String baseUrl =
      'https://raw.githubusercontent.com/lukasylilli/Root-in/main/content';

  /// Länger warten lohnt nicht: Es gibt entweder einen gespeicherten Stand
  /// oder eine klare Fehlermeldung.
  static const Duration timeout = Duration(seconds: 8);

  /// Adresse einer Datei — [path] ist **relativ zu `content/`**, mit
  /// Dateiendung, z. B. `de/lernplanung.md` oder `others/fa/news/start.md`.
  static Uri urlFor(String path) => Uri.parse('$baseUrl/$path');

  /// Pfad einer Anleitungs-Seite. Die vier festen Themen liegen flach im
  /// Sprachordner; ihr Dateiname je Sprache steht in `GuideTopic`.
  static String guidePath(String fileName, String languageCode) =>
      '$languageCode/$fileName.md';

  String _cacheKey(String path) => 'repo_content_$path';

  /// Schlüssel, unter dem **Phase 17.1** die Anleitungs-Texte ablegte
  /// (`guide_md_<sprache>_<name>`). Mit Phase 22 heißt er anders, weil der
  /// Dienst nicht mehr nur Anleitungen lädt.
  ///
  /// Ohne diese Übernahme stünde ein Nutzer nach dem Update **offline vor
  /// einer leeren Anleitung** — der Text wäre noch da, nur unter einem Namen,
  /// den niemand mehr abfragt. Das ist zwar „nur" ein Zwischenspeicher, aber
  /// derselbe Gedanke wie in Phase 25: Ein Update darf nichts wegnehmen.
  ///
  /// Greift nur bei flachen Sprachpfaden (`de/lernplanung.md`); alles unter
  /// `others/` ist neu und hatte nie einen alten Schlüssel.
  static String? _legacyGuideKey(String path) {
    final parts = path.split('/');
    if (parts.length != 2 || !parts[1].endsWith('.md')) return null;
    final name = parts[1].substring(0, parts[1].length - 3);
    return 'guide_md_${parts[0]}_$name';
  }

  /// Lädt die Datei unter [path] (siehe Klassendoku). `null` = die Datei gibt
  /// es (noch) nicht. [onUpdated] meldet einen im Hintergrund geholten,
  /// **geänderten** Inhalt.
  Future<String?> load(String path, {void Function()? onUpdated}) async {
    final key = _cacheKey(path);
    var cached = _prefs.getString(key);

    // Einmalige Übernahme aus dem alten Schlüssel (siehe [_legacyGuideKey]).
    if (cached == null) {
      final legacyKey = _legacyGuideKey(path);
      final legacy = legacyKey == null ? null : _prefs.getString(legacyKey);
      if (legacy != null) {
        await _prefs.setString(key, legacy);
        await _prefs.remove(legacyKey!);
        cached = legacy;
      }
    }

    if (cached != null) {
      // Nicht abwarten: Der gespeicherte Stand geht sofort raus.
      _refreshInBackground(key, path, cached, onUpdated);
      return cached;
    }

    final result = await _fetch(urlFor(path));
    if (result.status == HttpStatus.notFound) return null;
    if (result.status != HttpStatus.ok || result.body == null) {
      throw HttpException('HTTP ${result.status}');
    }

    await _prefs.setString(key, result.body!);
    return result.body;
  }

  Future<void> _refreshInBackground(
    String key,
    String path,
    String cached,
    void Function()? onUpdated,
  ) async {
    try {
      final result = await _fetch(urlFor(path));
      if (result.status != HttpStatus.ok) return;

      final body = result.body;
      // Nur bei echter Änderung melden — sonst löst jede Aktualisierung den
      // nächsten Aufbau aus, der wieder aktualisiert (Endlosschleife).
      if (body == null || body == cached) return;

      await _prefs.setString(key, body);
      onUpdated?.call();
    } catch (_) {
      // Kein Netz: Der gespeicherte Stand steht schon auf dem Bildschirm.
    }
  }

  /// Gespeicherten Stand verwerfen — nötig, damit „Erneut versuchen" nach
  /// einem Fehlschlag wirklich neu lädt.
  Future<void> clearCache(String path) => _prefs.remove(_cacheKey(path));

  static Future<RepoFetchResult> _download(Uri url) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(url).timeout(timeout);
      final response = await request.close().timeout(timeout);
      if (response.statusCode != HttpStatus.ok) {
        return (status: response.statusCode, body: null);
      }
      final body = await response.transform(utf8.decoder).join().timeout(
        timeout,
      );
      return (status: HttpStatus.ok, body: body);
    } finally {
      client.close(force: true);
    }
  }
}

final repoContentServiceProvider = Provider<RepoContentService>((ref) {
  return RepoContentService(ref.watch(sharedPreferencesProvider));
});
