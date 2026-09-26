import 'package:flutter/material.dart';

/// Einzige Quelle für die Farben der Berg-Szene auf der Home-Seite (siehe
/// PLAN.md Phase 33). Die Werte sind 1:1 aus der Nutzer-Vorlage
/// `mountain_progress_ios.html` übernommen (CSS-Variablen `--bg`, `--blob-*`,
/// `--peak-*`, `--rim`, `--trail`, `--warm-top`, `--glass-*`, `--blue`,
/// `--green`) — je eine Fassung für hell und dunkel. Painter und Widget
/// lesen nur von hier; Farbwerte der Szene stehen an keiner anderen Stelle.
@immutable
class AscentScenePalette {
  const AscentScenePalette._({
    required this.background,
    required this.label,
    required this.secondaryLabel,
    required this.blob1,
    required this.blob2,
    required this.blob3,
    required this.peakTop,
    required this.peakBottom,
    required this.rim,
    required this.trail,
    required this.warmTop,
    required this.glassStrong,
    required this.glassRim,
    required this.accent,
    required this.complete,
    required this.shadow,
  });

  /// Grundfläche hinter der Szene (`--bg`).
  final Color background;

  /// Haupttext (`--label`) und Nebentext (`--label-2`).
  final Color label;
  final Color secondaryLabel;

  /// Die drei weichgezeichneten Farbflecken im Hintergrund (`--blob-1..3`).
  final Color blob1;
  final Color blob2;
  final Color blob3;

  /// Verlauf des gläsernen Bergs (`--peak-top` → `--peak-bottom`).
  final Color peakTop;
  final Color peakBottom;

  /// Lichtkante auf dem Grat (`--rim`).
  final Color rim;

  /// Ganzer Pfad, gedämpft (`--trail`).
  final Color trail;

  /// Warmer Schein, der mit dem Fortschritt kommt (`--warm-top`).
  final Color warmTop;

  /// Glas-Perlen: Füllung (`--glass-strong`) und Rand (`--glass-rim`).
  final Color glassStrong;
  final Color glassRim;

  /// Farbe des zurückgelegten Wegs (`--blue`) und bei 100 % (`--green`).
  final Color accent;
  final Color complete;

  /// Schatten der Karte (`--glass-shadow`, erste Ebene).
  final Color shadow;

  static const AscentScenePalette light = AscentScenePalette._(
    background: Color(0xFFEEF2F8),
    label: Color(0xFF000000),
    secondaryLabel: Color(0x993C3C43),
    blob1: Color(0xFF8EC5FF),
    blob2: Color(0xFFB9B3FF),
    blob3: Color(0xFF9FE7F0),
    peakTop: Color(0x9EFFFFFF),
    peakBottom: Color(0x24FFFFFF),
    rim: Color(0xF2FFFFFF),
    trail: Color(0xE6FFFFFF),
    warmTop: Color(0xBFFFBE82),
    glassStrong: Color(0x99FFFFFF),
    glassRim: Color(0xF2FFFFFF),
    accent: Color(0xFF007AFF),
    complete: Color(0xFF34C759),
    shadow: Color(0x1A142850),
  );

  static const AscentScenePalette dark = AscentScenePalette._(
    background: Color(0xFF05070D),
    label: Color(0xFFFFFFFF),
    secondaryLabel: Color(0x99EBEBF5),
    blob1: Color(0xFF1C4F9C),
    blob2: Color(0xFF3B2F86),
    blob3: Color(0xFF10596A),
    peakTop: Color(0x29FFFFFF),
    peakBottom: Color(0x05FFFFFF),
    rim: Color(0x66FFFFFF),
    trail: Color(0x47FFFFFF),
    warmTop: Color(0x59FF8C50),
    glassStrong: Color(0x1FFFFFFF),
    glassRim: Color(0x47FFFFFF),
    accent: Color(0xFF0A84FF),
    complete: Color(0xFF30D158),
    shadow: Color(0x80000000),
  );

  /// Folgt dem Darstellungsmodus der App (hell/dunkel/System), den der
  /// Nutzer in den Einstellungen wählt.
  static AscentScenePalette of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  /// Farbe des Wegs — grün, sobald der Gipfel erreicht ist.
  Color progressColor({required bool atSummit}) => atSummit ? complete : accent;
}
