import 'package:get/get.dart' as G;

enum TransitionStyle {
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

extension ToGetTransition on TransitionStyle {
  G.Transition get toGet {
    switch (this) {
      case TransitionStyle.fade:
        return G.Transition.fade;
      case TransitionStyle.leftToRight:
        return G.Transition.leftToRight;
      case TransitionStyle.rightToLeft:
        return G.Transition.rightToLeft;
      case TransitionStyle.upToDown:
        return G.Transition.upToDown;
      case TransitionStyle.downToUp:
        return G.Transition.downToUp;
      case TransitionStyle.zoom:
        return G.Transition.zoom;
      case TransitionStyle.leftToRightWithFade:
        return G.Transition.leftToRightWithFade;
      case TransitionStyle.rightToLeftWithFade:
        return G.Transition.rightToLeftWithFade;
      case TransitionStyle.noTransition:
        return G.Transition.noTransition;

      default:
        return G.Transition.rightToLeft;
    }
  }
}
