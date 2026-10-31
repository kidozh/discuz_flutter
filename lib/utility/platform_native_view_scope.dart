import 'package:flutter/widgets.dart';

/// Allows a host to keep its controls on Flutter's rendering surface without
/// changing the user's selected appearance or persisted preferences.
class PlatformNativeViewScope extends InheritedWidget {
  const PlatformNativeViewScope({
    required this.enabled,
    required super.child,
    super.key,
  });

  final bool enabled;

  static bool enabledOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<PlatformNativeViewScope>()
          ?.enabled ??
      true;

  @override
  bool updateShouldNotify(PlatformNativeViewScope oldWidget) =>
      enabled != oldWidget.enabled;
}
