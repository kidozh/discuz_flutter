import 'package:discuz_flutter/page/ConfigureChevertoPage.dart';
import 'package:discuz_flutter/utility/AppPlatformIcons.dart';
import 'package:discuz_flutter/utility/PictureBedUtils.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:settings_ui/settings_ui.dart';

import '../generated/l10n.dart';

class ConfigurePictureBedPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ConfigurePictureBedState();
  }
}

class ConfigurePictureBedState extends State<ConfigurePictureBedPage> {
  String imglocToken = "";
  String smmsToken = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refreshImglocState();
  }

  Future<void> _refreshImglocState() async {
    String imglocTokenInSF =
        await PictureBedUtils.getChevertoApiToken(ChevertoPictureBed.imgloc);
    String smmsTokenInSF =
        await PictureBedUtils.getChevertoApiToken(ChevertoPictureBed.imgbb);
    if (!mounted) {
      return;
    }
    setState(() {
      imglocToken = imglocTokenInSF.trim();
      smmsToken = smmsTokenInSF.trim();
    });
  }

  Future<void> _openChevertoPage(ChevertoPictureBed pictureBed) async {
    await Navigator.of(context).push(platformPageRoute(
      iosTitle: _getPictureBedTitle(pictureBed),
      builder: (_) => ConfigureChevertoPage(pictureBed),
      context: context,
    ));
    await _refreshImglocState();
  }

  String _getPictureBedTitle(ChevertoPictureBed pictureBed) {
    switch (pictureBed) {
      case ChevertoPictureBed.imgbb:
        return S.of(context).pictureBedImgBB;
      case ChevertoPictureBed.imgloc:
        return S.of(context).pictureBedImgloc;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(S.of(context).pictureBedTitle),
      ),
      body: SafeArea(
        child: PlatformAdaptiveSettingsList(
          sections: [
            SettingsSection(
                title: Text(S.of(context).cheveretoPictureBed),
                tiles: [
                  SettingsTile.navigation(
                    //leading: PlatformCircularProgressIndicator(),
                    title: Text(S.of(context).pictureBedImgBB),
                    value: smmsToken == ""
                        ? Text(S.of(context).pictureBedNotPrepared)
                        : null,
                    onPressed: (context) async {
                      VibrationUtils.vibrateWithClickIfPossible();
                      bool isUserAcceptTerms =
                          await PictureBedUtils.isImgbbTermAccepted();
                      if (!isUserAcceptTerms) {
                        showPictureBedTermsModal(
                            ChevertoPictureBed.imgbb,
                            S.of(context).pictureBedImgBB,
                            "https://imgbb.com/tos",
                            "https://imgbb.com/privacy", () async {
                          VibrationUtils.vibrateWithClickIfPossible();
                          await PictureBedUtils.setImgbbTermAccepted(true);
                          Navigator.of(context).pop();
                          await _openChevertoPage(ChevertoPictureBed.imgbb);
                        });
                      } else {
                        _openChevertoPage(ChevertoPictureBed.imgbb);
                      }
                    },
                  ),
                  SettingsTile.navigation(
                    //leading: PlatformCircularProgressIndicator(),
                    title: Text(S.of(context).pictureBedImgloc),
                    value: imglocToken == ""
                        ? Text(S.of(context).pictureBedNotPrepared)
                        : null,
                    onPressed: (context) async {
                      VibrationUtils.vibrateWithClickIfPossible();
                      bool isUserAcceptTerms =
                          await PictureBedUtils.isImglocTermAccepted();
                      if (!isUserAcceptTerms) {
                        showPictureBedTermsModal(
                            ChevertoPictureBed.imgloc,
                            S.of(context).pictureBedImgloc,
                            "https://imgloc.com/page/tos",
                            "https://imgloc.com/page/privacy", () async {
                          VibrationUtils.vibrateWithClickIfPossible();
                          await PictureBedUtils.setImglocTermAccepted(true);
                          Navigator.of(context).pop();
                          await _openChevertoPage(ChevertoPictureBed.imgloc);
                        });
                      } else {
                        _openChevertoPage(ChevertoPictureBed.imgloc);
                      }
                    },
                  )
                ]),
            CustomSettingsSection(
                child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8)),
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: RichText(
                  text: TextSpan(children: [
                WidgetSpan(
                    child: Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(
                    AppPlatformIcons(context).errorOutline,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )),
                TextSpan(
                  text: S.of(context).pictureBedServiceNote,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontSize: 14),
                )
              ])),
            )),
          ],
        ),
      ),
    );
  }

  void showPictureBedTermsModal(
      ChevertoPictureBed chevertoPictureBed,
      String pictureBedName,
      String termsOfUseUrl,
      String privacyPolicyUrl,
      VoidCallback? onPressed) async {
    await showPlatformModalSheet(
        context: context,
        builder: (context) {
          return Container(
            color: usesLiquidGlass(context)
                ? Colors.transparent
                : Theme.of(context).dialogBackgroundColor,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      S.of(context).pictureBedTermsTitle(pictureBedName),
                      style: Theme.of(context).textTheme.headlineMedium
                        ?..copyWith(fontWeight: FontWeight.bold),
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
                      padding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 0),
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
