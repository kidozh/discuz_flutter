import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:discuz_flutter/JsonResult/CaptchaResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/AppPlatformIcons.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class CaptchaWidget extends StatelessWidget {
  Discuz _discuz;
  User? _user;
  String captchaType;
  Dio dio;
  bool? showProgress;

  CaptchaWidget(this.dio, this._discuz, this._user, this.captchaType,
      {this.captchaController, this.showProgress});

  CaptchaController? captchaController;

  @override
  Widget build(BuildContext context) {
    return CaptchaStatefulWidget(
        this.dio, _discuz, _user, captchaType, captchaController, this.showProgress);
  }
}

class CaptchaStatefulWidget extends StatefulWidget {
  Discuz _discuz;
  User? _user;
  String captchaType;

  CaptchaController? captchaController;
  bool? showProgress;

  CaptchaStatefulWidget(this.dio, this._discuz, this._user, this.captchaType,
      this.captchaController, this.showProgress);

  Dio dio;

  @override
  State<StatefulWidget> createState() {
    return CaptchaState(dio, _discuz, _user, captchaType, captchaController, showProgress);
  }
}

class CaptchaState extends State<CaptchaStatefulWidget> {
  Discuz _discuz;
  User? _user;
  String captchaType;
  late MobileApiClient _client;
  Dio _dio;
  CaptchaController? captchaController;

  CaptchaVariable? captchaVariable;
  Uint8List? imageByte;

  TextEditingController _textEditingController = new TextEditingController();
  bool? showProgress;
  bool loaded = false;

  CaptchaState(this._dio, this._discuz, this._user, this.captchaType,
      this.captchaController, this.showProgress);


  @override
  void initState() {
    super.initState();
    _initNetwork();
  }

  String _getCaptchaUrl() {
    return "${_discuz.baseURL}/api/mobile/index.php?module=seccode&sechash=${captchaVariable!.secHash}&version=4&type=$captchaType";
  }

  // Future<void> _refreshDio() async {
  //   if (_dio == null) {
  //     if(_user == null){
  //       _dio = Dio();
  //     }
  //     else{
  //       print("load cookie for user ${_user!.username}");
  //       _dio = await NetworkUtils.getDioWithPersistCookieJar(_user);
  //     }
  //
  //   }
  // }

  _initNetwork() async {
    // await _refreshDio();

    _client = MobileApiClient(_dio, baseUrl: _discuz.baseURL);
    _loadCaptchaInfo();
    _bindNotifier();
  }

  _bindNotifier() {
    _textEditingController.addListener(() {
      String verification = _textEditingController.text;
      if (captchaController != null && captchaController!.value != null) {
        captchaController!.value = CaptchaFields(
            captchaController!.value!.captchaFormHash,
            captchaController!.value!.fieldType,
            verification);
        captchaController!.notifyListeners();
      }
    });
    if (captchaController != null) {
      captchaController!.addListener(() {
        CaptchaFields? captchaFields = captchaController!.value;
        if (captchaFields == null) {
          // trigger change if captcha fields is null
          _loadCaptchaInfo();
        }
      });
    }
  }

  _loadCaptchaInfo() async{
    // refresh
    _client = MobileApiClient(_dio, baseUrl: _discuz.baseURL);
    _client.captchaResult(this.captchaType).then((value) async {
      print("GET ${value.variables.secCodeURL} ${value.variables.secHash}");
      // the captcha html
      setState(() {
        captchaVariable = value.variables;
        loaded = true;
      });
      // refresh controller parameters
      if (captchaController != null) {
        captchaController!.value = CaptchaFields(
            value.variables.secHash, captchaType, _textEditingController.text);
      }

      Response<Uint8List> rs;
      // _dio = await NetworkUtils.getDioWithPersistCookieJar(_user);
      rs = await _dio.get<Uint8List>(_getCaptchaUrl(),
          options: Options(
              responseType: ResponseType.bytes,
              headers: {"Referer": value.variables.secCodeURL}));
      if (rs.data != null) {
        //print("Recv response data ${rs.data}");
        setState(() {
          imageByte = rs.data!;
        });

      }
    }).onError((error, stackTrace){
      setState(() {
        loaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (captchaVariable == null) {
      // an empty container
      if(showProgress == true){
        if(loaded == false){
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
            child: Row(
              children: [
                PlatformCircularProgressIndicator(),
                Expanded(child: Text(S.of(context).loadingCaptchaInformation))
              ],
            ),
          );
        }
        else{
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
            child: Row(
              children: [
                Icon(AppPlatformIcons(context).checkCircleSolid, color: Colors.green,),
                Expanded(child: Text(S.of(context).noCaptachaRequired))
              ],
            ),
          );
        }

      }
      else{
        return Container(
          width: 0,
          height: 0,
        );
      }

    } else {
      return Padding(
        padding: EdgeInsets.all(4.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
                child: PlatformTextField(
              controller: _textEditingController,
              hintText: S.of(context).captchaRequired,
            )),
            SizedBox(
              width: 8.0,
            ),
            if (imageByte != null)
              GestureDetector(
                child: Image.memory(imageByte!),
                onTap: () {
                  VibrationUtils.vibrateWithClickIfPossible();
                  _loadCaptchaInfo();
                },
              )
          ],
        ),
      );
    }
  }
}

class CaptchaFields {
  String captchaFormHash = "";
  String fieldType = "";
  String verification = "";

  CaptchaFields(this.captchaFormHash, this.fieldType, this.verification);
}

class CaptchaController extends ValueNotifier<CaptchaFields?> {
  CaptchaController(CaptchaFields value) : super(value);

  @override
  set value(CaptchaFields? newValue) {
    super.value = newValue;
  }

  void reloadCaptcha() {
    print("reload captcha ");
    super.value = null;
    notifyListeners();
  }
}
