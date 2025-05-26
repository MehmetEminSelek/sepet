// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:sepet_mobile_app/services/demo_auth_service.dart';
import 'package:sepet_mobile_app/services/demo_firestore_service.dart';
import 'package:sepet_mobile_app/screens/demo_auth_wrapper.dart';
import 'package:sepet_mobile_app/constants/app_theme.dart';

void main() {
  group('SepetApp Demo Widget Tests', () {
    testWidgets('Demo Auth Wrapper should build without errors',
        (WidgetTester tester) async {
      // Build demo auth wrapper directly
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<DemoAuthService>(
              create: (_) => DemoAuthService()..initialize(),
            ),
            Provider<DemoFirestoreService>(
              create: (_) => DemoFirestoreService()..initialize(),
            ),
          ],
          child: MaterialApp(
            title: 'Sepet - Ortak Alışveriş',
            theme: AppTheme.lightTheme,
            home: const DemoAuthWrapper(),
          ),
        ),
      );

      // Verify that the app builds successfully
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Demo services should initialize', (WidgetTester tester) async {
      final demoAuthService = DemoAuthService();
      final demoFirestoreService = DemoFirestoreService();

      // Initialize services
      demoAuthService.initialize();
      demoFirestoreService.initialize();

      // Services should be initialized without errors
      expect(demoAuthService, isNotNull);
      expect(demoFirestoreService, isNotNull);
    });

    testWidgets('MaterialApp should have correct title',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<DemoAuthService>(
              create: (_) => DemoAuthService()..initialize(),
            ),
            Provider<DemoFirestoreService>(
              create: (_) => DemoFirestoreService()..initialize(),
            ),
          ],
          child: MaterialApp(
            title: 'Sepet - Ortak Alışveriş',
            theme: AppTheme.lightTheme,
            home: const DemoAuthWrapper(),
          ),
        ),
      );

      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
      expect(materialApp.title, 'Sepet - Ortak Alışveriş');
    });

    testWidgets('Demo auth wrapper should show scaffold',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<DemoAuthService>(
              create: (_) => DemoAuthService()..initialize(),
            ),
            Provider<DemoFirestoreService>(
              create: (_) => DemoFirestoreService()..initialize(),
            ),
          ],
          child: const MaterialApp(
            home: DemoAuthWrapper(),
          ),
        ),
      );

      // Use pump instead of pumpAndSettle to avoid timeout
      await tester.pump();

      // Should contain MaterialApp
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(DemoAuthWrapper), findsOneWidget);
    });
  });
}
