import 'package:discuz_flutter/utility/AppPlatformIcons.dart';
import 'package:discuz_flutter/utility/PictureBedUtils.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:settings_ui/settings_ui.dart';

import '../generated/l10n.dart';

class ConfigurePictureBedPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ConfigurePictureBedState();
  }
}

class ConfigurePictureBedState extends State<ConfigurePictureBedPage> {
  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(S.of(context).pictureBedTitle),
      ),
      body: SafeArea(
        child: SettingsList(
          sections: [
            SettingsSection(tiles: [
              SettingsTile.navigation(
                //leading: PlatformCircularProgressIndicator(),
                title: Text(S.of(context).pictureBedSMMS),
                value: Text(S.of(context).pictureBedNotPrepared),
                onPressed: (context) async {
                  VibrationUtils.vibrateWithClickIfPossible();
                  bool isUserAcceptTerms =
                      await PictureBedUtils.isSMMSTermAccepted();
                  if (!isUserAcceptTerms) {
                    showSMMSTermsModal();
                  }
                },
              )
            ]),
            CustomSettingsSection(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Text(
                    S.of(context).pictureBedServiceNote,
                    style: Theme.of(context).textTheme.bodyMedium?..copyWith(
                      color: Theme.of(context).disabledColor
                    ),
                  ),

                )
            )
          ],
        ),
      ),
    );
  }

  void showSMMSTermsModal() async {
    await showPlatformModalSheet(
        context: context,
        builder: (context) {
          return Container(
            color: Theme.of(context).dialogBackgroundColor,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      S.of(context).pictureBedTermsTitle(S.of(context).pictureBedSMMS),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Text(S.of(context).pictureBedTermsSubtitle),
                  SizedBox(
                    height: 8,
                  ),
                  PlatformListTile(
                    title: Text(S.of(context).termsOfService),
                    subtitle: Text("https://smms.app/terms-of-use/"),
                    trailing: Icon(AppPlatformIcons(context).chevronSolid),
                    onTap: () {
                      VibrationUtils.vibrateWithClickIfPossible();
                      URLUtils.launchURL("https://smms.app/terms-of-use/");
                    },
                  ),
                  PlatformListTile(
                    title: Text(S.of(context).privacyPolicy),
                    subtitle: Text("https://smms.app/privacy-policy/"),
                    trailing: Icon(AppPlatformIcons(context).chevronSolid),
                    onTap: () {
                      VibrationUtils.vibrateWithClickIfPossible();
                      URLUtils.launchURL("https://smms.app/privacy-policy/");
                    },
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                    child: PlatformElevatedButton(
                      child: Text(S.of(context).pictureBedAgreeToService),
                      onPressed: () {
                        VibrationUtils.vibrateWithClickIfPossible();
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}
