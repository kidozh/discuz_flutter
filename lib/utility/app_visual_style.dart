import 'package:adaptive_platform_ui/adaptive_platform_ui.dart'
    show PlatformInfo;
import 'package:flutter/material.dart' show TargetPlatform;

/// Persist appearance separately from the device platform. Cupertino must not
/// implicitly opt into native Liquid Glass on a newer iOS release.
enum AppVisualStyle {
  system(''),
  liquidGlass('liquid_glass'),
  cupertino('cupertino'),
  material('android');

  const AppVisualStyle(this.preference);

  final String preference;

  static AppVisualStyle fromPreference(String value) => switch (value) {
        // The old iOS option enabled glass when available, not classic-only UI.
        'ios' || 'liquid_glass' => liquidGlass,
        'cupertino' => cupertino,
        'android' => material,
        _ => system,
      };

  // Device capabilities do not change during an app session. Avoid parsing
  // the OS version again for every card/control built while scrolling.
  static final bool supportsLiquidGlass = PlatformInfo.isIOS26OrHigher();

  AppVisualStyle get effective => resolve(
        isIOS: PlatformInfo.isIOS,
        supportsLiquidGlass: supportsLiquidGlass,
      );

  /// Keep this decision pure so older iOS, Android and unknown OS versions can
  /// all be tested without spoofing the host that creates native platform views.
  AppVisualStyle resolve({
    required bool isIOS,
    required bool supportsLiquidGlass,
  }) {
    final canUseGlass = isIOS && supportsLiquidGlass;
    return switch (this) {
      system => isIOS ? (canUseGlass ? liquidGlass : cupertino) : material,
      liquidGlass => canUseGlass ? liquidGlass : cupertino,
      cupertino || material => this,
    };
  }

  TargetPlatform get targetPlatform =>
      this == material ? TargetPlatform.android : TargetPlatform.iOS;
}
