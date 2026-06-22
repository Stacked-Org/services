import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stacked_services/stacked_services.dart';

import '../helpers/test_app.dart';

/// These tests exercise the [StackObserver] indirectly through the public
/// routing state it feeds (currentRoute / previousRoute / isDialogOpen /
/// isBottomSheetOpen). They are written against the public surface so they
/// survive the `get` removal unchanged.
void main() {
  group('StackObserver (routing state) -', () {
    late NavigationService navigation;
    late DialogService dialog;
    late BottomSheetService bottomSheet;

    setUp(() {
      navigation = NavigationService();
      dialog = DialogService();
      bottomSheet = BottomSheetService();
    });

    Future<void> pumpApp(WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();
    }

    testWidgets('tracks current and previous across multiple pushes',
        (tester) async {
      await pumpApp(tester);

      unawaited(navigation.navigateTo(TestRoutes.second));
      await tester.pumpAndSettle();
      unawaited(navigation.navigateTo(TestRoutes.third));
      await tester.pumpAndSettle();

      expect(navigation.currentRoute, TestRoutes.third);
      expect(navigation.previousRoute, TestRoutes.second);
    });

    testWidgets('restores current after popping', (tester) async {
      await pumpApp(tester);

      unawaited(navigation.navigateTo(TestRoutes.second));
      await tester.pumpAndSettle();
      unawaited(navigation.navigateTo(TestRoutes.third));
      await tester.pumpAndSettle();

      navigation.back();
      await tester.pumpAndSettle();

      expect(navigation.currentRoute, TestRoutes.second);
    });

    testWidgets('opening a dialog does not change the current page route',
        (tester) async {
      await pumpApp(tester);
      unawaited(navigation.navigateTo(TestRoutes.second));
      await tester.pumpAndSettle();

      final future = dialog.showDialog(
        title: 'Title',
        buttonTitle: 'Confirm',
        dialogPlatform: DialogPlatform.Material,
      );
      await tester.pumpAndSettle();

      expect(navigation.currentRoute, TestRoutes.second);
      expect(dialog.isDialogOpen, isTrue);

      await tester.tap(find.byKey(const Key('dialog_touchable_confirm')));
      await tester.pumpAndSettle();
      await future;

      expect(dialog.isDialogOpen, isFalse);
    });

    testWidgets('opening a bottom sheet does not change the current page route',
        (tester) async {
      await pumpApp(tester);
      unawaited(navigation.navigateTo(TestRoutes.second));
      await tester.pumpAndSettle();

      final future = bottomSheet.showBottomSheet(
        title: 'Sheet',
        confirmButtonTitle: 'Confirm',
      );
      await tester.pumpAndSettle();

      expect(navigation.currentRoute, TestRoutes.second);
      expect(bottomSheet.isBottomSheetOpen, isTrue);

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      await future;

      expect(bottomSheet.isBottomSheetOpen, isFalse);
    });
  });
}
