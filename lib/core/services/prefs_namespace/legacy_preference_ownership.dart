import 'dart:convert';

/// Gehört der alte Eintrag `flutter.<name>` mit dem gespeicherten Rohwert
/// [raw] zu Root-in? (PLAN.md 31.8)
///
/// `shared_preferences` legt im Browser jeden Wert als JSON ab (`"dark"`,
/// `true`, `2`, `["a","b"]`). Entschieden wird nach **Name und Art des
/// Werts** — der Name allein reicht nicht: `theme_mode` benutzt auch Vox,
/// dort als Zahl. Ein Eintrag, der nach Name zu Root-in passt, aber die
/// falsche Art hat, gehört jemand anderem und bleibt, wo er ist.
///
/// ⚠️ Die Liste muss alle Schlüssel enthalten, die Root-in **vor** 31.8
/// geschrieben hat. Neue Schlüssel gehören NICHT hierher — sie entstehen
/// ohnehin im eigenen Namensraum.
bool isRootInLegacyEntry(String name, String raw) {
  const textKeys = {
    'theme_mode',
    'theme_variant',
    'ascent_source',
    'app_language',
    'profile_name',
  };
  const flagKeys = {
    'onboarding_seen',
    'share_include_overview',
    'web_storage_hint_seen',
    'remove_ads_purchased',
  };

  final Object? value;
  try {
    value = jsonDecode(raw);
  } on FormatException {
    return false;
  }

  if (textKeys.contains(name)) return value is String;
  if (flagKeys.contains(name)) return value is bool;
  if (name.startsWith('repo_content_') || name.startsWith('guide_md_')) {
    return value is String;
  }
  if (name.startsWith('dashboard_layout_')) return value is List;
  return false;
}
