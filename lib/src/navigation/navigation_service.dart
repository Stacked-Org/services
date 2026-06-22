import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';

@Deprecated(
    'This will be deprecated in future release,Consider using Transition enum instead')
class NavigationTransition {
  static const String Fade = 'fade';
  static const String RightToLeft = 'righttoleft';
  static const String LeftToRight = 'lefttoright';
  static const String UpToDown = 'uptodown';
  static const String DownToUp = 'downtoup';
  static const String Rotate = 'zoom';
  static const String RightToLeftWithFade = 'righttoleftwithfade';
  static const String LeftToRighttWithFade = 'lefttorightwithfade';
  static const String NoTransition = 'noTransition';
}

/// Provides a service that can be injected into the ViewModels for navigation.
///
/// Uses the native Flutter [Navigator] through the [StackedService.navigatorKey].
class NavigationService {
  final Map<String, Transition> _transitions = {
    Transition.fade.name: Transition.fade,
    Transition.rightToLeft.name: Transition.rightToLeft,
    Transition.leftToRight.name: Transition.leftToRight,
    Transition.upToDown.name: Transition.upToDown,
    Transition.downToUp.name: Transition.downToUp,
    Transition.zoom.name: Transition.zoom,
    Transition.rightToLeftWithFade.name: Transition.rightToLeftWithFade,
    Transition.leftToRightWithFade.name: Transition.leftToRightWithFade,
    Transition.noTransition.name: Transition.noTransition,
  };

  /// Returns the navigator state for the given nested navigation [id], or the
  /// root navigator when [id] is null.
  NavigatorState? _navigator([int? id]) => (id != null
          ? StackedService.nestedNavigationKey(id)
          : StackedService.navigatorKey)
      ?.currentState;

  @Deprecated(
      'Prefer to use the StackedServices.navigatorKey instead of using this key. This will be removed in the next major version update for stacked.')
  GlobalKey<NavigatorState>? get navigatorKey => StackedService.navigatorKey;

  /// Returns the previous route
  String get previousRoute => StackedService.routing.previous;

  /// Returns the current route
  String get currentRoute => StackedService.routing.current;

  /// Returns the current arguments
  dynamic get currentArguments => StackedService.routing.args;

  /// Creates and/or returns a new navigator key based on the index passed in
  @Deprecated(
      'Prefer to use the StackedServices.nestedNavigationKey instead of using this property. This will be removed in the next major version update for stacked.')
  GlobalKey<NavigatorState>? nestedNavigationKey(int index) =>
      StackedService.nestedNavigationKey(index);

  /// Allows you to configure the default behaviour for navigation.
  ///
  /// [enableLog] and [defaultGlobalState] were specific to the `get` package and
  /// are now no-ops, kept for backwards compatibility.
  void config({
    bool? enableLog,
    bool? defaultPopGesture,
    bool? defaultOpaqueRoute,
    Duration? defaultDurationTransition,
    bool? defaultGlobalState,
    Transition? defaultTransitionStyle,
    @Deprecated(
        'Prefer to use the defaultTransitionStyle instead of using this property. This will be removed in the next major version update for stacked.')
    String? defaultTransition,
  }) {
    final config = StackedService.navigationConfig;
    if (defaultPopGesture != null) config.defaultPopGesture = defaultPopGesture;
    if (defaultOpaqueRoute != null) {
      config.defaultOpaqueRoute = defaultOpaqueRoute;
    }
    if (defaultDurationTransition != null) {
      config.defaultDuration = defaultDurationTransition;
    }
    config.defaultTransition = defaultTransitionStyle ??
        (defaultTransition != null
            ? _getTransitionOrDefault(defaultTransition)
            : config.defaultTransition);
  }

  /// Pushes [page] onto the navigation stack. This uses the [page] itself (Widget) instead
  /// of routeName (String).
  ///
  /// [id] is for when you are using nested navigation, as explained in documentation.
  ///
  /// [popGesture] is kept for backwards compatibility and is currently a no-op.
  ///
  /// [duration] transition duration.
  ///
  /// [opaque] Whether the route obscures previous routes when the transition is complete.
  ///
  /// [routeName] Name of the route to be pushed onto the navigation stack
  Future<T?>? navigateWithTransition<T>(
    Widget page, {
    bool? opaque,
    @Deprecated(
        'Prefer to use the transitionStyle instead of using this property. This will be removed in the next major version update for stacked.')
    String transition = '',
    Duration? duration,
    bool? popGesture,
    int? id,
    Curve? curve,
    bool fullscreenDialog = false,
    bool preventDuplicates = true,
    @Deprecated(
        'Prefer to use the transitionStyle instead of using this property. This will be removed in the next major version update for stacked.')
    Transition? transitionClass,
    Transition? transitionStyle,
    String? routeName,
  }) {
    if (preventDuplicates &&
        routeName != null &&
        routeName == StackedService.routing.current) {
      return null;
    }

    return _navigator(id)?.push<T?>(buildTransitionRoute<T?>(
      page,
      transition: transitionStyle ??
          transitionClass ??
          _getTransitionOrDefault(transition),
      duration: duration ?? StackedService.navigationConfig.defaultDuration,
      opaque: opaque ?? StackedService.navigationConfig.defaultOpaqueRoute,
      fullscreenDialog: fullscreenDialog,
      curve: curve ?? Curves.linear,
      settings: routeName != null ? RouteSettings(name: routeName) : null,
    ));
  }

