import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:stacked_services/stacked_services.dart';

void main() {
  group('SnackbarService showCustomSnackBar -', () {
    testWidgets(
      'schedules a frame and shows the snackbar when called after an async '
      'gap (instantInit: false)',
      (tester) async {
        await tester.pumpWidget(
          GetMaterialApp(home: Scaffold(body: Container())),
        );
        await tester.pump();

        final snackbarService = SnackbarService();
        snackbarService.registerCustomSnackbarConfig(
          variant: 'regression-1163',
          config: SnackbarConfig(),
        );

        expect(SchedulerBinding.instance.hasScheduledFrame, isFalse);

        snackbarService.showCustomSnackBar(
          message: 'Blue and yellow',
          variant: 'regression-1163',
          duration: const Duration(milliseconds: 200),
        );

        expect(SchedulerBinding.instance.hasScheduledFrame, isTrue);

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        expect(find.text('Blue and yellow'), findsOneWidget);

        await tester.pump(const Duration(milliseconds: 200));
        await tester.pump(const Duration(milliseconds: 1200));
      },
    );

    testWidgets(
      'still shows immediately when instantInit is true',
      (tester) async {
        await tester.pumpWidget(
          GetMaterialApp(home: Scaffold(body: Container())),
        );
        await tester.pump();

        final snackbarService = SnackbarService();
        snackbarService.registerCustomSnackbarConfig(
          variant: 'regression-1163-instant',
          config: SnackbarConfig(instantInit: true),
        );

        snackbarService.showCustomSnackBar(
          message: 'Instant message',
          variant: 'regression-1163-instant',
          duration: const Duration(milliseconds: 200),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        expect(find.text('Instant message'), findsOneWidget);

        await tester.pump(const Duration(milliseconds: 200));
        await tester.pump(const Duration(milliseconds: 1200));
      },
    );
  });
}
