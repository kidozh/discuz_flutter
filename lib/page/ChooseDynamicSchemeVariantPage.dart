import 'dart:developer';

import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/ThemeNotifierProvider.dart';
import 'package:discuz_flutter/utility/AppPlatformIcons.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

class ChooseDynamicSchemeVariantPage extends StatefulWidget {
  @override
  _ChooseDynamicSchemeVariantState createState() => _ChooseDynamicSchemeVariantState();
}

class _ChooseDynamicSchemeVariantState extends State<ChooseDynamicSchemeVariantPage> {

  DynamicSchemeVariant _selectedDynamicSchemeVariant = DynamicSchemeVariant.fidelity;

  @override
  void initState() {
    super.initState();
    setState(() {
      _selectedDynamicSchemeVariant = Provider.of<ThemeNotifierProvider>(context,listen: false).dynamicSchemeVariant;

      log("Get dynamic scheme ${_selectedDynamicSchemeVariant}");
    });
  }

  @override
  Widget build(BuildContext context) {



    return PlatformScaffold(
      iosContentPadding: true,
      appBar: PlatformAppBar(
        title: Text(S.of(context).dynamicSchemeVariant),
      ),
      body: SettingsList(
        sections: [

          SettingsSection(tiles: [
            SettingsTile(
              title: Text(S.of(context).dynamicSchemeVariantTonalSpotKey),
              trailing: ( _selectedDynamicSchemeVariant == DynamicSchemeVariant.tonalSpot)
                  ? Icon(PlatformIcons(context).checkMark, color: Theme.of(context).colorScheme.primary)
                  : Icon(null),
              onPressed: (BuildContext context) {
                changeDynamicVariant(DynamicSchemeVariant.tonalSpot);
              },
            ),

            SettingsTile(
              title: Text(S.of(context).dynamicSchemeVariantFidelityKey),
              trailing: ( _selectedDynamicSchemeVariant == DynamicSchemeVariant.fidelity)
                  ? Icon(PlatformIcons(context).checkMark, color: Theme.of(context).colorScheme.primary)
                  : Icon(null),
              onPressed: (BuildContext context) {
                changeDynamicVariant(DynamicSchemeVariant.fidelity);
              },
            ),

            SettingsTile(
              title: Text(S.of(context).dynamicSchemeVariantMonochromeKey),
              trailing: ( _selectedDynamicSchemeVariant == DynamicSchemeVariant.monochrome)
                  ? Icon(PlatformIcons(context).checkMark, color: Theme.of(context).colorScheme.primary)
                  : Icon(null),
              onPressed: (BuildContext context) {
                changeDynamicVariant(DynamicSchemeVariant.monochrome);
              },
            ),

            SettingsTile(
              title: Text(S.of(context).dynamicSchemeVariantNeutralKey),
              trailing: ( _selectedDynamicSchemeVariant == DynamicSchemeVariant.neutral)
                  ? Icon(PlatformIcons(context).checkMark, color: Theme.of(context).colorScheme.primary)
                  : Icon(null),
              onPressed: (BuildContext context) {
                changeDynamicVariant(DynamicSchemeVariant.neutral);
              },
            ),

            SettingsTile(
              title: Text(S.of(context).dynamicSchemeVariantVibrantKey),
              trailing: ( _selectedDynamicSchemeVariant == DynamicSchemeVariant.vibrant)
                  ? Icon(PlatformIcons(context).checkMark, color: Theme.of(context).colorScheme.primary)
                  : Icon(null),
              onPressed: (BuildContext context) {
                changeDynamicVariant(DynamicSchemeVariant.vibrant);
              },
            ),

            SettingsTile(
              title: Text(S.of(context).dynamicSchemeVariantExpressiveKey),
              trailing: ( _selectedDynamicSchemeVariant == DynamicSchemeVariant.expressive)
                  ? Icon(PlatformIcons(context).checkMark, color: Theme.of(context).colorScheme.primary)
                  : Icon(null),
              onPressed: (BuildContext context) {
                changeDynamicVariant(DynamicSchemeVariant.expressive);
              },
            ),

            SettingsTile(
              title: Text(S.of(context).dynamicSchemeVariantContentKey),
              trailing: ( _selectedDynamicSchemeVariant == DynamicSchemeVariant.content)
                  ? Icon(PlatformIcons(context).checkMark, color: Theme.of(context).colorScheme.primary)
                  : Icon(null),
              onPressed: (BuildContext context) {
                changeDynamicVariant(DynamicSchemeVariant.content);
              },
            ),

            SettingsTile(
              title: Text(S.of(context).dynamicSchemeVariantRainbowKey),
              trailing: ( _selectedDynamicSchemeVariant == DynamicSchemeVariant.rainbow)
                  ? Icon(PlatformIcons(context).checkMark, color: Theme.of(context).colorScheme.primary)
                  : Icon(null),
              onPressed: (BuildContext context) {
                changeDynamicVariant(DynamicSchemeVariant.rainbow);
              },
            ),

            SettingsTile(
              title: Text(S.of(context).dynamicSchemeVariantFruitSaladKey),
              trailing: ( _selectedDynamicSchemeVariant == DynamicSchemeVariant.fruitSalad)
                  ? Icon(PlatformIcons(context).checkMark, color: Theme.of(context).colorScheme.primary)
                  : Icon(null),
              onPressed: (BuildContext context) {
                changeDynamicVariant(DynamicSchemeVariant.fruitSalad);
              },
            ),



            
          ]),

          SettingsSection(

              tiles: [
                if(isMaterial(context))
                  CustomSettingsTile(child: Divider()),
                SettingsTile(
                  leading: Icon(AppPlatformIcons(context).dynamicSchemeDescriptionOutlined),
                  title: Consumer<ThemeNotifierProvider>(
                    builder: (BuildContext context, ThemeNotifierProvider value, Widget? child) {
                      return Text(value.getDynamicSchemeVariantDescription(context));
                    },
                  ),
                ),
                if(_selectedDynamicSchemeVariant != DynamicSchemeVariant.fidelity)
                  SettingsTile(
                    leading: Icon(PlatformIcons(context).info),
                    title: Text(S.of(context).dynamicSchemeVariantNotification,style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary
                    )
                    ),
                  ),
                if(_selectedDynamicSchemeVariant == DynamicSchemeVariant.fidelity)
                  SettingsTile(
                    leading: Icon(PlatformIcons(context).checkMarkCircledOutline, color: Colors.green,),
                    title: Text(S.of(context).dynamicSchemeVariantFidelityNotification,style: TextStyle(
                        color: Colors.green
                    )
                    ),
                  ),
              ]
          ),
        ],
      ),
    );
  }

  void changeDynamicVariant(DynamicSchemeVariant dynamicSchemeVariant) {
    setState(() {
      _selectedDynamicSchemeVariant = dynamicSchemeVariant;
    });
    print("change dynamic scheme variant to $dynamicSchemeVariant");

    setState(() {
      _selectedDynamicSchemeVariant = dynamicSchemeVariant;
    });

    Provider.of<ThemeNotifierProvider>(context,listen: false).setDynamicSchemeVariant(dynamicSchemeVariant);
    UserPreferencesUtils.putInterfaceDynamicSchemeVariantPreference(dynamicSchemeVariant);

    VibrationUtils.vibrateSuccessfullyIfPossible();
  }
}