  /// Replaces current view in the navigation stack. This uses the [page] itself (Widget) instead
  /// of routeName (String).
  ///
  /// [id] is for when you are using nested navigation, as explained in documentation.
  ///
  /// [popGesture] is kept for backwards compatibility and is currently a no-op.
  ///
  /// [duration] transition duration.
  ///
  /// [opaque] Whether the route obscures previous routes when the transition is complete.
  ///
  /// [routeName] Name of the route to be pushed onto the navigation stack
  Future<T?>? replaceWithTransition<T>(
    Widget page, {
    bool? opaque,
    @Deprecated(
        'Prefer to use the transitionStyle instead of using this property. This will be removed in the next major version update for stacked.')
    String transition = '',
    Duration? duration,
    bool? popGesture,
    int? id,
    Curve? curve,
    bool fullscreenDialog = false,
    bool preventDuplicates = true,
    @Deprecated(
        'Prefer to use the transitionStyle instead of using this property. This will be removed in the next major version update for stacked.')
    Transition? transitionClass,
    Transition? transitionStyle,
    String? routeName,
  }) {
    return _navigator(id)
        ?.pushReplacement<T?, dynamic>(buildTransitionRoute<T?>(
      page,
      transition: transitionStyle ??
          transitionClass ??
          _getTransitionOrDefault(transition),
      duration: duration ?? StackedService.navigationConfig.defaultDuration,
      opaque: opaque ?? StackedService.navigationConfig.defaultOpaqueRoute,
      fullscreenDialog: fullscreenDialog,
      curve: curve ?? Curves.linear,
      settings: routeName != null ? RouteSettings(name: routeName) : null,
    ));
  }

  /// Pops the current scope and indicates if you can pop again
  ///
  /// [result] is the data that will returned to the previous route
  /// you can use this feature to exchange data between two routes
  bool back<T>({dynamic result, int? id}) {
    final navigator = _navigator(id);
    navigator?.pop<T>(result);
    return navigator?.canPop() ?? false;
  }

  /// Pops the back stack until the predicate is satisfied
  ///
  /// [id] is for when you are using nested navigation, as explained in documentation.
  void popUntil(RoutePredicate predicate, {int? id}) {
    _navigator(id)?.popUntil(predicate);
  }

  /// Pops the back stack the number of times you indicate with [popTimes]
  void popRepeated(int popTimes) {
    final navigator = _navigator();
    for (var i = 0; i < popTimes; i++) {
      navigator?.pop();
    }
  }

  /// Pushes [routeName] onto the navigation stack
  ///
  /// [id] is for when you are using nested navigation, as explained in documentation.
  ///
  /// [preventDuplicates] will prevent you from pushing a route that you already in, if you want to push anyway,
  /// set to false.
  Future<T?>? navigateTo<T>(
    String routeName, {
    dynamic arguments,
    int? id,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    RouteTransitionsBuilder? transition,
  }) {
    if (preventDuplicates && routeName == StackedService.routing.current) {
      return null;
    }

    return _navigator(id)?.pushNamed<T?>(
      _routeNameWithParameters(routeName, parameters),
      arguments: transition != null
          ? {'arguments': arguments, 'transition': transition}
          : arguments,
    );
  }

