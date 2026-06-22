import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:stacked_services_example/app/app.locator.dart';
import 'package:stacked_services_example/app/app.router.dart';
import 'package:stacked_services_example/ui/setup_bottom_sheet_ui.dart';
import 'package:stacked_services_example/ui/setup_dialog_ui.dart';
import 'package:stacked_services_example/ui/setup_snackbar_ui.dart';

/// End-to-end smoke test of the get-free refactor, driving the real example
/// app. Exercises every migrated service:
///   - DialogService      -> showGeneralDialog
///   - SnackbarService    -> vendored GetSnackBar on the navigator overlay
///   - BottomSheetService -> showModalBottomSheet
///   - NavigationService  -> native Navigator + PageRouteBuilder transitions
///
/// The snackbar/sheet/transition each run an AnimationController on the shared
/// [StackedService] overlay/navigator, so every test fully dismisses its
/// transient UI and settles before ending — otherwise an active Ticker would
/// outlive the widget tree and trip the framework's leak assertion.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Widget buildApp() => MaterialApp(
        title: 'Stacked Services Demo',
        navigatorObservers: [StackedService.routeObserver],
        onGenerateRoute: StackedRouter().onGenerateRoute,
        navigatorKey: StackedService.navigatorKey,
      );

  setUp(() async {
    // Reset between tests so re-running setupLocator() doesn't throw on the
    // already-registered get_it singletons.
    await locator.reset();
    setupLocator();
    setupDialogUi();
    setupSnackbarUi();
    setupBottomSheetUi();
  });

  testWidgets('DialogService.showDialog renders via showGeneralDialog',
      (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    // Dialogs tab is the default landing view.
    await tester.tap(find.text('Show Material Dialog').first);
    await tester.pumpAndSettle();

    expect(find.text('Test Dialog Title'), findsOneWidget);
    expect(find.text('Test Dialog Description'), findsOneWidget);

    // Dismiss the dialog so the route's transition ticker is disposed.
    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await tester.pumpAndSettle();
  });

  testWidgets('SnackbarService.showSnackbar renders the vendored snackbar',
      (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Snackbar'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Show Snackbar'));
    await tester.pump(); // schedule the entry
    await tester.pump(const Duration(seconds: 1)); // finish the entry animation

    expect(find.text('This is a snack bar'), findsOneWidget);

    // Let the 3s auto-dismiss timer fire, then settle the exit animation so the
    // overlay entry (and its ticker) is fully removed before teardown.
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.text('This is a snack bar'), findsNothing);
  });

  testWidgets('BottomSheetService.showBottomSheet renders via modal sheet',
      (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('BottomSheet'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Show Basic Bottom Sheet Alert'));
    await tester.pumpAndSettle();

    expect(find.text('This is my Sheets Title'), findsOneWidget);

    // Dismiss the modal sheet and settle its exit animation.
    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await tester.pumpAndSettle();
    expect(find.text('This is my Sheets Title'), findsNothing);
  });

  testWidgets('NavigationService transition pushes via native Navigator',
      (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    // FAB -> FirstScreen (named route).
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('First Screen'), findsOneWidget);

    // Fade transition -> SecondScreen (widget push + PageRouteBuilder).
    await tester.tap(find.text('Use Fade Transition'));
    await tester.pumpAndSettle();
    expect(find.text('Second Screen'), findsOneWidget);

    // Unwind the stack so transition tickers are disposed before teardown.
    final navigator =
        tester.state<NavigatorState>(find.byType(Navigator).first);
    navigator.pop();
    await tester.pumpAndSettle();
    navigator.pop();
    await tester.pumpAndSettle();
    expect(find.text('Home Screen'), findsOneWidget);
  });
}
