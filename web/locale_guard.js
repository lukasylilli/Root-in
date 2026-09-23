// FILE: web/locale_guard.js
// PHASE: Start-Absturz bei ungültiger Browsersprache (2026-09-23; gleiche Datei wie vox/web/locale_guard.js)
//
// PROBLEM: Die Flutter-Web-Engine liest beim Start `navigator.languages` und
// baut für jeden Eintrag `new Intl.Locale(tag)`. Manche Browser melden aber
// Sprachen, die kein gültiges BCP-47 sind — z. B. Chromium unter Linux mit
// System-Locale „C"/„POSIX" meldet "en-US@posix". Dann wirft die Engine
// `RangeError: Incorrect locale information provided`, noch bevor irgendein
// Dart-Code läuft, und die App bleibt beim Ladekreis hängen.
//
// LÖSUNG: Dieses Skript läuft VOR flutter_bootstrap.js. Nur wenn der Browser
// mindestens eine ungültige Sprache meldet, ersetzt es `navigator.languages`
// und `navigator.language` durch eine bereinigte Liste:
//   "en-US@posix" → "en-US", "de_AT.UTF-8" → "de-AT", Unbrauchbares entfällt,
//   bleibt nichts übrig → ["en"].
// Bei gültigen Sprachen (jeder normale Browser) ändert es nichts.
//
// Welche Sprache Root-in zeigt, entscheidet weiterhin
// lib/core/l10n/app_language.dart (resolveLocale) — dieses Skript sorgt nur
// dafür, dass die Engine die Liste überhaupt lesen kann.
(function () {
  'use strict';
  if (typeof Intl === 'undefined' || typeof Intl.Locale !== 'function') return;

  function gueltig(tag) {
    if (typeof tag !== 'string' || tag.length === 0) return false;
    try { new Intl.Locale(tag); return true; } catch (e) { return false; }
  }

  function reparieren(tag) {
    if (gueltig(tag)) return tag;
    if (typeof tag !== 'string') return null;
    // POSIX-Form "sprache_REGION.zeichensatz@modifikator" → BCP 47
    var kern = tag.split('@')[0].split('.')[0].replace(/_/g, '-');
    return gueltig(kern) ? kern : null;
  }

  var nav = window.navigator;
  var roh = (nav.languages && nav.languages.length)
      ? Array.prototype.slice.call(nav.languages)
      : [nav.language];

  var allesGueltig = gueltig(nav.language);
  for (var i = 0; i < roh.length && allesGueltig; i++) {
    if (!gueltig(roh[i])) allesGueltig = false;
  }
  if (allesGueltig) return;

  var sauber = [];
  for (var j = 0; j < roh.length; j++) {
    var r = reparieren(roh[j]);
    if (r !== null && sauber.indexOf(r) < 0) sauber.push(r);
  }
  if (sauber.length === 0) sauber.push('en');
  var liste = Object.freeze(sauber);

  try {
    Object.defineProperty(nav, 'languages', {
      configurable: true, get: function () { return liste; }
    });
    Object.defineProperty(nav, 'language', {
      configurable: true, get: function () { return liste[0]; }
    });
  } catch (e) {
    // Lässt sich nicht überschreiben: nichts tun, Verhalten wie vorher.
  }
})();
