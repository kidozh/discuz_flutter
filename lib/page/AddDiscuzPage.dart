import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:discuz_flutter/JsonResult/CheckResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:discuz_flutter/widget/ErrorCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:form_validator/form_validator.dart';
import 'package:provider/provider.dart';

import '../entity/DiscuzError.dart';

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

  Future<void> _saveDiscuzInDb(Discuz discuz) async {

    final dao = await AppDatabase.getDiscuzDao();
    int insertId = await dao.insertDiscuz(discuz);
    if(dao.getDiscuzByIndex(insertId)!=null){
      discuz = dao.getDiscuzByIndex(insertId)!;
    }

    Provider.of<DiscuzAndUserNotifier>(context, listen: false).setDiscuz(discuz);
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
                if (error!=null)
                  Column(
                    children: [
                      ErrorCard(error!,(){
                        _checkApiAvailable();
                      }, largeSize: false,),
                    ],
                  ),
                SizedBox(height: 32.0,),

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


              ],
            ),
          )),
        );
  }
}
