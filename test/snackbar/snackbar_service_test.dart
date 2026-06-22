import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stacked_services/stacked_services.dart';

import '../helpers/test_app.dart';

void main() {
  group('SnackbarService -', () {
    late SnackbarService service;

    setUp(() {
      service = SnackbarService();
    });

    Future<void> pumpApp(WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();
    }

    // Fully dismisses any open snackbar and lets its exit animation finish so
    // the overlay disposes its tickers before the test tree is torn down.
    Future<void> dismiss(WidgetTester tester, SnackbarService service) async {
      unawaited(service.closeSnackbar());
      await tester.pumpAndSettle(const Duration(seconds: 1));
    }

    testWidgets('showSnackbar displays the message', (tester) async {
      await pumpApp(tester);

      service.showSnackbar(
        title: 'Hello',
        message: 'World',
        duration: const Duration(seconds: 30),
      );
      await tester.pumpAndSettle();

      expect(find.text('World'), findsOneWidget);
      expect(service.isSnackbarOpen, isTrue);

      await dismiss(tester, service);
    });

    testWidgets('closeSnackbar dismisses the snackbar', (tester) async {
      await pumpApp(tester);

      service.showSnackbar(
        message: 'Dismiss me',
        duration: const Duration(seconds: 30),
      );
      await tester.pumpAndSettle();
      expect(service.isSnackbarOpen, isTrue);

      await dismiss(tester, service);

      expect(service.isSnackbarOpen, isFalse);
    });

    testWidgets('showCustomSnackBar renders the custom snackbar view',
        (tester) async {
      service.registerCustomSnackbarConfig(
        variant: 'basic',
        config: SnackbarConfig(instantInit: true),
      );

      await pumpApp(tester);

      service.showCustomSnackBar(
        message: 'Custom message',
        variant: 'basic',
        duration: const Duration(seconds: 30),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('snackbar_view')), findsOneWidget);
      expect(find.text('Custom message'), findsOneWidget);

      await dismiss(tester, service);
    });

    testWidgets(
        'showCustomSnackBar throws when no config registered for variant',
        (tester) async {
      await pumpApp(tester);

      await expectLater(
        service.showCustomSnackBar(message: 'No config', variant: 'missing'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
