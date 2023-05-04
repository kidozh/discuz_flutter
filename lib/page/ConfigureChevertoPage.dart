import 'package:discuz_flutter/utility/PictureBedUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:settings_ui/settings_ui.dart';

import '../generated/l10n.dart';

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
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(S.of(context).pictureBedTitle),
      ),
      body: SafeArea(
        child: SettingsList(
          sections: [
            CustomSettingsSection(
                child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                    child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        decoration: isCupertino(context)
                            ? BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Theme.of(context)
                                    .disabledColor
                                    .withOpacity(0.1))
                            : null,
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 16, horizontal: 6),
                          child: Column(
                            children: [
                              PlatformTextFormField(
                                controller: controller,
                                hintText: S.of(context).cheveretoApiKey,
                                material: (context, platform) {
                                  return MaterialTextFormFieldData(
                                    decoration: InputDecoration(
                                      labelText: S.of(context).cheveretoApiKey,
                                      prefixIcon: Icon(Icons.vpn_key),
                                    ),
                                  );
                                },
                                cupertino: (context, platform) {
                                  return CupertinoTextFormFieldData(
                                      prefix:
                                          Text(S.of(context).cheveretoApiKey),
                                      decoration: BoxDecoration());
                                },
                              ),
                              PlatformText(S.of(context).cheveretoApiDescription,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).disabledColor
                                ),
                              )
                            ],
                          ),
                        )
                    )
                )
            ),
            CustomSettingsSection(
                child: PlatformPopupMenu(
                  options: [
                    PopupMenuOption(label: 'One', ),
                    PopupMenuOption(label: 'Two',),
                    PopupMenuOption(label: 'Three',)
                  ],
                  icon: Icon(
                    context.platformIcon(
                      material: Icons.more_vert_rounded,
                      cupertino: CupertinoIcons.ellipsis,
                    ),
                  ),
                )
            )
          ],
        ),
      ),
    );
  }
}
