import 'package:flutter/widgets.dart';

import 'route_transition.dart';

/// Holds the current navigation state, maintained by the `StackObserver`.
///
/// This is the native (get-free) replacement for `Get.routing`. The
/// [NavigationService] reads [current], [previous] and [args] from here, and
/// the dialog/bottom sheet services read [isDialog] / [isBottomSheet].
class StackedRouting {
  /// Name of the current page route.
  String current = '';

  /// Name of the previous route.
  String previous = '';

  /// Arguments of the most recent route.
  dynamic args;

  /// The most recent route involved in a navigation event.
  Route<dynamic>? route;

  /// Whether the last navigation event was a back navigation.
  bool isBack = false;

  /// Name of the route that was removed (for didRemove events).
  String removed = '';

  /// Whether a bottom sheet is currently open.
  bool? isBottomSheet;

  /// Whether a dialog is currently open.
  bool? isDialog;
}

/// Default navigation behaviour, configurable through
/// `NavigationService.config`. Native replacement for `Get.config`.
class StackedNavigationConfig {
  Transition defaultTransition = Transition.rightToLeft;
  Duration defaultDuration = const Duration(milliseconds: 300);
  bool defaultOpaqueRoute = true;
  bool defaultPopGesture = false;
}
