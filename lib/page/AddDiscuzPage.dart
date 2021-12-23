import 'dart:convert';
import 'dart:developer';

import 'package:discuz_flutter/JsonResult/CheckResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/utility/DBHelper.dart';
import 'package:discuz_flutter/utility/GlobalTheme.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:discuz_flutter/widget/ErrorCard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:dio/dio.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:form_validator/form_validator.dart';
import 'package:provider/provider.dart';

class AddDiscuzPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
        iosContentBottomPadding: true,
        iosContentPadding: true,
        appBar: PlatformAppBar(
          title: Text(S.of(context).addDiscuzTitle),
        ),
        body: AddDiscuzForumFieldStatefulWidget());
  }
}

class AddDiscuzForumFieldStatefulWidget extends StatefulWidget {
  AddDiscuzForumFieldStatefulWidget({Key? key}):super(key: key);
  @override
  _AddDiscuzFormFieldState createState() {
    return _AddDiscuzFormFieldState();
  }
}

class _AddDiscuzFormFieldState
    extends State<AddDiscuzForumFieldStatefulWidget> {
  final _formKey = GlobalKey<FormState>();
  CheckResult? _checkResult;
  String error = "";
  bool _isLoading = false;
  final TextEditingController _urlController = new TextEditingController();

  Future<void> _saveDiscuzInDb(Discuz discuz) async {
    final db = await DBHelper.getAppDb();
    final dao = db.discuzDao;
    int insertId = await dao.insertDiscuz(discuz);
    Discuz selectedDiscuz = Discuz(
      insertId,
      discuz.baseURL,
      discuz.discuzVersion,
      discuz.charset,
      discuz.apiVersion,
      discuz.pluginVersion,
      discuz.regname,
      discuz.qqconnect,
      discuz.wsqqqconnect,
      discuz.wsqhideregister,
      discuz.siteName,
      discuz.siteId,
      discuz.uCenterURL,
      discuz.defaultFid
    );
    Provider.of<DiscuzAndUserNotifier>(context, listen: false).setDiscuz(selectedDiscuz);
    Provider.of<DiscuzAndUserNotifier>(context, listen: false).setUser(null);
    // pop the activity
    EasyLoading.showToast(S.of(context).addDiscuzSuccessfully(discuz.siteName));
    Navigator.pop(context);
  }

  void _checkApiAvailable() {
    String discuzUrl = _urlController.text;
    log("Recv url " + discuzUrl);
    // check the availability
    final dio = Dio();
    final client = MobileApiClient(dio, baseUrl: discuzUrl);
    setState(() {
      _isLoading = true;
    });
    client.getCheckResultInString().then((value) {
      setState(() {
        _isLoading = false;
      });
      log(value.toString());
      // convert string to json
      Map<String, dynamic> checkResultJson = jsonDecode(value);
      CheckResult checkResult = CheckResult.fromJson(checkResultJson);
      log(checkResult.toString());
      setState(() {
        _checkResult = _checkResult;
        error = "";
      });
      _saveDiscuzInDb(checkResult.toDiscuz(discuzUrl));
    }).catchError((onError) {
      VibrationUtils.vibrateErrorIfPossible();
      setState(() {
        _isLoading = false;
      });
      switch (onError.runtimeType) {
        case DioError:
          {
            error = onError.message;
            break;
          }
        default:
          {
            setState(() {
              error = onError.toString();
            });
          }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(4.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // title and page
                if (_isLoading)
                  LinearProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(
                        GlobalTheme.getThemeData().primaryColor),
                  ),
                Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: SvgPicture.asset(
                        "assets/images/add-a-new-discuz-site.svg",
                        semanticsLabel: '论坛的图形标识',
                        allowDrawingOutsideViewBox: true,
                        width: MediaQuery.of(context).size.width * 0.5,
                      ),
                    )),
                // input fields
                new TextFormField(
                  controller: _urlController,
                  onFieldSubmitted: (text){
                    if (_formKey.currentState!.validate()) {
                      EasyLoading.showToast(S.of(context).connectServerWhenAdding);
                      _checkApiAvailable();
                    } else {
                      EasyLoading.showError(S.of(context).incorrectDiscuzAddress);
                    }
                  },
                  decoration: new InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: S.of(context).discuzServerAddress,
                    hintText: S.of(context).discuzServerAddressHint,
                    helperText: S.of(context).discuzServerAddressHelperText,
                    prefixIcon: Icon(Icons.web),

                  ),
                  validator: ValidationBuilder().url().build(),
                ),
                if (error.isNotEmpty)
                  Column(
                    children: [
                      ErrorCard("发生错误", error,(){
                        _checkApiAvailable();
                      }),
                    ],
                  ),
                SizedBox(height: 32.0,),
                SizedBox(
                  width: double.infinity,
                  child: PlatformElevatedButton(
                    child: Text(S.of(context).continueAdding),
                    onPressed: (){
                      VibrationUtils.vibrateWithClickIfPossible();
                      if (_formKey.currentState!.validate()) {
                        EasyLoading.showToast(S.of(context).connectServerWhenAdding);
                        _checkApiAvailable();
                      } else {
                        EasyLoading.showError(S.of(context).incorrectDiscuzAddress);
                      }
                    },
                  ),
                ),
              ],
            ),
          )),
        );
  }
}
