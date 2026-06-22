import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:stacked_services/stacked_services.dart';

import '../helpers/test_app.dart';

void main() {
  group('NavigationService -', () {
    late NavigationService service;

    setUp(() {
      service = NavigationService();
    });

    Future<void> pumpApp(WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();
    }

    testWidgets('starts on the initial route', (tester) async {
      await pumpApp(tester);
      expect(find.byKey(TestScreen.keyFor('home')), findsOneWidget);
    });

    testWidgets('navigateTo pushes the named route', (tester) async {
      await pumpApp(tester);

      unawaited(service.navigateTo(TestRoutes.second));
      await tester.pumpAndSettle();

      expect(find.byKey(TestScreen.keyFor('second')), findsOneWidget);
      expect(find.byKey(TestScreen.keyFor('home')), findsNothing);
    });

    testWidgets('currentRoute and previousRoute reflect the stack',
        (tester) async {
      await pumpApp(tester);
      expect(service.currentRoute, TestRoutes.home);

      unawaited(service.navigateTo(TestRoutes.second));
      await tester.pumpAndSettle();

      expect(service.currentRoute, TestRoutes.second);
      expect(service.previousRoute, TestRoutes.home);
    });

    testWidgets('currentArguments returns the arguments passed in',
        (tester) async {
      await pumpApp(tester);

      unawaited(service.navigateTo(TestRoutes.second, arguments: 'payload'));
      await tester.pumpAndSettle();

      expect(service.currentArguments, 'payload');
    });

    testWidgets('back pops the current route', (tester) async {
      await pumpApp(tester);
      unawaited(service.navigateTo(TestRoutes.second));
      await tester.pumpAndSettle();

      service.back();
      await tester.pumpAndSettle();

      expect(find.byKey(TestScreen.keyFor('home')), findsOneWidget);
    });

    testWidgets('preventDuplicates blocks navigating to the current route',
        (tester) async {
      await pumpApp(tester);
      unawaited(service.navigateTo(TestRoutes.second));
      await tester.pumpAndSettle();

      final result = service.navigateTo(TestRoutes.second);
      await tester.pumpAndSettle();

      expect(result, isNull);
    });

    testWidgets('replaceWith swaps the current route', (tester) async {
      await pumpApp(tester);
      unawaited(service.navigateTo(TestRoutes.second));
      await tester.pumpAndSettle();

      unawaited(service.replaceWith(TestRoutes.third));
      await tester.pumpAndSettle();

      expect(find.byKey(TestScreen.keyFor('third')), findsOneWidget);
      expect(find.byKey(TestScreen.keyFor('second')), findsNothing);

      // Popping should return to home, proving second was replaced not pushed.
      service.back();
      await tester.pumpAndSettle();
      expect(find.byKey(TestScreen.keyFor('home')), findsOneWidget);
    });

    testWidgets('clearStackAndShow clears the backstack', (tester) async {
      await pumpApp(tester);
      unawaited(service.navigateTo(TestRoutes.second));
      await tester.pumpAndSettle();
      unawaited(service.navigateTo(TestRoutes.third));
      await tester.pumpAndSettle();

      unawaited(service.clearStackAndShow(TestRoutes.home));
      await tester.pumpAndSettle();

      expect(find.byKey(TestScreen.keyFor('home')), findsOneWidget);
      // Nothing left to pop.
      expect(
        StackedService.navigatorKey?.currentState?.canPop(),
        isFalse,
      );
    });

    testWidgets('navigateToView pushes a widget directly', (tester) async {
      await pumpApp(tester);

      unawaited(service.navigateToView(const TestScreen('inline')));
      await tester.pumpAndSettle();

      expect(find.byKey(TestScreen.keyFor('inline')), findsOneWidget);
    });

    testWidgets('navigateTo folds parameters into the route name',
        (tester) async {
      String? capturedName;
      await tester.pumpWidget(buildTestApp(
        onGenerateRoute: (settings) {
          capturedName = settings.name;
          return testOnGenerateRoute(settings);
        },
      ));
      await tester.pumpAndSettle();

      unawaited(service.navigateTo(
        TestRoutes.second,
        parameters: {'id': '42'},
      ));
      await tester.pumpAndSettle();

      expect(capturedName, contains('id=42'));
    });
  });
}
