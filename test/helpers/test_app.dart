import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';

/// Named routes used across the navigation tests.
class TestRoutes {
  static const String home = '/';
  static const String second = '/second';
  static const String third = '/third';
}

/// A simple screen that is uniquely identifiable both by [Key] and by text.
class TestScreen extends StatelessWidget {
  final String name;
  const TestScreen(this.name, {Key? key}) : super(key: key);

  static Key keyFor(String name) => Key('screen_$name');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: keyFor(name),
      body: Center(child: Text(name, key: Key('text_$name'))),
    );
  }
}

/// [onGenerateRoute] used by the test [MaterialApp] so that named navigation
/// (toNamed/offNamed/offAllNamed) resolves to deterministic screens.
Route<dynamic>? testOnGenerateRoute(RouteSettings settings) {
  final name = settings.name ?? TestRoutes.home;
  String screenName;
  switch (name) {
    case TestRoutes.home:
      screenName = 'home';
      break;
    case TestRoutes.second:
      screenName = 'second';
      break;
    case TestRoutes.third:
      screenName = 'third';
      break;
    default:
      screenName = 'unknown';
  }
  return MaterialPageRoute<dynamic>(
    builder: (_) => TestScreen(screenName),
    settings: settings,
  );
}

/// Builds a [MaterialApp] wired exactly like a consumer wires `stacked_services`:
/// using [StackedService.navigatorKey], [StackedService.routeObserver] and an
/// [onGenerateRoute] for named navigation.
///
/// This intentionally references the public `stacked_services` surface only, so
/// the same tests keep working before and after the `get` removal.
Widget buildTestApp({
  List<NavigatorObserver>? observers,
  String initialRoute = TestRoutes.home,
  Route<dynamic>? Function(RouteSettings)? onGenerateRoute,
}) {
  return MaterialApp(
    navigatorKey: StackedService.navigatorKey,
    navigatorObservers: observers ?? [StackedService.routeObserver],
    onGenerateRoute: onGenerateRoute ?? testOnGenerateRoute,
    initialRoute: initialRoute,
  );
}
