import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stacked_services/stacked_services.dart';

void main() {
  group('StackedService -', () {
    test('navigatorKey is a non-null GlobalKey<NavigatorState>', () {
      expect(StackedService.navigatorKey, isA<GlobalKey<NavigatorState>>());
    });

    test('navigatorKey is stable across calls', () {
      expect(
        identical(StackedService.navigatorKey, StackedService.navigatorKey),
        isTrue,
      );
    });

    test('nestedNavigationKey returns a non-null key', () {
      expect(
        StackedService.nestedNavigationKey(1),
        isA<GlobalKey<NavigatorState>>(),
      );
    });

    test('routeObserver returns a NavigatorObserver', () {
      expect(StackedService.routeObserver, isA<NavigatorObserver>());
    });
  });
}
