import 'dart:io';

import 'package:flutter_file_dialog/flutter_file_dialog.dart';

/// Android/iOS-Fassung von `pickTextFileContent` — siehe `pick_text_file.dart`
/// für den Grund der Aufteilung.
Future<String?> pickTextFileContent() async {
  final path = await FlutterFileDialog.pickFile(
    params: const OpenFileDialogParams(
      // Bewusst kein Endungs-Filter: je nach Quelle (Drive, Downloads …)
      // meldet Android nicht zuverlässig eine `.json`-Endung.
      copyFileToCacheDir: true,
    ),
  );
  if (path == null) return null;

  return File(path).readAsString();
}
