import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../services/page_reload/reload_page.dart';

/// Ersetzt die **graue Fläche**, die Flutter in der veröffentlichten Fassung
/// zeigt, wenn beim Aufbau einer Seite ein Fehler passiert (PLAN.md 31.7).
///
/// Warum: Ein Nutzer meldete 2026-09-26 eine Root-in-Seite, die nur grau
/// blieb — und nichts sonst. Grau ist Flutters Ersatz für den roten
/// Fehlerbildschirm der Entwicklerfassung; er verrät weder dem Nutzer, was
/// los ist, noch uns, **welcher** Fehler es war. Diese Ansicht sagt es in
/// allen drei App-Sprachen, zeigt den Fehlertext (für ein Bildschirmfoto an
/// Lukas) und bietet „Neu laden\" an.
///
/// ⚠️ Nur in der veröffentlichten Fassung (`kReleaseMode`): In der
/// Entwicklerfassung und in den Tests bleibt Flutters roter Bildschirm mit
/// dem vollen Stapel — der ist dort ausführlicher.
void installAppErrorView() {
  if (!kReleaseMode) return;
  ErrorWidget.builder = (details) => AppErrorView(details: details);
}

/// Die Fehlerseite selbst.
///
/// ⚠️ Darf sich auf **nichts** aus der App stützen — kein Theme, keine
/// Übersetzungen, kein `MediaQuery`, kein Material: Sie erscheint genau dann,
/// wenn irgendwo darüber etwas kaputt ist, womöglich die App selbst. Daher
/// eigene Richtung, eigene Farben, feste Texte.
class AppErrorView extends StatelessWidget {
  const AppErrorView({super.key, required this.details});

  final FlutterErrorDetails details;

  /// Unterhalb dieser Größe ist der Fehler in einem **Teil** der Seite
  /// passiert (eine Kachel, eine Zeile). Dort passt keine Erklärung hinein;
  /// dann bleibt es bei Flutters schlichter Fehlerfläche, und die übrige
  /// Seite bleibt benutzbar.
  static const double minWidth = 260;
  static const double minHeight = 320;

  static const Color _background = Color(0xFF2E7D5B); // wie web/index.html
  static const Color _foreground = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final roomForExplanation = box.hasBoundedWidth &&
            box.hasBoundedHeight &&
            box.maxWidth >= minWidth &&
            box.maxHeight >= minHeight;
        if (!roomForExplanation) {
          return ErrorWidget.withDetails(message: details.exceptionAsString());
        }
        return _explanation();
      },
    );
  }

  Widget _explanation() {
    final message = details.exceptionAsString();
    final shortMessage =
        message.length > 300 ? '${message.substring(0, 300)} …' : message;

    return ColoredBox(
      color: _background,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _line('مشکلی پیش آمد. لطفاً صفحه را دوباره باز کنید.',
                  TextDirection.rtl, 17),
              const SizedBox(height: 8),
              _line('Etwas ist schiefgelaufen. Bitte die Seite neu laden.',
                  TextDirection.ltr, 15),
              const SizedBox(height: 4),
              _line('Something went wrong. Please reload the page.',
                  TextDirection.ltr, 15),
              const SizedBox(height: 24),
              GestureDetector(
                key: const Key('app-error-reload'),
                behavior: HitTestBehavior.opaque,
                onTap: reloadPage,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: _foreground,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      'بارگذاری دوباره · Neu laden · Reload',
                      style: TextStyle(
                        color: _background,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _line(shortMessage, TextDirection.ltr, 11, maxLines: 6),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _line(
    String text,
    TextDirection direction,
    double size, {
    int maxLines = 3,
  }) {
    return Directionality(
      textDirection: direction,
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: _foreground,
          fontSize: size,
          height: 1.4,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}
