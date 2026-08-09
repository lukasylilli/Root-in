/// Einzige Quelle der öffentlichen Links der App (siehe PLAN.md Phase 19).
///
/// Kein anderer Ort baut eine Store-Adresse zusammen: die Fortschritts-Karte
/// (QR-Code), der Begleittext des Share-Sheets und „App teilen" in den
/// Einstellungen lesen alle hier. Ändert sich die Adresse, ändert sie sich an
/// einer Stelle.
library;

/// Paketname der App — nach der Veröffentlichung unveränderlich. Muss zur
/// `applicationId` in `android/app/build.gradle.kts` passen.
const String appPackageName = 'com.rootin.app';

/// Play-Store-Seite der App.
///
/// Die Adresse ergibt sich allein aus [appPackageName] und steht damit schon
/// vor der Veröffentlichung fest; gültig wird sie, sobald die App in der
/// Produktion ist (PLAN.md Phase 15.6). Vorher führt sie auf eine
/// „nicht gefunden"-Seite von Google — das ist gewollt, ein Platzhalter-Link
/// müsste sonst später in jedem geteilten Bild nachgezogen werden.
const String playStoreUrl =
    'https://play.google.com/store/apps/details?id=$appPackageName';
