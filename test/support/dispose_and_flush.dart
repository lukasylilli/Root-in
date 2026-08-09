import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Räumt den gepumpten Widget-Baum aktiv ab und lässt anschließend
/// ausstehende Nulldauer-Timer ablaufen (z. B. Drifts
/// `StreamQueryStore.markAsClosed`, das beim Abbestellen eines
/// `.watch()`-Streams einen `Timer(Duration.zero, ...)` plant). Ohne das
/// meldet `flutter_test` am Testende fälschlich „A Timer is still pending",
/// sobald ein Widget-Test einen DB-gestützten Stream-Provider berührt — der
/// Timer wird sonst erst während des automatischen Framework-Teardowns
/// geplant, nachdem der Testkörper schon zurückgekehrt ist. Als letzte
/// Zeile jedes solchen Tests aufrufen.
Future<void> disposeAndFlush(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(Duration.zero);
}
