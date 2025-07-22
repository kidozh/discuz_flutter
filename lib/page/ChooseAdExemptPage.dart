import 'dart:developer';

import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/ThemeNotifierProvider.dart';
import 'package:discuz_flutter/utility/AdHelper.dart';
import 'package:discuz_flutter/utility/AppPlatformIcons.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

import '../dao/DiscuzDao.dart';
import '../database/AppDatabase.dart';
import '../entity/Discuz.dart';
import '../provider/UserPreferenceNotifierProvider.dart';

class ChooseAdExemptPage extends StatefulWidget {
  @override
  _ChooseAdExemptState createState() => _ChooseAdExemptState();
}

class _ChooseAdExemptState extends State<ChooseAdExemptPage> {
  String _selectedPlatformName = "";
  List<Discuz> _unWaivedDiscuzList = [];
  List<Discuz> _whiteDiscuzList = [];
  String _adExemptHost = "";

  late DiscuzDao _discuzDao;

  @override
  void initState() {
    super.initState();
    _initDiscuzList();
  }

  Future<void> _initDiscuzList() async {
    _discuzDao = await AppDatabase.getDiscuzDao();
    List<Discuz> discuzList = await _discuzDao.findAllDiscuzs();
    List<String> adWhiteList = AdHelper.adWhiteDiscuzHostList;
    _adExemptHost =
        Provider.of<UserPreferenceNotifierProvider>(context, listen: false)
            .adExemptHost;

    List<Discuz> unWaivedDiscuzList = [];
    List<Discuz> whiteDiscuzList = [];

    for (var discuz in discuzList) {
      if (adWhiteList.contains(discuz.host)) {
        whiteDiscuzList.add(discuz);
      } else {
        unWaivedDiscuzList.add(discuz);
      }
    }

    setState(() {
      _unWaivedDiscuzList = unWaivedDiscuzList;
      _whiteDiscuzList = whiteDiscuzList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      iosContentPadding: true,
      appBar: PlatformAppBar(
        title: Text(S.of(context).adExemptTitle),
      ),
      body: SettingsList(
        sections: [
          if (_unWaivedDiscuzList.isEmpty)
            CustomSettingsSection(
                child: Container(
              margin: EdgeInsets.all(16.0),
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).disabledColor.withOpacity(0.1),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: Text(
                S.of(context).adExemptNoNeedToConfirm,
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                  color: Theme.of(context).disabledColor,
                ),
              ),
            )),
          if (_unWaivedDiscuzList.isNotEmpty)
            SettingsSection(
                title: Text(S.of(context).adExemptNeedConfirm),
                tiles: _unWaivedDiscuzList
                    .map((discuz) => SettingsTile(
                          title: Text(discuz.siteName),
                          trailing: _adExemptHost == discuz.host
                              ? Icon(AppPlatformIcons(context).check)
                              : null,
                          onPressed: (context) {
                            VibrationUtils.vibrateWithClickIfPossible();
                            String adExemptHost = "";
                            if (_adExemptHost == discuz.host) {
                              adExemptHost = "";
                            } else {
                              adExemptHost = discuz.host;
                            }
                            setState(() {
                              _adExemptHost = adExemptHost;
                              log("Set advertisement ${_adExemptHost}");
                            });
                            UserPreferencesUtils
                                .putAdExemptDiscuzHostPreference(adExemptHost);
                            Provider.of<UserPreferenceNotifierProvider>(context,
                                    listen: false)
                                .adExemptHost = adExemptHost;
                          },
                        ))
                    .toList()),
          if (_whiteDiscuzList.isNotEmpty)
            SettingsSection(
                title: Text(S.of(context).adExemptEmbeddedList),
                tiles: _whiteDiscuzList
                    .map((discuz) => SettingsTile(
                        title: Text(discuz.siteName),
                        trailing: Icon(AppPlatformIcons(context)
                            .advertisementExemptCheckSolid),
                        onPressed: (context) {
                          VibrationUtils.vibrateWithClickIfPossible();
                          launchAdExemptDialog(discuz);
                        }))
                    .toList()),
        ],
      ),
    );
  }

  void launchAdExemptDialog(Discuz discuz){
    showPlatformModalSheet(context: context, builder: (context) => Container(
        color: Theme.of(context).dialogBackgroundColor,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(AppPlatformIcons(context).checkCircleOutlined, size: 32,),
              SizedBox(height: 16, width: double.infinity,),
              Text(S.of(context).discuzInAdExemptBuiltInList(discuz.siteName), style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18
              )
              ),
              SizedBox(height: 8, width: double.infinity,),
              Text(S.of(context).discuzInAdExemptBuiltInListDescription(discuz.siteName), style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 14
              )),
              SizedBox(height: 16, width: double.infinity,),
              SizedBox(
                width: double.infinity,
                child: PlatformElevatedButton(
                  color: Theme.of(context).colorScheme.primaryContainer,

                  child: Text(discuz.siteName, style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer
                  ),),
                  onPressed: (){
                    VibrationUtils.vibrateWithClickIfPossible();
                    URLUtils.launchURL(discuz.baseURL);
                  },
                ),
              )
            ],
          ),
        )
    ));
  }

  Widget trailingWidget(String platformName) {
    return (_selectedPlatformName == platformName)
        ? Icon(PlatformIcons(context).checkMark,
            color: Theme.of(context).colorScheme.primary)
        : Icon(null);
  }

  void changePlatform(String platformName) {
    setState(() {
      _selectedPlatformName = platformName;
    });
    print("change theme color to $platformName");

    Provider.of<ThemeNotifierProvider>(context, listen: false)
        .setPlatformName(platformName);
    UserPreferencesUtils.putPlatformPreference(platformName);

    if (PlatformProvider.of(context) != null) {
      switch (platformName) {
        case "":
          {
            PlatformProvider.of(context)!.changeToAutoDetectPlatform();
            break;
          }
        case "ios":
          {
            PlatformProvider.of(context)!.changeToCupertinoPlatform();
            break;
          }
        case "android":
          {
            PlatformProvider.of(context)!.changeToMaterialPlatform();
            break;
          }
      }
    }
    VibrationUtils.vibrateSuccessfullyIfPossible();
  }
}
