import 'package:flutter/material.dart';

import 'navigation/route_observer.dart';
import 'navigation/stacked_routing.dart';

/// This service exposes properties that is required to be set before any of the services can be used
class StackedService {
  const StackedService._();

  static final GlobalKey<NavigatorState> _navigatorKey =
      GlobalKey<NavigatorState>();

  /// The navigation key used by the application's [MaterialApp].
  static GlobalKey<NavigatorState>? get navigatorKey => _navigatorKey;

  static final Map<int, GlobalKey<NavigatorState>> _nestedNavigationKeys = {};

  /// Creates and/or returns a navigator key based on the index passed in
  static GlobalKey<NavigatorState>? nestedNavigationKey(int index) =>
      _nestedNavigationKeys.putIfAbsent(
          index, () => GlobalKey<NavigatorState>());

  /// The routing state maintained by [routeObserver]. Native replacement for
  /// `Get.routing`.
  static final StackedRouting routing = StackedRouting();

  /// Default navigation behaviour, configured through `NavigationService.config`.
  static final StackedNavigationConfig navigationConfig =
      StackedNavigationConfig();

  /// Returns the [NavigatorObserver] to be passed through navigatorObservers in
  /// MaterialApp to keep the routing state up to date.
  static NavigatorObserver get routeObserver => StackObserver(routing: routing);
}
