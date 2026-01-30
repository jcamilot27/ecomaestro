import 'package:flutter_test/flutter_test.dart';
import 'package:eco_maestro/main.dart';
import 'package:eco_maestro/core/di/service_locator.dart' as di;
import 'package:get_it/get_it.dart';

void main() {
  setUp(() async {
    await GetIt.instance.reset(); // Reset DI
    await di.init(); // Init DI
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const EcoMaestroApp());

    // Wait for animations to settle
    await tester.pumpAndSettle();

    // Verify that our title is present
    expect(find.text('Bienvenido, Estudiante'), findsOneWidget);
  });
}
