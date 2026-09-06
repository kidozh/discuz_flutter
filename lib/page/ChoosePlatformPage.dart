import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/ThemeNotifierProvider.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

class ChoosePlatformPage extends StatelessWidget {
  const ChoosePlatformPage({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedStyle = context.watch<ThemeNotifierProvider>().visualStyle;
    final strings = S.of(context);
    final supportsGlass = AppVisualStyle.supportsLiquidGlass;

    SettingsTile styleTile(
      AppVisualStyle style,
      String title,
      String description, {
      bool enabled = true,
    }) =>
        SettingsTile(
          key: ValueKey('appearance-${style.name}'),
          title: Text(title),
          description: Text(description),
          enabled: enabled,
          trailing: selectedStyle == style
              ? Icon(PlatformIcons(context).checkMark,
                  color: Theme.of(context).colorScheme.primary)
              : const SizedBox.shrink(),
          onPressed: enabled ? (_) => _changeStyle(context, style) : null,
        );

    return PlatformScaffold(
      iosContentPadding: true,
      appBar: PlatformAppBar(
        title: Text(strings.appearanceOptimizedPlatform),
      ),
      body: PlatformAdaptiveSettingsList(
        sections: [
          SettingsSection(tiles: [
            styleTile(AppVisualStyle.system, strings.followSystem,
                strings.systemStyleDescription),
            styleTile(
              AppVisualStyle.liquidGlass,
              strings.liquidGlassStyle,
              supportsGlass
                  ? strings.liquidGlassStyleDescription
                  : strings.liquidGlassStyleUnavailable,
              enabled: supportsGlass,
            ),
            styleTile(AppVisualStyle.cupertino, strings.cupertinoStyle,
                strings.cupertinoStyleDescription),
            styleTile(AppVisualStyle.material, strings.materialDesign,
                strings.materialStyleDescription),
          ]),
        ],
      ),
    );
  }

  void _changeStyle(BuildContext context, AppVisualStyle style) {
    if (style == AppVisualStyle.liquidGlass &&
        !AppVisualStyle.supportsLiquidGlass) {
      return;
    }
    context.read<ThemeNotifierProvider>().setPlatformName(style.preference);
    PlatformProvider.of(context)?.changeStyle(style);
    UserPreferencesUtils.putPlatformPreference(style.preference);
    VibrationUtils.vibrateSuccessfullyIfPossible();
  }
}
