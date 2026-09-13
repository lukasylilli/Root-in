import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// PLAN.md 31.5 — `tool/check_bundle_secrets.py` muss rot werden können.
///
/// Ruft **das echte Skript** auf, wie `privacy_page_test.dart`. Die Schlüssel
/// hier sind gefälscht: gültig aufgebaute JWTs mit erfundener Signatur — für
/// den Suchlauf zählt nur die Rolle in der Nutzlast.
///
/// ⚠️ Der wichtigste Fall ist der letzte: Ein Suchlauf, der nichts findet, ist
/// grün — auch wenn er blind ist. Mit `--expect-anon` muss das rot sein
/// (Lehre 32).
void main() {
  String part(Map<String, Object> json) =>
      base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');

  String jwt(String role) =>
      '${part({'alg': 'HS256', 'typ': 'JWT'})}.'
      '${part({'iss': 'supabase', 'role': role})}.'
      'gefaelschteSignatur123';

  Future<ProcessResult> scan(String bundle, {bool expectAnon = false}) async {
    final dir = await Directory.systemTemp.createTemp('root_in_bundle_');
    addTearDown(() => dir.delete(recursive: true));
    await File('${dir.path}/main.dart.js').writeAsString(bundle);
    return Process.run('python3', [
      'tool/check_bundle_secrets.py',
      dir.path,
      if (expectAnon) '--expect-anon',
    ]);
  }

  test('der erlaubte anon-Schlüssel ist grün', () async {
    final result = await scan('var a="${jwt('anon')}";', expectAnon: true);
    expect(result.exitCode, 0, reason: '${result.stdout}${result.stderr}');
  });

  test(
    '⚠️ ein service_role-Schlüssel ist rot — und wird nicht ausgegeben',
    () async {
      final secret = jwt('service_role');
      final result = await scan('var a="${jwt('anon')}";var b="$secret";');
      expect(result.exitCode, 1);
      expect('${result.stdout}', contains('service_role'));
      expect('${result.stdout}', isNot(contains(secret)));
    },
  );

  test('⚠️ ein sb_secret_-Schlüssel ist rot', () async {
    final result = await scan('var a="sb_secret_abcdefghijklmnop";');
    expect(result.exitCode, 1);
    expect('${result.stdout}', isNot(contains('abcdefghijklmnop')));
  });

  test(
    '⚠️ blinder Suchlauf: kein erlaubter Schlüssel, aber einer erwartet → rot',
    () async {
      final result = await scan('var nichts="";', expectAnon: true);
      expect(result.exitCode, 1);
    },
  );

  test('ohne Erwartung ist ein Bau ohne Schlüssel grün', () async {
    final result = await scan('var nichts="";');
    expect(result.exitCode, 0);
  });
}
