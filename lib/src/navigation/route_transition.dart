import 'package:flutter/material.dart';

enum Transition {
  fade,
  rightToLeft,
  leftToRight,
  upToDown,
  downToUp,
  rightToLeftWithFade,
  leftToRightWithFade,
  noTransition,
  zoom,
}

/// Applies the visual effect for [transition] to [child], driven by
/// [animation]. This is the native (get-free) replacement for the transitions
/// that the `get` package used to provide.
Widget applyTransition(
  Transition transition,
  Animation<double> animation,
  Curve curve,
  Widget child,
) {
  final curved = CurvedAnimation(parent: animation, curve: curve);

  Widget slide(Offset begin) => SlideTransition(
        position: Tween<Offset>(begin: begin, end: Offset.zero).animate(curved),
        child: child,
      );

  Widget slideWithFade(Offset begin) => FadeTransition(
        opacity: curved,
        child: slide(begin),
      );

  switch (transition) {
    case Transition.fade:
      return FadeTransition(opacity: curved, child: child);
    case Transition.rightToLeft:
      return slide(const Offset(1, 0));
    case Transition.leftToRight:
      return slide(const Offset(-1, 0));
    case Transition.upToDown:
      return slide(const Offset(0, -1));
    case Transition.downToUp:
      return slide(const Offset(0, 1));
    case Transition.zoom:
      return ScaleTransition(scale: curved, child: child);
    case Transition.rightToLeftWithFade:
      return slideWithFade(const Offset(1, 0));
    case Transition.leftToRightWithFade:
      return slideWithFade(const Offset(-1, 0));
    case Transition.noTransition:
      return child;
  }
}

/// Builds a [PageRouteBuilder] that renders [page] using the given [transition].
///
/// This is the native replacement for `Get.to`'s transition handling. The
/// transition argument map convention used by named navigation lives in
/// `RouteDataV1` (stacked) and is unaffected by this builder.
Route<T> buildTransitionRoute<T>(
  Widget page, {
  required Transition transition,
  Duration duration = const Duration(milliseconds: 300),
  bool opaque = true,
  bool fullscreenDialog = false,
  Curve curve = Curves.linear,
  RouteSettings? settings,
}) {
  return PageRouteBuilder<T>(
    settings: settings,
    opaque: opaque,
    fullscreenDialog: fullscreenDialog,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) =>
        applyTransition(transition, animation, curve, child),
  );
}
