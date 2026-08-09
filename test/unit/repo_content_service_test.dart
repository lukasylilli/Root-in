import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/core/services/repo_content_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> _prefs() async {
  SharedPreferences.setMockInitialValues({});
  return SharedPreferences.getInstance();
}

/// Sammelt die aufgerufenen Adressen und antwortet nach Drehbuch.
class _FakeServer {
  _FakeServer(this.responses);

  final List<RepoFetchResult> responses;
  final List<Uri> calls = [];

  Future<RepoFetchResult> fetch(Uri url) async {
    calls.add(url);
    if (responses.isEmpty) throw const SocketException('kein Netz');
    return responses.removeAt(0);
  }
}

void main() {
  test('lädt den Text und legt ihn ab', () async {
    final prefs = await _prefs();
    final server = _FakeServer([(status: 200, body: '# Lernplanung')]);
    final service = RepoContentService(prefs, fetcher: server.fetch);

    expect(await service.load('de/lernplanung.md'), '# Lernplanung');
    expect(
      server.calls.single.toString(),
      endsWith('/content/de/lernplanung.md'),
    );
    // Zweiter Aufruf kommt aus dem Speicher, nicht vom Server.
    expect(prefs.getString('repo_content_de/lernplanung.md'), '# Lernplanung');
  });

  test('zeigt ohne Netz den gespeicherten Stand', () async {
    final prefs = await _prefs();
    final server = _FakeServer([(status: 200, body: 'gespeichert')]);
    final service = RepoContentService(prefs, fetcher: server.fetch);
    await service.load('de/lernplanung.md');

    // Ab jetzt antwortet der Server gar nicht mehr.
    expect(await service.load('de/lernplanung.md'), 'gespeichert');
  });

  test('ohne Netz und ohne gespeicherten Stand wirft es', () async {
    final prefs = await _prefs();
    final service = RepoContentService(
      prefs,
      fetcher: _FakeServer(const []).fetch,
    );

    expect(
      () => service.load('de/lernplanung.md'),
      throwsA(isA<SocketException>()),
    );
  });

  test('404 heißt: Seite gibt es in dieser Sprache noch nicht', () async {
    final prefs = await _prefs();
    final service = RepoContentService(
      prefs,
      fetcher: _FakeServer([(status: 404, body: null)]).fetch,
    );

    expect(await service.load('fa/lernquellen.md'), isNull);
    expect(prefs.getString('repo_content_fa/lernquellen.md'), isNull);
  });

  test('geänderter Text im Hintergrund meldet sich genau einmal', () async {
    final prefs = await _prefs();
    final server = _FakeServer([
      (status: 200, body: 'alt'),
      (status: 200, body: 'neu'),
      (status: 200, body: 'neu'),
    ]);
    final service = RepoContentService(prefs, fetcher: server.fetch);
    await service.load('de/lernplanung.md');

    var updates = 0;
    // Zweiter Aufruf: liefert „alt" aus dem Speicher und holt „neu" nach.
    expect(
      await service.load('de/lernplanung.md', onUpdated: () => updates++),
      'alt',
    );
    await Future<void>.delayed(Duration.zero);
    expect(updates, 1);
    expect(prefs.getString('repo_content_de/lernplanung.md'), 'neu');

    // Dritter Aufruf: unverändert → keine weitere Meldung, sonst liefe die
    // Seite in eine Endlosschleife aus Aktualisieren und Neuaufbau.
    expect(
      await service.load('de/lernplanung.md', onUpdated: () => updates++),
      'neu',
    );
    await Future<void>.delayed(Duration.zero);
    expect(updates, 1);
  });

  test('je Sprache ein eigener Speicherplatz', () async {
    final prefs = await _prefs();
    final server = _FakeServer([
      (status: 200, body: 'deutsch'),
      (status: 200, body: 'فارسی'),
    ]);
    final service = RepoContentService(prefs, fetcher: server.fetch);

    expect(await service.load('de/lernplanung.md'), 'deutsch');
    expect(await service.load('fa/lernplanung.md'), 'فارسی');
    expect(prefs.getString('repo_content_de/lernplanung.md'), 'deutsch');
    expect(prefs.getString('repo_content_fa/lernplanung.md'), 'فارسی');
  });

  test('übernimmt den Zwischenspeicher aus der Zeit vor Phase 22', () async {
    // Bis Phase 17.1 lagen die Anleitungen unter `guide_md_<sprache>_<name>`.
    // Ohne Übernahme stünde ein Nutzer nach dem Update **offline vor einer
    // leeren Anleitung** — der Text wäre noch da, nur unter einem Namen, den
    // niemand mehr abfragt.
    SharedPreferences.setMockInitialValues({
      'guide_md_de_lernplanung': 'alter Stand',
    });
    final prefs = await SharedPreferences.getInstance();
    // Kein Netz: Was jetzt kommt, kann nur aus dem Speicher stammen.
    final service = RepoContentService(
      prefs,
      fetcher: _FakeServer(const []).fetch,
    );

    expect(await service.load('de/lernplanung.md'), 'alter Stand');
    expect(prefs.getString('repo_content_de/lernplanung.md'), 'alter Stand');
    // Der alte Schlüssel wird dabei geräumt, damit es nicht zweimal liegt.
    expect(prefs.getString('guide_md_de_lernplanung'), isNull);
  });

  test('neue Pfade haben keinen alten Schlüssel', () async {
    // `others/...` gibt es erst seit Phase 22 — hier darf nichts „übernommen"
    // werden, sonst würde ein zufällig passender Prefs-Eintrag Inhalte
    // vortäuschen.
    final prefs = await _prefs();
    final service = RepoContentService(
      prefs,
      fetcher: _FakeServer(const []).fetch,
    );

    expect(
      () => service.load('others/fa/news/start.md'),
      throwsA(isA<SocketException>()),
    );
  });
}
