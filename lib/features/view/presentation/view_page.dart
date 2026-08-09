import 'package:flutter/material.dart';

import '../../../l10n/gen/app_localizations.dart';
import '../month/month_tab.dart';
import '../overview/overview_tab.dart';
import '../week/week_tab.dart';
import '../year/year_tab.dart';

/// View-Seite: Tab-Container für die Unterseiten Woche/Übersicht/Monat/Jahr.
class ViewPage extends StatelessWidget {
  const ViewPage({super.key});

  /// Position der Übersicht in der Tab-Reihenfolge. Die Seite braucht sie, um
  /// zu erkennen, ob sie gerade sichtbar ist (siehe [OverviewTab.tabIndex]) —
  /// deshalb eine Konstante statt einer im Kopf mitgezählten 1.
  static const int overviewTabIndex = 1;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.navView),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.tabWeek),
              Tab(text: l10n.tabOverview),
              Tab(text: l10n.tabMonth),
              Tab(text: l10n.tabYear),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            WeekTab(),
            OverviewTab(tabIndex: overviewTabIndex),
            MonthTab(),
            YearTab(),
          ],
        ),
      ),
    );
  }
}
