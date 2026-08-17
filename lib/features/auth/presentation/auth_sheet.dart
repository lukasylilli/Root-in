import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/username_rules.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../l10n/gen/app_localizations.dart';

/// **Einziger** Weg zur Anmeldung in der App (PLAN.md Phase 27.5) — dasselbe
/// Muster wie `showShareProgressSheet()`: eine Funktion, ein Sheet, kein
/// zweiter Einstieg, der auseinanderlaufen kann.
///
/// Anmelden und Registrieren liegen bewusst **in einem** Sheet: Es ist
/// derselbe Vorgang aus Sicht des Nutzers („ich will an mein Konto"), und
/// zwei Seiten mit fast gleichem Formular wären zwei Stellen für jede
/// spätere Änderung.
Future<void> showAuthSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _AuthSheet(),
  );
}

/// Übersetzt einen sprachneutralen Grund aus `auth_service.dart`.
///
/// ⚠️ Die Zuordnung steht **hier**, nicht im Dienst: Der Dienst kennt keine
/// Sprache, die Oberfläche kennt keine Server-Codes. Wer das vermischt,
/// braucht `BuildContext` in einem Dienst — und kann ihn nicht mehr testen.
String authIssueText(AuthIssue issue, AppLocalizations l10n) => switch (issue) {
  AuthIssue.emailTaken => l10n.authErrorEmailTaken,
  AuthIssue.usernameTaken => l10n.authErrorUsernameTaken,
  AuthIssue.invalidCredentials => l10n.authErrorInvalidCredentials,
  AuthIssue.weakPassword => l10n.authErrorWeakPassword,
  AuthIssue.invalidEmail => l10n.authErrorInvalidEmail,
  AuthIssue.signupDisabled => l10n.authErrorSignupDisabled,
  AuthIssue.emailRateLimited => l10n.authErrorRateLimited,
  AuthIssue.offline => l10n.authErrorOffline,
  // `notConfigured` darf den Nutzer nie erreichen — ohne Server ist die
  // ganze Rubrik unsichtbar. Kommt es doch vor, ist es ein Fehler von uns
  // und keiner, den der Nutzer beheben kann.
  AuthIssue.notConfigured || AuthIssue.unknown => l10n.authErrorUnknown,
};

/// Übersetzt einen Grund aus `username_rules.dart`.
String usernameIssueText(UsernameIssue issue, AppLocalizations l10n) =>
    switch (issue) {
      UsernameIssue.empty => l10n.usernameErrorEmpty,
      UsernameIssue.tooShort =>
        l10n.usernameErrorTooShort(UsernameRules.minLength),
      UsernameIssue.tooLong =>
        l10n.usernameErrorTooLong(UsernameRules.maxLength),
      UsernameIssue.invalidCharacters => l10n.usernameErrorInvalidChars,
    };

class _AuthSheet extends ConsumerStatefulWidget {
  const _AuthSheet();

  @override
  ConsumerState<_AuthSheet> createState() => _AuthSheetState();
}

class _AuthSheetState extends ConsumerState<_AuthSheet> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _username = TextEditingController();

  bool _registering = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _username.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final service = ref.read(authServiceProvider);

    // Den Benutzernamen prüfen, BEVOR ein Konto entsteht: Sonst legt eine
    // ungültige Eingabe erst das Konto an und scheitert dann am Namen.
    if (_registering) {
      final issue = UsernameRules.validate(_username.text);
      if (issue != null) {
        setState(() => _error = usernameIssueText(issue, l10n));
        return;
      }
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    final result = _registering
        ? await service.signUp(
            email: _email.text,
            password: _password.text,
            username: UsernameRules.normalize(_username.text),
          )
        : await service.signIn(email: _email.text, password: _password.text);

    if (!mounted) return;

    if (result.isSuccess) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _busy = false;
      _error = authIssueText(result.issue!, l10n);
      // Beim belegten Namen bleibt das Konto bestehen — nur der Name fehlt
      // noch (PLAN.md 27.5). Der Nutzer soll genau das ändern können, ohne
      // von vorn anzufangen, deshalb bleibt das Formular stehen.
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        // Ohne diesen Wert verdeckt die Tastatur die Felder.
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.md,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: false, label: Text(l10n.cloudSignIn)),
                ButtonSegment(value: true, label: Text(l10n.cloudRegister)),
              ],
              selected: {_registering},
              onSelectionChanged: _busy
                  ? null
                  : (value) => setState(() {
                      _registering = value.first;
                      _error = null;
                    }),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _email,
              enabled: !_busy,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: InputDecoration(labelText: l10n.fieldEmail),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _password,
              enabled: !_busy,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.fieldPassword),
            ),
            if (_registering) ...[
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _username,
                enabled: !_busy,
                autocorrect: false,
                decoration: InputDecoration(labelText: l10n.fieldUsername),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.cloudEmailHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: _registering ? l10n.cloudRegister : l10n.cloudSignIn,
              onPressed: _busy ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
