import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';

/// Einziger „Text eingeben"-Dialog der App (z. B. Kategorie anlegen/
/// umbenennen). Verwaltet den `TextEditingController` über den eigenen
/// State-Lifecycle — ein extern per `Future`-Completion entsorgter
/// Controller würde abstürzen, solange die Schließen-Animation des Dialogs
/// noch läuft und das `TextField` noch im Baum steht.
class TextPromptDialog extends StatefulWidget {
  const TextPromptDialog({
    super.key,
    required this.title,
    this.initialValue = '',
    this.confirmLabel,
  });

  final String title;
  final String initialValue;

  /// Beschriftung des Bestätigen-Buttons; `null` = „Speichern" in der
  /// aktuellen Sprache (als Default-Wert nicht möglich, weil der Text erst
  /// mit einem `BuildContext` feststeht).
  final String? confirmLabel;

  @override
  State<TextPromptDialog> createState() => _TextPromptDialogState();
}

class _TextPromptDialogState extends State<TextPromptDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(labelText: l10n.fieldName),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: Text(widget.confirmLabel ?? l10n.actionSave),
        ),
      ],
    );
  }
}
