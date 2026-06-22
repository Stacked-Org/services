import 'package:flutter/material.dart';

import 'stacked_routing.dart';

bool _isDialogRoute(Route? route) => route is RawDialogRoute;

bool _isBottomSheetRoute(Route? route) => route is ModalBottomSheetRoute;

bool _isPageRoute(Route? route) => route is PageRoute;

String? _extractRouteName(Route? route) {
  if (route?.settings.name != null) {
    return route!.settings.name;
  }

  if (_isDialogRoute(route)) {
    return 'DIALOG ${route.hashCode}';
  }

  if (_isBottomSheetRoute(route)) {
    return 'BOTTOMSHEET ${route.hashCode}';
  }

  return null;
}

class _RouteData {
  final bool isPageRoute;
  final bool isBottomSheet;
  final bool isDialog;
  final String? name;

  _RouteData({
    required this.name,
    required this.isPageRoute,
    required this.isBottomSheet,
    required this.isDialog,
  });

  factory _RouteData.ofRoute(Route? route) {
    return _RouteData(
      name: _extractRouteName(route),
      isPageRoute: _isPageRoute(route),
      isDialog: _isDialogRoute(route),
      isBottomSheet: _isBottomSheetRoute(route),
    );
  }
}

/// Observes navigation events and keeps a [StackedRouting] up to date so the
/// services can expose currentRoute / previousRoute / isDialogOpen, etc.
class StackObserver extends NavigatorObserver {
  StackObserver({StackedRouting? routing})
      : routing = routing ?? StackedRouting();

  final StackedRouting routing;

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    final newRoute = _RouteData.ofRoute(route);

    if (newRoute.isPageRoute) {
      routing.current = newRoute.name ?? '';
    }

    routing.args = route.settings.arguments;
    routing.route = route;
    routing.isBack = false;
    routing.removed = '';
    routing.previous = _extractRouteName(previousRoute) ?? '';
    routing.isBottomSheet =
        newRoute.isBottomSheet ? true : routing.isBottomSheet ?? false;
    routing.isDialog = newRoute.isDialog ? true : routing.isDialog ?? false;
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    final newRoute = _RouteData.ofRoute(previousRoute);

    if (_isPageRoute(previousRoute)) {
      routing.current = _extractRouteName(previousRoute) ?? '';
    }

    routing.args = route.settings.arguments;
    routing.route = previousRoute;
    routing.isBack = true;
    routing.removed = '';
    routing.previous = newRoute.name ?? '';
    routing.isBottomSheet = newRoute.isBottomSheet;
    routing.isDialog = newRoute.isDialog;
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    final newName = _extractRouteName(newRoute);
    final oldName = _extractRouteName(oldRoute);
    final currentRoute = _RouteData.ofRoute(oldRoute);

    if (_isPageRoute(newRoute)) {
      routing.current = newName ?? '';
    }

    routing.args = newRoute?.settings.arguments;
    routing.route = newRoute;
    routing.isBack = false;
    routing.removed = '';
    routing.previous = '$oldName';
    routing.isBottomSheet =
        currentRoute.isBottomSheet ? false : routing.isBottomSheet;
    routing.isDialog = currentRoute.isDialog ? false : routing.isDialog;
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    final routeName = _extractRouteName(route);
    final currentRoute = _RouteData.ofRoute(route);

    routing.route = previousRoute;
    routing.isBack = false;
    routing.removed = routeName ?? '';
    routing.previous = routeName ?? '';
    routing.isBottomSheet =
        currentRoute.isBottomSheet ? false : routing.isBottomSheet;
    routing.isDialog = currentRoute.isDialog ? false : routing.isDialog;
  }
}
