import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/LoginByWebviewPage.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:discuz_flutter/widget/CaptchaWidget.dart';
import 'package:discuz_flutter/widget/ErrorCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:form_validator/form_validator.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  late final Discuz discuz;
  String? accountName;

  LoginPage(this.discuz, this.accountName);

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
        iosContentPadding: true,
        iosContentBottomPadding: true,
        appBar: PlatformAppBar(
          title: Text(S.of(context).signInTitle(discuz.siteName)),

        ),
        body: LoginForumFieldStatefulWidget(discuz,accountName));
  }
}

class LoginForumFieldStatefulWidget extends StatefulWidget {
  late final Discuz discuz;
  String? accountName;

  LoginForumFieldStatefulWidget(this.discuz, this.accountName);
  @override
  _LoginFormFieldState createState() {
    return _LoginFormFieldState(discuz,accountName);
  }
}

class _LoginFormFieldState
    extends State<LoginForumFieldStatefulWidget> {
  late final Discuz discuz;
  String? accountName;

  final _formKey = GlobalKey<FormState>();
  String error = "";
  ButtonState _loginState = ButtonState.idle;
  final TextEditingController _accountController = new TextEditingController();
  final TextEditingController _passwdController = new TextEditingController();
  final CaptchaController _captchaController = new CaptchaController(new CaptchaFields("", "login", ""));

  _LoginFormFieldState(this.discuz, this.accountName){}

  @override
  void initState() {
    super.initState();
    if(accountName !=null){
      _accountController.text = accountName!;
    }

    _initDio();


  }

  Dio _dio = Dio();
  late PersistCookieJar cookieJar;

  Future<void> _initDio() async{
    cookieJar = await NetworkUtils.getTemporaryCookieJar();
    setState(() {
      _dio.interceptors.add(CookieManager(cookieJar));
    });

  }

  void _verifyAccountAndPassword() async{
    // create a dio


    String account = _accountController.text;
    String password = _passwdController.text;

    log("Recv url " + discuz.baseURL);
    // check the availability
    // refresh the dio
    await _initDio();
    final client = MobileApiClient(_dio, baseUrl: discuz.baseURL);
    setState(() {
      _loginState = ButtonState.loading;
    });


    CaptchaFields? captchaFields = _captchaController.value;
    String captchaHash = "";
    String captchaMod = "";
    String verification = "";
    if(captchaFields!= null && captchaFields.captchaFormHash.isNotEmpty){
      captchaHash = captchaFields.captchaFormHash;
      verification = captchaFields.verification;
      captchaMod = "member::logging";
      print("Captcha hash: ${captchaFields.captchaFormHash} verification: ${captchaFields.verification}");
    }

    client.sendLoginRequest(account,password,captchaHash,captchaMod,verification).then((value) async {
      setState(() {

        error = "";
      });
      // check if the
      log("Recv a result ${value} ${value.toJson().toString()}");
      // if user is validated
      User user = value.loginVariables.getUser(discuz);
      user.discuz = discuz;
      if(value.errorResult!.key == "login_succeed"){
        // save it in database
        setState(() {
          _loginState = ButtonState.success;
        });
        try{

          final dao = await AppDatabase.getUserDao();
          // search in database first
          User? userInDataBase = dao.findUsersByDiscuzAndUid(discuz, user.uid);
          if(userInDataBase != null){
            user = userInDataBase;
            await dao.insertWithKey(userInDataBase.key, user);
          }
          else{
            await dao.insert(user);
          }
          // save it in cookiejar
          List<Cookie> cookies = await cookieJar.loadForRequest(Uri.parse(discuz.baseURL));
          PersistCookieJar savedCookieJar = await NetworkUtils.getPersistentCookieJarByUser(user);
          log("cookies ${cookies}");
          savedCookieJar.saveFromResponse(Uri.parse(discuz.baseURL), cookies);
          // pop the activity
          // set it
          EasyLoading.showSuccess(S.of(context).signInSuccessTitle(user.username, discuz.siteName));
          Provider.of<DiscuzAndUserNotifier>(context, listen: false).setUser(user);
          Navigator.pop(context);

        }
        catch(e,s){
          VibrationUtils.vibrateErrorIfPossible();
          log("${e},${s}");
        }
      }
      else{
        _captchaController.reloadCaptcha();
        setState(() {
          error = value.errorResult!.content;
          _loginState = ButtonState.fail;
        });
      }

    }).catchError((onError) {
      VibrationUtils.vibrateErrorIfPossible();
      _captchaController.reloadCaptcha();
      setState(() {
        error = onError.toString();
        _loginState = ButtonState.fail;
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
    })
    ;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 8.0),
        child: Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // title and page
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0,vertical: 16.0),
                    child: Center(
                        child: CachedNetworkImage(
                            imageUrl: discuz.getDiscuzAvatarURL(),
                            progressIndicatorBuilder: (context, url, downloadProgress) => CircularProgressIndicator(value: downloadProgress.progress),
                            errorWidget: (context, url, error) => ListTile(
                              title: Text(discuz.siteName),
                              subtitle: Text(discuz.baseURL),
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor,
                                child: Text(
                                  discuz.siteName.length != 0
                                      ? discuz.siteName[0].toUpperCase()
                                      : S.of(context).anonymous,
                                  style: TextStyle(color: Colors.white,fontSize: 18),
                                ),
                              ),
                            )
                        )
                    )),
                // input fields
                new TextFormField(
                    autofillHints: [AutofillHints.username],
                    controller: _accountController,
                    decoration: new InputDecoration(

                      labelText: S.of(context).account,
                      hintText: S.of(context).account,
                      prefixIcon: Icon(Icons.account_circle),
                    ),
                    validator: ValidationBuilder().required().build()
                ),
                new TextFormField(
                    autofillHints: [AutofillHints.password],
                    controller: _passwdController,
                    decoration: new InputDecoration(

                      labelText: S.of(context).password,
                      prefixIcon: Icon(Icons.vpn_key),
                    ),
                    obscureText: true,
                    validator: ValidationBuilder().required().build()
                ),
                CaptchaWidget(_dio, discuz, null, "login",captchaController: _captchaController,),
                if (error.isNotEmpty)
                  Column(
                    children: [
                      ErrorCard(S.of(context).error, error,(){
                        _verifyAccountAndPassword();
                      },
                        largeSize: false,),
                    ],
                  ),

                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8.0,horizontal: 4.0),
                    width: double.infinity,
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ProgressButton.icon(
                              maxWidth: 230.0,
                              iconedButtons: {
                                ButtonState.idle:
                                IconedButton(
                                    text: S.of(context).loginTitle,
                                    icon: Icon(Icons.login,color: Theme.of(context).primaryTextTheme.headline1?.color),
                                    color: Theme.of(context).primaryColor),
                                ButtonState.loading:
                                IconedButton(
                                    text: S.of(context).progressButtonLogining,
                                    color: Colors.blue.shade300),
                                ButtonState.fail:
                                IconedButton(
                                    text: S.of(context).progressButtonLoginFailed,
                                    icon: Icon(Icons.cancel,color: Colors.white),
                                    color: Colors.red.shade300),
                                ButtonState.success:
                                IconedButton(
                                    text: S.of(context).progressButtonLoginSuccess,
                                    icon: Icon(Icons.check_circle,color: Colors.white,),
                                    color: Colors.green.shade400)
                              },
                              onPressed: (){
                                VibrationUtils.vibrateWithClickIfPossible();
                                _verifyAccountAndPassword();
                              },
                              state: _loginState
                          ),
                        ),
                        // Row(
                        //     children: <Widget>[
                        //       Expanded(
                        //           child: Divider()
                        //       ),
                        //
                        //       Text(S.of(context).or,style: Theme.of(context).textTheme.bodyText2),
                        //
                        //       Expanded(
                        //           child: Divider()
                        //       ),
                        //     ]
                        // ),
                        // Container(
                        //   padding: EdgeInsets.symmetric(vertical: 8,horizontal: 0),
                        // ),
                        SizedBox(height: 12,),
                        if(!Platform.isIOS)
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              icon: Icon(Icons.open_in_browser),
                              label: Text(S.of(context).signInViaBrowser),
                              onPressed: (){
                                VibrationUtils.vibrateWithClickIfPossible();
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) => LoginByWebviewPage(discuz)));
                              }, ),
                          ),

                      ],
                    ),
                  ),
                ),

              ],
            ),
          ),
        ));
  }
}