  /// Pushes [view] onto the navigation stack
  ///
  /// [id] is for when you are using nested navigation, as explained in documentation.
  ///
  /// [popGesture] is kept for backwards compatibility and is currently a no-op.
  ///
  /// [duration] transition duration.
  ///
  /// [opaque] Whether the route obscures previous routes when the transition is complete.
  Future<T?>? navigateToView<T>(
    Widget view, {
    dynamic arguments,
    int? id,
    bool? opaque,
    Curve? curve,
    Duration? duration,
    bool fullscreenDialog = false,
    bool? popGesture,
    bool preventDuplicates = true,
    @Deprecated(
        'Prefer to use the transitionStyle instead of using this property. This will be removed in the next major version update for stacked.')
    Transition? transition,
    Transition? transitionStyle,
  }) {
    return _navigator(id)?.push<T?>(buildTransitionRoute<T?>(
      view,
      transition: transitionStyle ??
          transition ??
          StackedService.navigationConfig.defaultTransition,
      duration: duration ?? StackedService.navigationConfig.defaultDuration,
      opaque: opaque ?? StackedService.navigationConfig.defaultOpaqueRoute,
      fullscreenDialog: fullscreenDialog,
      curve: curve ?? Curves.linear,
      settings: RouteSettings(arguments: arguments),
    ));
  }

  /// Replaces the current route with the [routeName]
  ///
  /// [id] is for when you are using nested navigation, as explained in documentation.
  ///
  /// [preventDuplicates] will prevent you from pushing a route that you already in, if you want to push anyway,
  /// set to false.
  Future<T?>? replaceWith<T>(
    String routeName, {
    dynamic arguments,
    int? id,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    RouteTransitionsBuilder? transition,
  }) {
    if (preventDuplicates && routeName == StackedService.routing.current) {
      return null;
    }

    return _navigator(id)?.pushReplacementNamed<T?, dynamic>(
      _routeNameWithParameters(routeName, parameters),
      arguments: transition != null
          ? {'arguments': arguments, 'transition': transition}
          : arguments,
    );
  }

  /// Clears the entire back stack and shows [routeName]
  ///
  /// [id] is for when you are using nested navigation, as explained in documentation.
  Future<T?>? clearStackAndShow<T>(
    String routeName, {
    dynamic arguments,
    int? id,
    Map<String, String>? parameters,
  }) {
    return _navigator(id)?.pushNamedAndRemoveUntil<T?>(
      _routeNameWithParameters(routeName, parameters),
      (route) => false,
      arguments: arguments,
    );
  }

  /// Clears the entire back stack and shows [view]
  Future<T?>? clearStackAndShowView<T>(
    Widget view, {
    dynamic arguments,
    int? id,
  }) {
    return _navigator(id)?.pushAndRemoveUntil<T?>(
      buildTransitionRoute<T?>(
        view,
        transition: StackedService.navigationConfig.defaultTransition,
        duration: StackedService.navigationConfig.defaultDuration,
        opaque: StackedService.navigationConfig.defaultOpaqueRoute,
        settings: RouteSettings(arguments: arguments),
      ),
      (route) => false,
    );
  }

  /// Pops the navigation stack until there's 1 view left then pushes [routeName] onto the stack
  ///
  /// [id] is for when you are using nested navigation, as explained in documentation.
  ///
  /// [preventDuplicates] will prevent you from pushing a route that you already in, if you want to push anyway,
  /// set to false.
  Future<T?>? clearTillFirstAndShow<T>(
    String routeName, {
    dynamic arguments,
    int? id,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
  }) {
    _clearBackstackTillFirst();

    return navigateTo<T?>(
      routeName,
      arguments: arguments,
      id: id,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
    );
  }

  /// Pops the navigation stack until there's 1 view left then pushes [view] onto the stack
  ///
  /// [id] is for when you are using nested navigation, as explained in documentation.
  Future<T?>? clearTillFirstAndShowView<T>(Widget view,
      {dynamic arguments, int? id}) {
    _clearBackstackTillFirst();

    return navigateToView<T?>(view, arguments: arguments, id: id);
  }

  /// Push route and clear stack until predicate is satisfied
  ///
  /// [id] is for when you are using nested navigation, as explained in documentation.
  Future<T?>? pushNamedAndRemoveUntil<T>(String routeName,
      {RoutePredicate? predicate, dynamic arguments, int? id}) {
    return _navigator(id)?.pushNamedAndRemoveUntil<T?>(
      routeName,
      predicate ?? (route) => false,
      arguments: arguments,
    );
  }

  /// Pop repeatedly until reach the first route
  void _clearBackstackTillFirst() {
    StackedService.navigatorKey?.currentState
        ?.popUntil((Route route) => route.isFirst);
  }

  /// Folds [parameters] into [routeName] as a query string, matching the
  /// behaviour `get` used for named navigation with parameters.
  String _routeNameWithParameters(
    String routeName,
    Map<String, String>? parameters,
  ) {
    if (parameters == null) return routeName;
    return Uri(path: routeName, queryParameters: parameters).toString();
  }

  Transition _getTransitionOrDefault(String transition) {
    final _transition = transition.toLowerCase();
    return _transitions[_transition] ??
        StackedService.navigationConfig.defaultTransition;
  }
}
