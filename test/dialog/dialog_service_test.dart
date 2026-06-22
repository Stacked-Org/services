import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stacked_services/stacked_services.dart';

import '../helpers/test_app.dart';

void main() {
  group('DialogService -', () {
    late DialogService service;

    setUp(() {
      service = DialogService();
    });

    Future<void> pumpApp(WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();
    }

    testWidgets('showDialog renders title, description and button',
        (tester) async {
      await pumpApp(tester);

      final future = service.showDialog(
        title: 'Title',
        description: 'Description',
        buttonTitle: 'Confirm',
        dialogPlatform: DialogPlatform.Material,
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('dialog_view')), findsOneWidget);
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);

      await tester.tap(find.byKey(const Key('dialog_touchable_confirm')));
      await tester.pumpAndSettle();
      await future;
    });

    testWidgets('confirm button completes with confirmed = true',
        (tester) async {
      await pumpApp(tester);

      final future = service.showDialog(
        title: 'Title',
        buttonTitle: 'Confirm',
        dialogPlatform: DialogPlatform.Material,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('dialog_touchable_confirm')));
      await tester.pumpAndSettle();

      final response = await future;
      expect(response?.confirmed, isTrue);
    });

    testWidgets('cancel button completes with confirmed = false',
        (tester) async {
      await pumpApp(tester);

      final future = service.showConfirmationDialog(
        title: 'Title',
        cancelTitle: 'Cancel',
        confirmationTitle: 'Confirm',
        dialogPlatform: DialogPlatform.Material,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('dialog_touchable_cancel')));
      await tester.pumpAndSettle();

      final response = await future;
      expect(response?.confirmed, isFalse);
    });

    testWidgets('isDialogOpen toggles while a dialog is visible',
        (tester) async {
      await pumpApp(tester);
      expect(service.isDialogOpen, isFalse);

      final future = service.showDialog(
        title: 'Title',
        buttonTitle: 'Confirm',
        dialogPlatform: DialogPlatform.Material,
      );
      await tester.pumpAndSettle();
      expect(service.isDialogOpen, isTrue);

      await tester.tap(find.byKey(const Key('dialog_touchable_confirm')));
      await tester.pumpAndSettle();
      await future;
      expect(service.isDialogOpen, isFalse);
    });

    testWidgets('showCustomDialog uses the registered builder and completes',
        (tester) async {
      service.registerCustomDialogBuilders({
        'basic': (context, request, completer) => ElevatedButton(
              key: const Key('custom_dialog_button'),
              onPressed: () => completer(DialogResponse(confirmed: true)),
              child: Text(request.title ?? ''),
            ),
      });

      await pumpApp(tester);

      final future = service.showCustomDialog(
        variant: 'basic',
        title: 'Custom',
      );
      await tester.pumpAndSettle();

      expect(find.text('Custom'), findsOneWidget);

      await tester.tap(find.byKey(const Key('custom_dialog_button')));
      await tester.pumpAndSettle();

      final response = await future;
      expect(response?.confirmed, isTrue);
    });
  });
}
