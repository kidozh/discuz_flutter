import 'package:discuz_flutter/page/ConfigureChevertoPage.dart';
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
            SettingsSection(
              title: Text(S.of(context).cheveretoPictureBed),
                tiles: [
              SettingsTile.navigation(
                //leading: PlatformCircularProgressIndicator(),
                title: Text(S.of(context).pictureBedSMMS),
                value: Text(S.of(context).pictureBedNotPrepared),
                onPressed: (context) async {
                  VibrationUtils.vibrateWithClickIfPossible();
                  bool isUserAcceptTerms =
                      await PictureBedUtils.isSMMSTermAccepted();
                  if (!isUserAcceptTerms) {
                    showPictureBedTermsModal(
                        ChevertoPictureBed.smms,
                        S.of(context).pictureBedSMMS,
                        "https://smms.app/terms-of-use/",
                        "https://smms.app/privacy-policy/",
                            () {
                            VibrationUtils.vibrateWithClickIfPossible();
                            Navigator.of(context).push(platformPageRoute(
                              iosTitle: S.of(context).pictureBedSMMS,
                              builder: (_) => ConfigureChevertoPage(ChevertoPictureBed.smms),
                              context: context,
                            ));
                        }
                    );
                  }
                },
              ),
              SettingsTile.navigation(
                //leading: PlatformCircularProgressIndicator(),
                title: Text(S.of(context).pictureBedImgloc),
                value: Text(S.of(context).pictureBedNotPrepared),
                onPressed: (context) async {
                  VibrationUtils.vibrateWithClickIfPossible();
                  bool isUserAcceptTerms =
                  await PictureBedUtils.isSMMSTermAccepted();
                  if (!isUserAcceptTerms) {
                    showPictureBedTermsModal(
                        ChevertoPictureBed.imgloc,
                        S.of(context).pictureBedImgloc,
                        "https://imgloc.com/page/tos",
                        "https://imgloc.com/page/privacy",
                            () {
                          VibrationUtils.vibrateWithClickIfPossible();
                          Navigator.of(context).push(platformPageRoute(
                            iosTitle: S.of(context).pictureBedImgloc,
                            builder: (_) => ConfigureChevertoPage(ChevertoPictureBed.imgloc),
                            context: context,
                          ));
                        }
                    );
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

  void showPictureBedTermsModal(ChevertoPictureBed chevertoPictureBed,String pictureBedName, String termsOfUseUrl, String privacyPolicyUrl, VoidCallback? onPressed) async {
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
                      S.of(context).pictureBedTermsTitle(pictureBedName),
                      style: Theme.of(context).textTheme.headlineMedium?..copyWith(
                        fontWeight: FontWeight.bold
                      ),
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
                    //subtitle: Text("https://smms.app/terms-of-use/"),
                    subtitle: Text(termsOfUseUrl),
                    trailing: Icon(AppPlatformIcons(context).chevronSolid),
                    onTap: () {
                      VibrationUtils.vibrateWithClickIfPossible();
                      URLUtils.launchURL(termsOfUseUrl);
                    },
                  ),
                  PlatformListTile(
                    title: Text(S.of(context).privacyPolicy),
                    //subtitle: Text("https://smms.app/privacy-policy/"),
                    subtitle: Text(privacyPolicyUrl),
                    trailing: Icon(AppPlatformIcons(context).chevronSolid),
                    onTap: () {
                      VibrationUtils.vibrateWithClickIfPossible();
                      URLUtils.launchURL(privacyPolicyUrl);
                    },
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                      child: PlatformElevatedButton(
                        child: Text(S.of(context).pictureBedAgreeToService),
                        onPressed: onPressed,
                      ),
                    ),
                  )

                ],
              ),
            ),
          );
        });
  }
}
