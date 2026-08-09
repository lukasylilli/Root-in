import 'package:flutter/material.dart';

import 'app_fonts.dart';

/// Einzige Quelle für Text-Styles der App. Andere Dateien importieren diese
/// Klasse, statt Text-Styles erneut zu definieren. Alle Styles nutzen
/// [AppFonts.primaryFontFamily] — ein Font-Wechsel dort betrifft automatisch
/// jeden Text in der App.
abstract final class AppTextStyles {
  static const TextStyle headline = TextStyle(
    fontFamily: AppFonts.primaryFontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle title = TextStyle(
    fontFamily: AppFonts.primaryFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle body = TextStyle(
    fontFamily: AppFonts.primaryFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: AppFonts.primaryFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );
}
