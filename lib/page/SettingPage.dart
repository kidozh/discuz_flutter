import 'package:discuz_flutter/utility/on_device_ai_labels.dart';
import 'package:discuz_flutter/utility/BugReportUtils.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/AppleIntelligenceConfPage.dart';
import 'package:discuz_flutter/page/ChooseAdExemptPage.dart';
import 'package:discuz_flutter/page/ChoosePlatformPage.dart';
import 'package:discuz_flutter/page/ChooseTypography.dart';
import 'package:discuz_flutter/page/DiscuzAuthenticationPage.dart';
import 'package:discuz_flutter/page/SelectSignatureStylePage.dart';
import 'package:discuz_flutter/provider/ThemeNotifierProvider.dart';
import 'package:discuz_flutter/provider/TypeSettingNotifierProvider.dart';
import 'package:discuz_flutter/provider/UserPreferenceNotifierProvider.dart';
import 'package:discuz_flutter/utility/AppPlatformIcons.dart';
import 'package:discuz_flutter/utility/OnDeviceAiService.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/utility/PostTextFieldUtils.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import 'ChooseThemeColorPage.dart';
import 'ConfigurePictureBedPage.dart';
import 'SetPushNotificationPage.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool recordHistory = false;
  bool hapticFeedback = true;
  String packageVersion = '';
  String packageBuildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      packageVersion = packageInfo.version;
      packageBuildNumber = packageInfo.buildNumber;
    });
  }

  Future<void> _loadPreferences() async {
    final history = await UserPreferencesUtils.getRecordHistoryEnabled();
    final haptics = await UserPreferencesUtils.getHapticFeedbackPreference();
    if (!mounted) return;
    setState(() {
      recordHistory = history;
      hapticFeedback = haptics;
    });
  }

  String _intelligenceStatusText(
    BuildContext context,
    UserPreferenceNotifierProvider preference,
  ) {
    if (!preference.appleIntelligenceAvailabilityChecked) {
      return S.of(context).pushNotificationOff;
    }
    return switch (preference.onDeviceAiStatus) {
      OnDeviceAiAvailabilityStatus.available =>
        preference.appleIntelligenceEnabled
            ? S.of(context).pushNotificationOn
            : S.of(context).pushNotificationOff,
      OnDeviceAiAvailabilityStatus.downloadable ||
      OnDeviceAiAvailabilityStatus.needsAICoreUpdate ||
      OnDeviceAiAvailabilityStatus.needsSystemUpdate ||
      OnDeviceAiAvailabilityStatus.notEnoughStorage =>
        S.of(context).onDeviceAiSetupRequired,
      OnDeviceAiAvailabilityStatus.downloading =>
        S.of(context).onDeviceAiStatusDownloading,
      OnDeviceAiAvailabilityStatus.temporarilyUnavailable =>
        S.of(context).onDeviceAiTemporarilyUnavailableTitle,
      _ => S.of(context).appleIntelligenceNotSupported,
    };
  }

  @override
  Widget build(BuildContext context) => PlatformScaffold(
        appBar: PlatformAppBar(
          liquidGlassTitle: S.of(context).settingTitle,
          title: Text(S.of(context).settingTitle),
          // Avoid snapshot artifacts from a native UIKit platform view during
          // the interactive back transition on this frequently-opened route.
          liquidGlassUseNativeToolbar: false,
        ),
        iosContentPadding: true,
        body: _buildSettingsList(context),
      );

  Widget _buildSettingsList(BuildContext context) {
    final theme = context.watch<ThemeNotifierProvider>();
    final typeSetting = context.watch<TypeSettingNotifierProvider>();
    final preference = context.watch<UserPreferenceNotifierProvider>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 32),
      children: [
        _GlassSettingsSection(
          title: S.of(context).securityTitle,
          children: [
            _GlassNavigationTile(
              title: S.of(context).discuzAuthenticationTitle,
              leading: Icon(
                AppPlatformIcons(context).authenticationSecureOutline,
              ),
              onTap: () => _open(
                context,
                S.of(context).discuzAuthenticationTitle,
                DiscuzAuthenticationPage(),
              ),
            ),
            _GlassNavigationTile(
              title: OnDeviceAiLabels.name(S.of(context)),
              leading: Icon(AppPlatformIcons(context).aiModel),
              value: Text(_intelligenceStatusText(context, preference)),
              onTap: () => _open(
                context,
                OnDeviceAiLabels.name(S.of(context)),
                AppleIntelligenceConfPage(),
              ),
            ),
          ],
        ),
        _GlassSettingsSection(
          title: S.of(context).common,
          children: [
            _GlassSwitchTile(
              title: S.of(context).recordHistoryTitle,
              leading: Icon(AppPlatformIcons(context).historyOutlined),
              value: recordHistory,
              onChanged: (value) {
                VibrationUtils.vibrateWithSwitchIfPossible();
                UserPreferencesUtils.putRecordHistoryEnabled(value);
                setState(() => recordHistory = value);
              },
            ),
            _GlassNavigationTile(
              title: S.of(context).pushNotification,
              leading: Icon(AppPlatformIcons(context).pushServiceOutlined),
              value: Text(
                preference.allowPush
                    ? S.of(context).pushNotificationOn
                    : S.of(context).pushNotificationOff,
              ),
              onTap: () => _open(
                context,
                S.of(context).pushNotification,
                SetPushNotificationPage(),
              ),
            ),
          ],
        ),
        _GlassSettingsSection(
          title: S.of(context).displaySettingTitle,
          children: [
            _GlassNavigationTile(
              title: S.of(context).chooseThemeTitle,
              value: Text(_themeColorLabel(context, theme)),
              leading: Icon(AppPlatformIcons(context).appThemeOutlined),
              onTap: () => _open(
                context,
                S.of(context).chooseThemeTitle,
                ChooseThemeColorPage(),
              ),
            ),
            _GlassNavigationTile(
              title: S.of(context).appearanceOptimizedPlatform,
              value: Text(theme.getPlatformLocaleName(context)),
              leading: Icon(AppPlatformIcons(context).appAppearanceOutlined),
              onTap: () => _open(
                context,
                S.of(context).appearanceOptimizedPlatform,
                ChoosePlatformPage(),
              ),
            ),
            _GlassNavigationTile(
              title: S.of(context).typeSetting,
              value: Text(
                S.of(context).fontSizeScaleParameterUnit(
                      typeSetting.scalingParameter.toStringAsFixed(3),
                    ),
              ),
              leading: Icon(AppPlatformIcons(context).typeSettingOutlined),
              onTap: () => _open(
                context,
                S.of(context).typeSetting,
                ChooseTypeSettingScalePage(),
              ),
            ),
          ],
        ),
        _GlassSettingsSection(
          title: S.of(context).post,
          children: [
            _GlassNavigationTile(
              title: S.of(context).signatureStyle,
              leading: Icon(AppPlatformIcons(context).signatureOutlined),
              value: Text(_signatureLabel(context, preference.signature)),
              onTap: () => _open(
                context,
                S.of(context).customSignature,
                SelectSignatureStylePage(),
              ),
            ),
            if (preference.signature == PostTextFieldUtils.USE_APP_SIGNATURE)
              _GlassNavigationTile(
                title: S.of(context).adExemptTitle,
                leading: Icon(
                  AppPlatformIcons(context).advertisementExemptSolid,
                ),
                value: Text(preference.adExemptHost),
                onTap: () => _open(
                  context,
                  S.of(context).adExemptTitle,
                  ChooseAdExemptPage(),
                ),
              ),
            _GlassNavigationTile(
              title: S.of(context).pictureBedTitle,
              leading: Icon(AppPlatformIcons(context).pictureBedOutlined),
              onTap: () => _open(
                context,
                S.of(context).pictureBedTitle,
                ConfigurePictureBedPage(),
              ),
            ),
          ],
        ),
        _GlassSettingsSection(
          title: S.of(context).feedbackTitle,
          children: [
            _GlassSwitchTile(
              title: S.of(context).hapticFeedbackTitle,
              leading: Icon(AppPlatformIcons(context).hapticFeedbackOutlined),
              value: hapticFeedback,
              onChanged: (value) {
                if (value) VibrationUtils.vibrateWithClickIfPossible();
                UserPreferencesUtils.putHapticFeedbackPreference(value);
                setState(() => hapticFeedback = value);
              },
            ),
          ],
        ),
        _GlassSettingsSection(
          title: S.of(context).legalInformation,
          children: [
            _GlassNavigationTile(
              title: S.of(context).reportIssueSettingsTitle,
              leading: Icon(PlatformIcons(context).errorOutline),
              onTap: () => BugReportUtils.openIssuePage(context),
            ),
            _GlassNavigationTile(
              title: S.of(context).termsOfService,
              leading: Icon(AppPlatformIcons(context).privacyPolicyOutlined),
              onTap: () {
                VibrationUtils.vibrateWithClickIfPossible();
                URLUtils.launchURL(
                  'https://discuzhub.kidozh.com/term_of_use/',
                );
              },
            ),
            _GlassNavigationTile(
              title: S.of(context).privacyPolicy,
              leading: Icon(AppPlatformIcons(context).termsOfServiceOutlined),
              onTap: () {
                VibrationUtils.vibrateWithClickIfPossible();
                URLUtils.launchURL(
                  'https://discuzhub.kidozh.com/privacy_policy/',
                );
              },
            ),
            _GlassNavigationTile(
              title: S.of(context).openSoftwareTitle,
              leading: Icon(PlatformIcons(context).bookmark),
              onTap: () {
                VibrationUtils.vibrateWithClickIfPossible();
                showLicensePage(
                  useRootNavigator: true,
                  context: context,
                  applicationName: S.of(context).appName,
                  applicationIcon: const Image(
                    image: AssetImage('assets/images/icon-large.png'),
                    width: 64,
                  ),
                  applicationVersion: packageVersion,
                );
              },
            ),
          ],
        ),
        PlatformCard(
          margin: const EdgeInsets.fromLTRB(4, 4, 4, 0),
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            children: [
              const Image(
                image: AssetImage('assets/images/icon-large.png'),
                width: 64,
              ),
              const SizedBox(height: 8),
              Text(
                S.of(context).buildVersionDescription(
                      packageVersion,
                      packageBuildNumber,
                    ),
                style: TextStyle(color: Theme.of(context).disabledColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _signatureLabel(BuildContext context, String signature) {
    if (signature == PostTextFieldUtils.NO_SIGNATURE) {
      return S.of(context).noSignature;
    }
    if (signature == PostTextFieldUtils.USE_DEVICE_SIGNATURE) {
      return S.of(context).deviceNameSignature;
    }
    if (signature == PostTextFieldUtils.USE_APP_SIGNATURE) {
      return S.of(context).signatureWithDisFly;
    }
    return S.of(context).customSignature;
  }

  String _themeColorLabel(
    BuildContext context,
    ThemeNotifierProvider theme,
  ) {
    final customColor = theme.customThemeColor;
    if (customColor != null) {
      return S.of(context).customColorNamed(
            localizedCustomColorName(context, customColor),
          );
    }
    return localizedFlexSchemeName(context, theme.themeColor);
  }

  void _open(BuildContext context, String title, Widget page) {
    VibrationUtils.vibrateWithClickIfPossible();
    Navigator.of(context).push(
      platformPageRoute(
        iosTitle: title,
        builder: (_) => page,
        context: context,
      ),
    );
  }
}

class _GlassSettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _GlassSettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
              child: Text(
                title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            PlatformCard(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  for (var index = 0; index < children.length; index++) ...[
                    children[index],
                    if (index < children.length - 1 &&
                        !usesLiquidGlass(context))
                      Divider(
                        height: 1,
                        indent: 54,
                        color: Theme.of(context)
                            .dividerColor
                            .withValues(alpha: 0.35),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
}

class _GlassNavigationTile extends StatelessWidget {
  final String title;
  final Widget leading;
  final Widget? value;
  final VoidCallback onTap;

  const _GlassNavigationTile({
    required this.title,
    required this.leading,
    required this.onTap,
    this.value,
  });

  @override
  Widget build(BuildContext context) => PlatformListTile(
        leading: IconTheme.merge(
          data: IconThemeData(color: Theme.of(context).colorScheme.primary),
          child: leading,
        ),
        title: Text(title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (value != null)
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 170),
                child: DefaultTextStyle.merge(
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  child: value!,
                ),
              ),
            const SizedBox(width: 6),
            Icon(PlatformIcons(context).forward, size: 18),
          ],
        ),
        onTap: onTap,
      );
}

class _GlassSwitchTile extends StatelessWidget {
  final String title;
  final Widget leading;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _GlassSwitchTile({
    required this.title,
    required this.leading,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => PlatformListTile(
        leading: IconTheme.merge(
          data: IconThemeData(color: Theme.of(context).colorScheme.primary),
          child: leading,
        ),
        title: Text(title),
        trailing: PlatformSwitch(
          value: value,
          activeColor: Theme.of(context).colorScheme.primary,
          onChanged: onChanged,
        ),
        onTap: () => onChanged(!value),
      );
}
