import 'package:flutter/material.dart';

/// Einzige Quelle für Farbwerte der App. Andere Dateien importieren diese
/// Klasse, statt Farbwerte erneut zu definieren.
abstract final class AppColors {
  static const Color seed = Color(0xFF2E7D5B);

  static const Color success = Color(0xFF2E7D5B);
  static const Color warning = Color(0xFFE0A82E);
  static const Color error = Color(0xFFD64545);
}
