import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/default_categories.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/text_prompt_dialog.dart';
import '../../../data/local/daos/category_dao.dart' show DeleteCategoryResult;
import '../../../data/local/database.dart' show Category;
import '../../../data/repositories/habit_repository.dart';
import '../../../l10n/gen/app_localizations.dart';

/// Kategorien-Seite (siehe PLAN.md Abschnitt 5.6): anlegen, umbenennen,
/// löschen — dazu der Nachrüst-Knopf für die Standard-Kategorien
/// (Phase 21.1). Erreichbar über Einstellungen → Kategorien.
///
/// Die Standard-Kategorien sind hier **nichts Besonderes**: Sie lassen sich
/// wie jede andere umbenennen und löschen (Phase 21.2). Erkennbar sind sie
/// nur am Symbol, das [DefaultCategory.iconForName] über den Namen zuordnet.
class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  Future<void> _addCategory(BuildContext context, WidgetRef ref) async {
    final name = await _promptForName(
      context,
      title: AppLocalizations.of(context).dialogNewCategoryTitle,
    );
    if (name == null || name.isEmpty) return;
    await ref.read(habitRepositoryProvider).addCategory(name);
  }

  /// Nachrüsten für Bestandsnutzer: legt nur an, was fehlt, und meldet die
  /// Anzahl. Beim Erststart passiert das automatisch (siehe `main.dart`) —
  /// wer die App vor Phase 21 installiert hat, kommt nur hierüber daran.
  Future<void> _addDefaultCategories(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);

    final added = await ref
        .read(habitRepositoryProvider)
        .addMissingCategories(defaultCategoryNames(l10n));

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          added == 0
              ? l10n.categoriesDefaultsComplete
              : l10n.categoriesDefaultsAdded(added),
        ),
      ),
    );
  }

  Future<void> _renameCategory(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) async {
    final name = await _promptForName(
      context,
      title: AppLocalizations.of(context).dialogRenameCategoryTitle,
      initialValue: category.name,
    );
    if (name == null || name.isEmpty || name == category.name) return;
    await ref.read(habitRepositoryProvider).renameCategory(category.id, name);
  }

  Future<void> _deleteCategory(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) async {
    final outcome = await ref
        .read(habitRepositoryProvider)
        .deleteCategory(category.id);
    if (!context.mounted) return;
    if (outcome.status == DeleteCategoryResult.stillInUse) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(
              context,
            ).categoryStillInUse(category.name, outcome.habitsUsing),
          ),
        ),
      );
    }
  }

  Future<String?> _promptForName(
    BuildContext context, {
    required String title,
    String initialValue = '',
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) =>
          TextPromptDialog(title: title, initialValue: initialValue),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pageCategoriesTitle)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addCategory(context, ref),
        child: const Icon(Icons.add),
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text(l10n.errorGeneric('$error'))),
        data: (categories) {
          // Die Liste ist nach Namen sortiert (siehe `watchAllCategories`) —
          // eine stabile, für den Nutzer nachvollziehbare Reihenfolge, die
          // sich beim Anlegen und Umbenennen nicht umsortiert (Phase 21.2).
          return ListView(
            children: [
              if (categories.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    l10n.categoriesEmpty,
                    textAlign: TextAlign.center,
                  ),
                ),
              for (final category in categories)
                ListTile(
                  leading: Icon(
                    DefaultCategory.iconForName(category.name, l10n),
                  ),
                  title: Text(category.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: l10n.actionRename,
                        onPressed: () =>
                            _renameCategory(context, ref, category),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: l10n.actionDelete,
                        onPressed: () =>
                            _deleteCategory(context, ref, category),
                      ),
                    ],
                  ),
                ),
              const Divider(),
              // Steht bewusst **unter** der Liste und ohne Bedingung: Er darf
              // auch dann sichtbar sein, wenn alle sieben schon da sind —
              // sonst wäre unklar, warum er verschwindet. Er meldet dann
              // einfach, dass nichts fehlt.
              ListTile(
                leading: const Icon(Icons.playlist_add_outlined),
                title: Text(l10n.categoriesAddDefaults),
                subtitle: Text(l10n.categoriesAddDefaultsSubtitle),
                onTap: () => _addDefaultCategories(context, ref),
              ),
            ],
          );
        },
      ),
    );
  }
}
