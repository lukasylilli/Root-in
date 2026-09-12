import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// PLAN.md 29.5 — die Datenschutzerklärung wird **mit der App veröffentlicht**.
///
/// **Warum das einen Test braucht:** Der frühere Weg lief über einen von Hand
/// gepflegten GitHub-Gist und war **zweimal veraltet** (nach Phase 20 und nach
/// 27.8). Die Ursache war nie Nachlässigkeit, sondern die zweite Kopie. Jetzt
/// gibt es nur noch eine Quelle — und dieser Test hält fest, dass der Weg von
/// der Quelle zur Seite wirklich funktioniert.
///
/// ⚠️ Der Test ruft **das echte Skript** auf, nicht eine Nachbildung seiner
/// Logik. Ein Test, der die Umwandlung noch einmal selbst schreibt, prüft
/// seine eigene Kopie und geht mit ihr gemeinsam kaputt.
///
/// ⚠️ Er ist eine der wenigen Stellen im Projekt, die `dart:io` benutzen
/// dürfen: Er läuft nur auf der Test-VM und wird nie für den Browser
/// übersetzt. `no_dart_io_in_lib_test.dart` bewacht `lib/`, nicht `test/`.
void main() {
  late final String seite;

  setUpAll(() {
    final ziel = '${Directory.systemTemp.path}/root_in_privacy_test.html';
    final lauf = Process.runSync(
      'python3',
      ['tool/build_privacy_page.py', ziel],
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );
    expect(
      lauf.exitCode,
      0,
      reason: 'tool/build_privacy_page.py scheiterte: ${lauf.stderr}',
    );
    seite = File(ziel).readAsStringSync();
  });

  test('die tragenden Abschnitte stehen wirklich auf der Seite', () {
    // Stichproben quer durch BEIDE Sprachfassungen. Fehlt eine, hat die
    // Umwandlung einen ganzen Block verschluckt — das fiele sonst erst einem
    // Nutzer auf, der etwas nachlesen will.
    for (final teil in [
      'Datenschutzerklärung',
      'Konto und Sicherung auf dem Server',
      'Wo deine Daten im Browser liegen',
      'Deine Rechte',
      'Privacy Policy',
      'Where your data lives in the browser',
      'Your rights',
    ]) {
      expect(seite, contains(teil), reason: 'Abschnitt fehlt: $teil');
    }
  });

  test('⚠️ die INTERNE NOTIZ wird nicht mitveröffentlicht', () {
    // Am Ende der Markdown-Datei steht ein HTML-Kommentar mit Notizen, die
    // niemanden außerhalb des Projekts etwas angehen (Gist-Adresse,
    // Änderungsprotokoll, Phasen-Nummern). Der Wandler schneidet ihn ab.
    // Verlässt man sich stattdessen darauf, dass ein Browser Kommentare
    // versteckt, steht der Text trotzdem im Quelltext der Seite.
    expect(seite, isNot(contains('INTERNE NOTIZ')));
    expect(seite, isNot(contains('gist.github.com')));
    expect(seite, isNot(contains('PLAN.md')));
  });

  test('es ist eine vollständige, eigenständige Seite', () {
    // Kein externes Stylesheet, keine Schriftart von einem fremden Server:
    // Die Seite muss auch dann lesbar sein, wenn sonst nichts erreichbar ist.
    expect(seite, startsWith('<!DOCTYPE html>'));
    expect(seite.trimRight(), endsWith('</html>'));
    expect(seite, contains('<style>'));
    expect(seite, isNot(contains('<link rel="stylesheet"')));
    expect(seite, isNot(contains('<script')));
  });

  test('Tabellen und Auszeichnungen sind umgewandelt, nicht durchgereicht', () {
    // Der Test, der die Umwandlung wirklich misst: Bliebe Markdown stehen,
    // stünden Sternchen und Striche im Text.
    expect(seite, contains('<table>'));
    expect(seite, contains('<strong>'));
    expect(seite, contains('<h3>'));
    // Nirgends darf rohes Markdown übrig sein.
    expect(seite, isNot(contains('**')));
    expect(seite, isNot(contains('|---')));
  });
}
