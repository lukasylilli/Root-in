import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../l10n/gen/app_localizations.dart';

/// Eine Seite der Erststart-Erklärung. Bewusst ein reiner Wertetyp: die
/// Texte kommen aus [AppLocalizations], die Reihenfolge steht an genau einer
/// Stelle (siehe [_pages]).
class _OnboardingStep {
  const _OnboardingStep({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}

/// Erststart-Erklärung (siehe PLAN.md Phase 11.6): erklärt in vier Schritten,
/// wofür die App da ist und wo die wichtigsten Dinge liegen.
///
/// Erscheint nur, solange `onboardingSeenProvider` `false` ist — der Router
/// startet dann hier statt auf Home. Sowohl „Los geht's" als auch
/// „Überspringen" setzen den Merker, danach ist die Seite nicht mehr
/// erreichbar.
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<_OnboardingStep> _pages(AppLocalizations l10n) => [
    _OnboardingStep(
      icon: Icons.eco_outlined,
      title: l10n.onboardingWelcomeTitle,
      body: l10n.onboardingWelcomeBody,
    ),
    _OnboardingStep(
      icon: Icons.checklist_outlined,
      title: l10n.onboardingHabitsTitle,
      body: l10n.onboardingHabitsBody,
    ),
    _OnboardingStep(
      icon: Icons.insights_outlined,
      title: l10n.onboardingProgressTitle,
      body: l10n.onboardingProgressBody,
    ),
    _OnboardingStep(
      icon: Icons.notifications_active_outlined,
      title: l10n.onboardingRemindersTitle,
      body: l10n.onboardingRemindersBody,
    ),
  ];

  Future<void> _finish() async {
    await ref.read(onboardingSeenProvider.notifier).markSeen();
    if (mounted) context.go(AppRoutes.home);
  }

  void _next(int pageCount) {
    if (_index >= pageCount - 1) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pages = _pages(l10n);
    final isLast = _index == pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: Text(l10n.onboardingSkip),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (index) => setState(() => _index = index),
                itemBuilder: (context, index) => _StepView(step: pages[index]),
              ),
            ),
            _Dots(count: pages.length, active: _index),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: AppButton(
                label: isLast ? l10n.onboardingStart : l10n.onboardingNext,
                onPressed: () => _next(pages.length),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepView extends StatelessWidget {
  const _StepView({required this.step});

  final _OnboardingStep step;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: scheme.primaryContainer,
            child: Icon(step.icon, size: 44, color: scheme.primary),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            step.title,
            style: AppTextStyles.headline,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            step.body,
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Fortschrittspunkte unter den Seiten.
class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          Container(
            width: i == active ? 20 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: i == active ? scheme.primary : scheme.outlineVariant,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}
