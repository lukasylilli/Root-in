import 'package:go_router/go_router.dart';

import '../../features/account/presentation/account_page.dart';
import '../../features/categories/presentation/categories_page.dart';
import '../../features/guide/presentation/guide_page.dart';
import '../../features/guide/presentation/guide_topic.dart';
import '../../features/others/presentation/others_folder_page.dart';
import '../../features/others/presentation/others_folders_page.dart';
import '../../features/settings/presentation/reminders_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/onboarding/presentation/onboarding_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../features/today/presentation/today_page.dart';
import '../../features/view/overview/overview_fullscreen_page.dart';
import '../../features/view/presentation/view_page.dart';
import '../widgets/main_shell.dart';
import 'app_routes.dart';

/// Einzige go_router-Konfiguration der App.
///
/// Bewusst eine Funktion statt einer Konstante: beim allerersten Start
/// beginnt die App auf der Erklärungs-Seite statt auf Home (siehe PLAN.md
/// Phase 11.6). Ein `redirect` wäre der falsche Weg — ob das Onboarding
/// fällig ist, steht genau einmal beim Start fest und müsste sonst bei jeder
/// Navigation erneut geprüft werden.
///
/// Muss **einmalig** aufgebaut werden (in `app.dart` im `initState`): eine
/// bei jedem Build neue `GoRouter`-Instanz würde die Navigation zurücksetzen.
GoRouter createAppRouter({required bool showOnboarding}) => GoRouter(
  initialLocation: showOnboarding ? AppRoutes.onboarding : AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingPage(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: AppRoutes.today,
          builder: (context, state) => const TodayPage(),
        ),
        GoRoute(
          path: AppRoutes.view,
          builder: (context, state) => const ViewPage(),
        ),
        GoRoute(
          path: AppRoutes.settings,
          builder: (context, state) => const SettingsPage(),
        ),
      ],
    ),
    // Außerhalb der Shell (kein Bottom-Nav): Konto und Kategorien sind
    // Detail-Screens, die über Einstellungen erreicht werden, nicht über
    // die Hauptnavigation. Das Übersicht-Vollbild steht aus einem anderen
    // Grund hier — es braucht die 80 dp der Bottom-Navigation für die Bühne
    // (siehe PLAN.md Phase 16).
    GoRoute(
      path: AppRoutes.overviewFullscreen,
      builder: (context, state) => const OverviewFullscreenPage(),
    ),
    // Je Anleitungs-Thema eine eigene Route, aus dem Enum erzeugt: kein
    // Pfad-Parameter, der beim Aufruf mit unbekanntem Wert ins Leere liefe.
    for (final topic in GuideTopic.values)
      GoRoute(
        path: topic.route,
        builder: (context, state) => GuidePage(topic: topic),
      ),
    // „موارد دیگر": Ordner kommen aus dem Repository, nicht aus dem Code —
    // deshalb ein Pfad-Parameter statt einer Route je Ordner.
    GoRoute(
      path: AppRoutes.others,
      builder: (context, state) => const OthersFoldersPage(),
    ),
    GoRoute(
      path: AppRoutes.othersFolderPattern,
      builder: (context, state) => OthersFolderPage(
        folderId: state.pathParameters['folderId'] ?? '',
      ),
    ),
    GoRoute(
      path: AppRoutes.account,
      builder: (context, state) => const AccountPage(),
    ),
    GoRoute(
      path: AppRoutes.categories,
      builder: (context, state) => const CategoriesPage(),
    ),
    GoRoute(
      path: AppRoutes.reminders,
      builder: (context, state) => const RemindersPage(),
    ),
  ],
);
