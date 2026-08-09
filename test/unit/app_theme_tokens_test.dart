import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/core/theme/app_theme_variant.dart';

void main() {
  test('jede Variante liefert Tokens für beide Helligkeiten', () {
    for (final variant in AppThemeVariant.values) {
      final dark = variant.tokens(Brightness.dark);
      final light = variant.tokens(Brightness.light);

      // Akzent ist die Seed-Farbe, über beide Helligkeiten gleich.
      expect(dark.accent, variant.seedColor);
      expect(light.accent, variant.seedColor);
      // Flächen unterscheiden sich zwischen hell und dunkel.
      expect(dark.screenBg, isNot(light.screenBg));
      expect(dark.cardBg, isNot(light.cardBg));
    }
  });

  test('heat(): 0 ergibt den Ring-Track, 1 den vollen Akzent', () {
    final tokens = AppThemeVariant.blue.tokens(Brightness.dark);

    expect(tokens.heat(0), tokens.ringTrack);
    expect(tokens.heat(1), tokens.accent);
    // Ein Mittelwert liegt dazwischen (weder Track noch voller Akzent).
    final mid = tokens.heat(0.5);
    expect(mid, isNot(tokens.ringTrack));
    expect(mid, isNot(tokens.accent));
  });

  test('heat() begrenzt Werte außerhalb 0..1', () {
    final tokens = AppThemeVariant.green.tokens(Brightness.light);
    expect(tokens.heat(-1), tokens.ringTrack);
    expect(tokens.heat(5), tokens.accent);
  });
}
