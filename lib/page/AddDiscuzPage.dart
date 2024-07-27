import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:discuz_flutter/JsonResult/CheckResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:discuz_flutter/widget/ErrorCard.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:form_validator/form_validator.dart';
import 'package:provider/provider.dart';

import '../entity/DiscuzError.dart';
import '../utility/AppPlatformIcons.dart';
import '../utility/URLUtils.dart';

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
  DiscuzError? error = null;
  bool _isLoading = false;
  final TextEditingController _urlController = new TextEditingController(text: "https://");

  bool _reportDiscuzResultToAnalytics = true;

  Future<void> _saveDiscuzInDb(Discuz discuz) async {

    final dao = await AppDatabase.getDiscuzDao();
    int insertId = await dao.insertDiscuz(discuz);
    if(dao.getDiscuzByIndex(insertId)!=null){
      discuz = dao.getDiscuzByIndex(insertId)!;
    }

    Provider.of<DiscuzAndUserNotifier>(context, listen: false).setDiscuz(discuz);
    Provider.of<DiscuzAndUserNotifier>(context, listen: false).setUser(null);
    // pop the activity
    if(_reportDiscuzResultToAnalytics){
      log("Send Discuz report to Google analytics");
      await FirebaseAnalytics.instance.logEvent(
        name: "discuz_add",
        parameters: {
          "url": discuz.host,
          "sitename": discuz.siteName,
          "full_result": discuz.toString()
        },
      );
      await FirebaseAnalytics.instance.logSelectContent(
        contentType: "discuz",
        itemId: discuz.host
      );
    }


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
        error = null;
      });
      _saveDiscuzInDb(checkResult.toDiscuz(discuzUrl));
    }).catchError((onError) {
      VibrationUtils.vibrateErrorIfPossible();
      setState(() {
        _isLoading = false;
      });
      if(onError is DioException){
        //log("GET ADD discuz error ${onError}");
        DioException dioError = onError;
        error = DiscuzError(dioError.type.name, dioError.message==null?S.of(context).error: dioError.message!, dioError: dioError);
      }
      else{
        //log("GET ADD discuz error NOT in DIO ${onError}");
        setState(() {
          error = DiscuzError("", onError.toString());
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 32),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // input fields
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: isCupertino(context)
                        ? BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color:
                        Theme.of(context).disabledColor.withOpacity(0.1))
                        : null,
                  child: PlatformTextFormField(
                    controller: _urlController,
                    onFieldSubmitted: (text){
                      if (_formKey.currentState!.validate()) {
                        EasyLoading.showToast(S.of(context).connectServerWhenAdding);
                        _checkApiAvailable();
                      } else {
                        EasyLoading.showError(S.of(context).incorrectDiscuzAddress);
                      }
                    },
                    hintText: S.of(context).discuzServerAddressHint,
                    material: (context, platform) {
                      return MaterialTextFormFieldData(
                        decoration: InputDecoration(
                          labelText: S.of(context).discuzServerAddress,
                          hintText: S.of(context).discuzServerAddressHint,
                          helperText: S.of(context).discuzServerAddressHelperText,
                          //prefixIcon: Icon(Icons.web),
                        ),
                      );
                    },
                    cupertino: (context, platform) {
                      return CupertinoTextFormFieldData(
                          //prefix: Text(S.of(context).discuzServerAddress),
                          decoration: BoxDecoration());
                    },
                    // decoration: new InputDecoration(
                    //   border: OutlineInputBorder(),
                    //   labelText: S.of(context).discuzServerAddress,
                    //   hintText: S.of(context).discuzServerAddressHint,
                    //   helperText: S.of(context).discuzServerAddressHelperText,
                    //   prefixIcon: Icon(Icons.web),
                    //
                    // ),
                    validator: ValidationBuilder().required().url().build(),
                  ),
                ),

                if (error!=null)
                  Column(
                    children: [
                      ErrorCard(error!,(){
                        _checkApiAvailable();
                      }, largeSize: false,),
                      SizedBox(height: 16.0,),
                    ],
                  ),
                // SizedBox(height: 32.0,),

                Padding(
                    padding:
                    EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    child: Row(children: [
                      Expanded(
                          child: RichText(
                            text: TextSpan(
                                style: Theme.of(context).textTheme.bodyMedium,
                                text:S.of(context).reportDiscuzApiInformationToAnalytics,
                                children: [
                                  TextSpan(
                                      text: " "+S.of(context).rememberPasswordInAppDetail,
                                      style: TextStyle(color: Theme.of(context).colorScheme.primary),
                                      recognizer: TapGestureRecognizer()..onTap = (){
                                        VibrationUtils.vibrateWithClickIfPossible();
                                        _showReportToAnalyticsDialog();
                                      }
                                  )
                                ]
                            ),

                          )
                      ),
                      SizedBox(width: 8,),
                      PlatformSwitch(
                          value: _reportDiscuzResultToAnalytics,
                          activeColor: Theme.of(context).colorScheme.primary,
                          onChanged: (value) {
                            VibrationUtils.vibrateWithClickIfPossible();
                            setState(() {
                              _reportDiscuzResultToAnalytics = value;
                            });
                          })
                    ])),

                SizedBox(
                  width: double.infinity,
                  child: PlatformElevatedButton(

                    child: _isLoading? PlatformCircularProgressIndicator(): Text(S.of(context).continueAdding),
                    onPressed: _isLoading? null : (){
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
                // the following things


              ],
            ),
          )),
        );
  }

  Future<void> _showReportToAnalyticsDialog() async{
    showPlatformModalSheet(
        context: context,
        builder: (context) => Container(
          color: Theme.of(context).colorScheme.surface,
          padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(8),
                child: Icon(AppPlatformIcons(context).reportInformationToUsSolid,
                  color: Theme.of(context).colorScheme.primary,
                  size: 48,
                ),
              ),
              Text(S.of(context).reportDiscuzApiInformationToAnalyticsTitle, style: TextStyle(
                color: Theme.of(context).textTheme.titleMedium?.color,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              )),
              SizedBox(height: 16,),
              Text(S.of(context).reportDiscuzApiInformationToAnalyticsDescription, style: TextStyle(
                  color: Theme.of(context).textTheme.displayLarge?.color,
                  fontWeight: FontWeight.normal
              )),

              SizedBox(height: 32,),
              SizedBox(
                width: double.infinity,
                child: PlatformElevatedButton(

                  child: Text(S.of(context).viewPrivacyPolicy),
                  onPressed: (){
                    VibrationUtils.vibrateWithClickIfPossible();
                    URLUtils.launchURL("https://discuzhub.kidozh.com/privacy_policy/");
                    Navigator.of(context).pop();
                  },
                ),
              ),


              SizedBox(height: 8,),
            ],
          ),
        )
    );
  }
}
