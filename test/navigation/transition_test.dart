import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:stacked_services/stacked_services.dart';

import '../helpers/test_app.dart';

/// Ensures every [Transition] value can drive a navigation that renders the
/// target view. After the `get` removal this guards the native
/// `buildTransitionRoute` implementation for all enum cases.
void main() {
  group('Transitions -', () {
    late NavigationService navigation;

    setUp(() {
      navigation = NavigationService();
    });

    Future<void> pumpApp(WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();
    }

    for (final transition in Transition.values) {
      testWidgets('navigateWithTransition (${transition.name}) shows the view',
          (tester) async {
        await pumpApp(tester);

        unawaited(navigation.navigateWithTransition(
          const TestScreen('inline'),
          transitionStyle: transition,
          duration: const Duration(milliseconds: 100),
        ));
        await tester.pumpAndSettle();

        expect(find.byKey(TestScreen.keyFor('inline')), findsOneWidget);

        navigation.back();
        await tester.pumpAndSettle();
        expect(find.byKey(TestScreen.keyFor('home')), findsOneWidget);
      });
    }

    testWidgets('navigateToView with transitionStyle shows the view',
        (tester) async {
      await pumpApp(tester);

      unawaited(navigation.navigateToView(
        const TestScreen('inline'),
        transitionStyle: Transition.fade,
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(TestScreen.keyFor('inline')), findsOneWidget);
    });
  });
}
