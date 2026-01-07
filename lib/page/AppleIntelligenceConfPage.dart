import 'dart:developer';

import 'package:discuz_flutter/utility/AppPlatformIcons.dart';
import 'package:discuz_flutter/utility/PostTextFieldUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

import '../generated/l10n.dart';
import '../provider/UserPreferenceNotifierProvider.dart';
import '../utility/UserPreferencesUtils.dart';

class AppleIntelligenceConfPage extends StatefulWidget {
  @override
  AppleIntelligenceConfState createState() {
    return AppleIntelligenceConfState();
  }
}

class AppleIntelligenceConfState extends State<AppleIntelligenceConfPage> {
  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
        iosContentPadding: true,
        appBar: PlatformAppBar(
          title: Text(S.of(context).appleIntelligence),
          trailingActions: [
            PlatformIconButton(
              icon: Icon(AppPlatformIcons(context).addDiscuzSolid),
              onPressed: (){

              },
            )
          ],
        ),
        body: SettingsList(
          sections: [
            SettingsSection(
              tiles: [
                SettingsTile.switchTile(
                    initialValue: true,
                    onToggle: (value) {},
                    title: Text(S.of(context).appleIntelligenceEnabled)),
              ],

            ),
            SettingsSection(tiles: [
              SettingsTile.navigation(title: Text(S.of(context).account))
            ])
          ],
        ));
  }
}
