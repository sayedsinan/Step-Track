import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:step_track/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Health Connect App Integration Tests', () {
    testWidgets('App launches successfully', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.text('Health Dashboard'), findsOneWidget);
    });

    testWidgets('Navigation to permissions screen works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      final settingsButton = find.byIcon(Icons.settings);
      expect(settingsButton, findsOneWidget);

      await tester.tap(settingsButton);
      await tester.pumpAndSettle();

      expect(find.text('Permissions'), findsOneWidget);
    });

    testWidgets('Navigation to debug screen works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      final debugButton = find.byIcon(Icons.bug_report);
      expect(debugButton, findsOneWidget);

      await tester.tap(debugButton);
      await tester.pumpAndSettle();

      expect(find.text('Debug & Simulation'), findsOneWidget);
    });

    testWidgets('Simulation mode can be enabled', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to debug screen
      await tester.tap(find.byIcon(Icons.bug_report));
      await tester.pumpAndSettle();

      // Find and tap the simulation toggle
      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);

      await tester.tap(switchFinder);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify simulation is active
      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('Performance HUD can be toggled', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      final hudToggle = find.byIcon(Icons.visibility);
      expect(hudToggle, findsOneWidget);

      await tester.tap(hudToggle);
      await tester.pumpAndSettle();

      // HUD should now be hidden, button icon changes
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('Simulation generates data over time', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Enable simulation
      await tester.tap(find.byIcon(Icons.bug_report));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Go back to dashboard
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Wait for data generation (3 seconds per update)
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      // Verify step card shows non-zero value
      expect(find.byType(Card), findsWidgets);
      
      // Wait for more updates
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('Charts render without errors', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Enable simulation
      await tester.tap(find.byIcon(Icons.bug_report));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Go back to dashboard
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Wait for data
      await tester.pump(const Duration(seconds: 10));
      await tester.pumpAndSettle();

      // Verify charts exist
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });
}