import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/core/services/dashboard_layout_service.dart';
import 'package:root_in/core/services/settings_service.dart';
import 'package:root_in/core/widgets/dashboard/dashboard_widget_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ProviderContainer container;
  late SharedPreferences prefs;

  const config = (
    pageId: 'test',
    defaultTypes: [DashboardWidgetType.matrixGrid, DashboardWidgetType.categoryBar],
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
  });

  tearDown(() => container.dispose());

  test('liefert die Standard-Widgets, solange nichts gespeichert ist', () {
    expect(container.read(dashboardLayoutProvider(config)), [
      DashboardWidgetType.matrixGrid,
      DashboardWidgetType.categoryBar,
    ]);
  });

  test('toggle entfernt und fügt Widgets hinzu und persistiert', () {
    container
        .read(dashboardLayoutProvider(config).notifier)
        .toggle(DashboardWidgetType.matrixGrid);
    expect(container.read(dashboardLayoutProvider(config)), [
      DashboardWidgetType.categoryBar,
    ]);
    expect(prefs.getStringList('dashboard_layout_test'), ['categoryBar']);

    container
        .read(dashboardLayoutProvider(config).notifier)
        .toggle(DashboardWidgetType.progressTrend);
    expect(container.read(dashboardLayoutProvider(config)), [
      DashboardWidgetType.categoryBar,
      DashboardWidgetType.progressTrend,
    ]);
  });

  test('reorder ändert die Reihenfolge und persistiert', () {
    container.read(dashboardLayoutProvider(config).notifier).reorder(0, 1);

    expect(container.read(dashboardLayoutProvider(config)), [
      DashboardWidgetType.categoryBar,
      DashboardWidgetType.matrixGrid,
    ]);
    expect(prefs.getStringList('dashboard_layout_test'), [
      'categoryBar',
      'matrixGrid',
    ]);
  });

  test('gespeichertes Layout überlebt einen neuen Container', () {
    container
        .read(dashboardLayoutProvider(config).notifier)
        .toggle(DashboardWidgetType.matrixGrid);

    final container2 = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container2.dispose);

    expect(container2.read(dashboardLayoutProvider(config)), [
      DashboardWidgetType.categoryBar,
    ]);
  });
}
