import 'package:flutter/widgets.dart';

/// Routes detail destinations into the pane's persistent navigator, including
/// on a compact display so expanding later restores the same page stack.
class PaneNavigationScope extends InheritedWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final bool isDetail;

  const PaneNavigationScope({
    super.key,
    required this.navigatorKey,
    this.isDetail = false,
    required super.child,
  });

  static PaneNavigationScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PaneNavigationScope>();

  @override
  bool updateShouldNotify(PaneNavigationScope oldWidget) =>
      navigatorKey != oldWidget.navigatorKey || isDetail != oldWidget.isDetail;
}

/// Use from either pane for profiles, settings and other detail destinations.
/// Outside a two-pane host this preserves the usual nearest-navigator behavior.
Future<T?> pushDetailPage<T>(BuildContext context, Route<T> route) {
  final scope = PaneNavigationScope.maybeOf(context);
  final navigator = scope?.navigatorKey.currentState ?? Navigator.of(context);
  return navigator.push<T>(route);
}
