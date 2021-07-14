import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/Post.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/ThemeNotifierProvider.dart';
import 'package:discuz_flutter/provider/TypeSettingNotifierProvider.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:discuz_flutter/widget/PostWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

class ChooseTypeSettingScalePage extends StatefulWidget {
  @override
  _ChooseTypeSettingScaleState createState() => _ChooseTypeSettingScaleState();
}

class _ChooseTypeSettingScaleState extends State<ChooseTypeSettingScalePage> {
  double _scalingParamter = 1.0;

  @override
  Widget build(BuildContext context) {
    _scalingParamter =
        Provider.of<TypeSettingNotifierProvider>(context, listen: false)
            .scalingParameter;
    Discuz mockedDiscuz = Discuz(
        0,
        "https://bbs.nwpu.edu.cn",
        "4",
        "utf8",
        4,
        "X1.8",
        "register",
        false,
        "false",
        "false",
        "MOCK",
        "452",
        "uCenterURL",
        "1");
    Post mockedPost = Post();
    mockedPost.authorId = 4;
    mockedPost.position = 12;
    mockedPost.message = S.of(context).largeRichText;
    mockedPost.author = S.of(context).largeRichTextDescription;

    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(S.of(context).fontSizeScaleParameter),
      ),
      body: Consumer<TypeSettingNotifierProvider>(
          builder: (context, typesetting, _) {
        return SettingsList(
          sections: [
            CustomSection(
                child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  height: 16.0,
                ),
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Icon(
                        Icons.format_size,
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.grey.shade600
                            : Colors.white,
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                            left: isCupertino(context) ? 0.0 : 16.0),
                        child: Text(
                          S.of(context).fontSizeScaleParameter,
                          style: TextStyle(fontSize: 16),
                        )),
                    Expanded(
                      child: Container(),
                      flex: 1,
                    ),
                    //Expanded(child: Spacer()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                          S.of(context).fontSizeScaleParameterUnit(
                              _scalingParamter.toStringAsFixed(3)),
                          style: TextStyle(
                              fontSize: 14, color: Colors.grey.shade600)),
                    )
                  ],
                ),
                SizedBox(
                  width: double.infinity,
                  child: PlatformSlider(
                    activeColor: Theme.of(context).primaryColor,
                    value: _scalingParamter,
                    min: 1.0,
                    max: 2.0,
                    onChanged: (value) {
                      changeScale(value);
                    },
                  ),
                )
              ],
            )),
            CustomSection(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    PostWidget(mockedDiscuz, mockedPost, 4),
                    PostWidget(mockedDiscuz, mockedPost, 5),
                    PostWidget(mockedDiscuz, mockedPost, 6)
                  ],
                ),
              ),
            )
          ],
        );
      }),
    );
  }

  void changeScale(double value) {
    setState(() {
      _scalingParamter = value.toDouble();
    });
    UserPreferencesUtils.putTypesettingScalePreference(_scalingParamter);
    Provider.of<TypeSettingNotifierProvider>(context, listen: false)
        .setScalingParameter(_scalingParamter);
  }
}
