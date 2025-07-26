import 'package:discuz_flutter/utility/PictureBedUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:settings_ui/settings_ui.dart';

import '../generated/l10n.dart';
import '../utility/AppPlatformIcons.dart';
import '../utility/URLUtils.dart';
import '../utility/VibrationUtils.dart';

class ConfigureChevertoPage extends StatefulWidget {
  ChevertoPictureBed chevertoPictureBed;

  ConfigureChevertoPage(this.chevertoPictureBed);

  @override
  State<StatefulWidget> createState() {
    return ConfigureChevertoState(this.chevertoPictureBed);
  }
}

class ConfigureChevertoState extends State<ConfigureChevertoPage> {
  ChevertoPictureBed chevertoPictureBed;

  ConfigureChevertoState(this.chevertoPictureBed);

  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // query for the state
    _loadToken();
    loadUrlInfo();
  }

  void _loadToken() async {
    String token =
        await PictureBedUtils.getChevertoApiToken(chevertoPictureBed);
    controller.text = token;
  }

  String termsOfUseUrl = "";
  String privacyPolicyUrl = "";

  void loadUrlInfo() {
    switch (chevertoPictureBed) {
      case ChevertoPictureBed.imgbb:
        {
          termsOfUseUrl = "https://imgbb.com/tos";
          privacyPolicyUrl = "https://imgbb.com/privacy";
        }
      case ChevertoPictureBed.imgloc:
        {
          termsOfUseUrl = "https://imgloc.com/page/tos";
          privacyPolicyUrl = "https://imgloc.com/page/privacy";
        }
    }
  }

  String getChevertoTitle() {
    switch (chevertoPictureBed) {
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
        title: Text(getChevertoTitle()),
      ),
      body: SafeArea(
        child: SettingsList(
          sections: [
            CustomSettingsSection(
                child: Padding(
                    padding: isCupertino(context)
                        ? EdgeInsets.symmetric(vertical: 4, horizontal: 16)
                        : EdgeInsets.zero,
                    child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        decoration: isCupertino(context)
                            ? BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Theme.of(context)
                                    .disabledColor
                                    .withValues(alpha: 0.1))
                            : null,
                        child: Padding(
                          padding: isCupertino(context)
                              ? EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 6)
                              : EdgeInsets.zero,
                          child: Column(
                            children: [
                              PlatformTextFormField(
                                controller: controller,
                                hintText: S.of(context).cheveretoApiKey,
                                material: (context, platform) {
                                  return MaterialTextFormFieldData(
                                    decoration: InputDecoration(
                                        labelText:
                                            S.of(context).cheveretoApiKey,
                                        prefixIcon: Icon(Icons.vpn_key),
                                        labelStyle: TextStyle(
                                            color: Theme.of(context)
                                                .disabledColor)),
                                  );
                                },
                                cupertino: (context, platform) {
                                  return CupertinoTextFormFieldData(
                                      prefix: Text(
                                          S.of(context).cheveretoApiKey,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .disabledColor)),
                                      decoration: BoxDecoration());
                                },
                                onChanged: (token) async {
                                  PictureBedUtils.setChevertoApiToken(
                                      chevertoPictureBed, token);
                                },
                              ),
                              Text(
                                S.of(context).cheveretoApiDescription,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        color: Theme.of(context).disabledColor),
                              )
                            ],
                          ),
                        )))),
            SettingsSection(
                title: Text(S.of(context).legalInformation),
                tiles: [
                  SettingsTile.navigation(
                    title: Text(S.of(context).termsOfService),
                    onPressed: (context) {
                      VibrationUtils.vibrateWithClickIfPossible();
                      URLUtils.launchURL(termsOfUseUrl);
                    },
                  ),
                  SettingsTile.navigation(
                    title: Text(S.of(context).privacyPolicy),
                    onPressed: (context) {
                      VibrationUtils.vibrateWithClickIfPossible();
                      URLUtils.launchURL(privacyPolicyUrl);
                    },
                  )
                ]),

          ],
        ),
      ),
    );
  }
}
