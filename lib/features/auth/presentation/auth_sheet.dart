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
///
/// Mit [usernameOnly] fragt das Sheet **nur nach dem Benutzernamen** — für ein
/// Konto, das schon besteht, aber keinen Namen hat (PLAN.md 31.1). Derselbe
/// Zustand kann mitten in der Registrierung entstehen; dann schaltet das
/// Sheet von selbst dorthin um.
Future<void> showAuthSheet(BuildContext context, {bool usernameOnly = false}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _AuthSheet(usernameOnly: usernameOnly),
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
String usernameIssueText(
  UsernameIssue issue,
  AppLocalizations l10n,
) => switch (issue) {
  UsernameIssue.empty => l10n.usernameErrorEmpty,
  UsernameIssue.tooShort => l10n.usernameErrorTooShort(UsernameRules.minLength),
  UsernameIssue.tooLong => l10n.usernameErrorTooLong(UsernameRules.maxLength),
  UsernameIssue.invalidCharacters => l10n.usernameErrorInvalidChars,
};

class _AuthSheet extends ConsumerStatefulWidget {
  const _AuthSheet({required this.usernameOnly});

  final bool usernameOnly;

  @override
  ConsumerState<_AuthSheet> createState() => _AuthSheetState();
}

class _AuthSheetState extends ConsumerState<_AuthSheet> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _username = TextEditingController();

  bool _registering = false;

  /// Das Konto besteht, nur der Benutzername fehlt (PLAN.md 31.1).
  late bool _usernameOnly = widget.usernameOnly;

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
    final asksForUsername = _registering || _usernameOnly;

    // Den Benutzernamen prüfen, BEVOR ein Konto entsteht: Sonst legt eine
    // ungültige Eingabe erst das Konto an und scheitert dann am Namen.
    if (asksForUsername) {
      final issue = UsernameRules.validate(_username.text);
      if (issue != null) {
        setState(() => _error = usernameIssueText(issue, l10n));
        return;
      }
    }
    final username = UsernameRules.normalize(_username.text);

    setState(() {
      _busy = true;
      _error = null;
    });

    final AuthResult result;
    if (_usernameOnly) {
      result = await service.claimUsername(username);
    } else if (_registering) {
      // Vorab fragen, ob der Name frei ist (PLAN.md 31.1). Das ist nur
      // Höflichkeit — die Wahrheit ist der eindeutige Index in der Datenbank,
      // und der Fehlschlag danach wird unten trotzdem behandelt. Aber im
      // Normalfall entsteht so gar nicht erst ein Konto ohne Namen.
      if (!await service.isUsernameAvailable(username)) {
        if (!mounted) return;
        setState(() {
          _busy = false;
          _error = l10n.authErrorUsernameTaken;
        });
        return;
      }
      result = await service.signUp(
        email: _email.text,
        password: _password.text,
        username: username,
      );
    } else {
      result = await service.signIn(
        email: _email.text,
        password: _password.text,
      );
    }

    if (!mounted) return;

    if (result.isSuccess) {
      // ⚠️ Die Anmeldung kann sich melden, BEVOR die Profilzeile geschrieben
      // ist — die Konto-Seite hätte dann schon „kein Name" geladen.
      ref.invalidate(accountUsernameProvider);
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _busy = false;
      _error = authIssueText(result.issue!, l10n);
      // ⚠️ Steht das Konto trotz Fehlschlag, fehlt nur noch der Name: Jemand
      // war zwischen Vorab-Frage und Schreiben schneller, oder die Verbindung
      // brach genau dazwischen ab. Ein zweiter Versuch mit dem ganzen
      // Formular scheiterte an „E-Mail schon registriert" — aus diesem
      // Zustand käme der Nutzer nicht mehr heraus. Das Konto wird dabei
      // NICHT gelöscht; sein Passwort ist gesetzt, nur der Name fehlt.
      if (_registering && service.currentAccount != null) {
        _usernameOnly = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

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
            if (_usernameOnly)
              Text(l10n.authPickUsernameBody, style: theme.textTheme.bodyMedium)
            else ...[
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
            ],
            if (_registering || _usernameOnly) ...[
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _username,
                enabled: !_busy,
                autocorrect: false,
                decoration: InputDecoration(labelText: l10n.fieldUsername),
              ),
            ],
            if (_registering && !_usernameOnly) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(l10n.cloudEmailHint, style: theme.textTheme.bodySmall),
            ],
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
            ],
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: _usernameOnly
                  ? l10n.authSaveUsername
                  : _registering
                  ? l10n.cloudRegister
                  : l10n.cloudSignIn,
              onPressed: _busy ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
