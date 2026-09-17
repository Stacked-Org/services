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
        // Regression test for https://github.com/Stacked-Org/stacked/issues/1163
        //
        // showCustomSnackBar defers the actual `getBar.show()` call to a
        // WidgetsBinding.addPostFrameCallback when the registered
        // SnackbarConfig has instantInit == false (the default). That
        // callback only ever runs the next time the engine produces a
        // frame. If showCustomSnackBar is called after an `await` with no
        // frame already scheduled - i.e. the binding is idle, exactly like
        // after an `await Future.delayed(...)` in a real app, which is how
        // the issue was reported - nothing would trigger that frame and the
        // snackbar would silently never appear.
        await tester.pumpWidget(
          GetMaterialApp(home: Scaffold(body: Container())),
        );
        await tester.pump();

        final snackbarService = SnackbarService();
        snackbarService.registerCustomSnackbarConfig(
          variant: 'regression-1163',
          config: SnackbarConfig(),
        );

        // Sanity check: the binding is idle with no frame scheduled - this
        // is what the SchedulerBinding looks like after an `await` with no
        // other pending work, which is exactly the reported repro.
        expect(SchedulerBinding.instance.hasScheduledFrame, isFalse);

        snackbarService.showCustomSnackBar(
          message: 'Blue and yellow',
          variant: 'regression-1163',
          duration: const Duration(milliseconds: 200),
        );

        // Without the fix, nothing here schedules a frame and the queued
        // addPostFrameCallback would sit pending forever, so the snackbar
        // would never appear.
        expect(SchedulerBinding.instance.hasScheduledFrame, isTrue);

        // Run the frame that fires the deferred post-frame callback (where
        // getBar.show() actually happens), then one more frame so the
        // freshly-inserted overlay entry is actually built and painted.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        expect(find.text('Blue and yellow'), findsOneWidget);

        // Drain the auto-dismiss timer and the hide animation so nothing is
        // left pending (Timer/AnimationController) when the test ends.
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pump(const Duration(milliseconds: 1200));
      },
    );

    testWidgets(
      'still shows immediately when instantInit is true',
      (tester) async {
        // instantInit: true takes the non-deferred path (no post-frame
        // callback at all) and must keep working exactly as before.
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
