import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stacked_services/stacked_services.dart';

import '../helpers/test_app.dart';

void main() {
  group('BottomSheetService -', () {
    late BottomSheetService service;

    setUp(() {
      service = BottomSheetService();
    });

    Future<void> pumpApp(WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();
    }

    testWidgets('showBottomSheet renders title, description and buttons',
        (tester) async {
      await pumpApp(tester);

      final future = service.showBottomSheet(
        title: 'Sheet title',
        description: 'Sheet description',
        confirmButtonTitle: 'Confirm',
        cancelButtonTitle: 'Cancel',
      );
      await tester.pumpAndSettle();

      expect(find.text('Sheet title'), findsOneWidget);
      expect(find.text('Sheet description'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      await future;
    });

    testWidgets('confirm completes with confirmed = true', (tester) async {
      await pumpApp(tester);

      final future = service.showBottomSheet(
        title: 'Sheet title',
        confirmButtonTitle: 'Confirm',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      final response = await future;
      expect(response?.confirmed, isTrue);
    });

    testWidgets('cancel completes with confirmed = false', (tester) async {
      await pumpApp(tester);

      final future = service.showBottomSheet(
        title: 'Sheet title',
        confirmButtonTitle: 'Confirm',
        cancelButtonTitle: 'Cancel',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      final response = await future;
      expect(response?.confirmed, isFalse);
    });

    testWidgets('isBottomSheetOpen toggles while a sheet is visible',
        (tester) async {
      await pumpApp(tester);
      expect(service.isBottomSheetOpen, isFalse);

      final future = service.showBottomSheet(
        title: 'Sheet title',
        confirmButtonTitle: 'Confirm',
      );
      await tester.pumpAndSettle();
      expect(service.isBottomSheetOpen, isTrue);

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      await future;
      expect(service.isBottomSheetOpen, isFalse);
    });

    testWidgets('showCustomSheet uses the registered builder and completes',
        (tester) async {
      service.setCustomSheetBuilders({
        'basic': (context, request, completer) => ElevatedButton(
              key: const Key('custom_sheet_button'),
              onPressed: () => completer(SheetResponse(confirmed: true)),
              child: Text(request.title ?? ''),
            ),
      });

      await pumpApp(tester);

      final future = service.showCustomSheet(
        variant: 'basic',
        title: 'Custom sheet',
      );
      await tester.pumpAndSettle();

      expect(find.text('Custom sheet'), findsOneWidget);

      await tester.tap(find.byKey(const Key('custom_sheet_button')));
      await tester.pumpAndSettle();

      final response = await future;
      expect(response?.confirmed, isTrue);
    });
  });
}
