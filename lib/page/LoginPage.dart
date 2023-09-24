import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/DiscuzError.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/LoginByWebviewPage.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/SecureStorageUtils.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:discuz_flutter/widget/CaptchaWidget.dart';
import 'package:discuz_flutter/widget/ErrorCard.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:form_validator/form_validator.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:provider/provider.dart';

import '../dao/DiscuzAuthentificationDao.dart';
import '../entity/DiscuzAuthentification.dart';
import 'PushServicePage.dart';

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
          title: Text(discuz.siteName),
        ),
        body: LoginForumFieldStatefulWidget(discuz, accountName));
  }
}

class LoginForumFieldStatefulWidget extends StatefulWidget {
  late final Discuz discuz;
  String? accountName;

  LoginForumFieldStatefulWidget(this.discuz, this.accountName);
  @override
  _LoginFormFieldState createState() {
    return _LoginFormFieldState(discuz, accountName);
  }
}

class _LoginFormFieldState extends State<LoginForumFieldStatefulWidget> {
  late final Discuz discuz;
  String? accountName;

  final _formKey = GlobalKey<FormState>();
  DiscuzError? error = null;
  ButtonState _loginState = ButtonState.idle;
  final TextEditingController _accountController = new TextEditingController();
  final TextEditingController _passwdController = new TextEditingController();
  final CaptchaController _captchaController =
      new CaptchaController(new CaptchaFields("", "login", ""));
  bool canAuthenticate = false;
  bool _rememberPassword = true;
  bool _isAuthed = false;

  _LoginFormFieldState(this.discuz, this.accountName) {}

  @override
  void initState() {
    super.initState();
    if (accountName != null) {
      _accountController.text = accountName!;
    }

    _initDio();
    _checkWithAuthentication();
  }

  Future<void> _checkWithAuthentication() async {
    bool canAuth = await SecureStorageUtils.canAuthenticated();
    setState(() {
      canAuthenticate = canAuth;
      _rememberPassword = canAuth;
    });

    if(canAuth){
      await _authWithSystemAndAutoFill();
    }

  }

  Future<void> _authWithSystemAndAutoFill() async{
    bool canAuth = await SecureStorageUtils.canAuthenticated();

    if(canAuth){
      bool isAuthed = await SecureStorageUtils.authenticateWithSystem(context);

      setState(() {
        _isAuthed = isAuthed;
      });
      // check into system
      DiscuzAuthentificationDao discuzAuthentificationDao = await SecureStorageUtils.getDiscuzAuthentificationDao();
      List<DiscuzAuthentification> discuzAuthentificationList =
      discuzAuthentificationDao.getDiscuzAuthentificationListByHost(discuz.host);
      if(discuzAuthentificationList.length == 1){
        // only one element in authentication
        DiscuzAuthentification discuzAuthentification = discuzAuthentificationList.first;
        _autoFillLoginForm(discuzAuthentification.account, discuzAuthentification.password);
      }
    }


  }

  Future<void> _autoFillLoginForm(String account, String password) async {
    // first of all set it
    _accountController.text = account;
    _passwdController.text = password;

    if(_captchaController.value == null || _captchaController.value!.captchaFormHash.isEmpty){
      _verifyAccountAndPassword();
    }

  }

  Future<void> _saveAuthentificationToSecureDatabase() async{
    String account = _accountController.text;
    String password = _passwdController.text;
    DiscuzAuthentificationDao discuzAuthentificationDao = await SecureStorageUtils.getDiscuzAuthentificationDao();
    DiscuzAuthentification discuzAuthentification = DiscuzAuthentification();
    discuzAuthentification.account = account;
    discuzAuthentification.password = password;
    discuzAuthentification.discuz_host = discuz.host;
    discuzAuthentification.updateTime = DateTime.now();
    discuzAuthentificationDao.insertDiscuzAuthentification(
        discuzAuthentification
    );
  }

  Dio _dio = Dio();
  late PersistCookieJar cookieJar;

  Future<void> _initDio() async {
    cookieJar = await NetworkUtils.getTemporaryCookieJar();
    setState(() {
      _dio.interceptors.add(CookieManager(cookieJar));
    });
  }

  void _verifyAccountAndPassword() async {
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
    if (captchaFields != null && captchaFields.captchaFormHash.isNotEmpty) {
      captchaHash = captchaFields.captchaFormHash;
      verification = captchaFields.verification;
      captchaMod = "member::logging";
      print(
          "Captcha hash: ${captchaFields.captchaFormHash} verification: ${captchaFields.verification}");
    }

    client
        .sendLoginRequest(
            account, password, captchaHash, captchaMod, verification)
        .then((value) async {
      setState(() {
        error = null;
      });
      // check if the
      log("Recv a result ${value} ${value.toJson().toString()}");
      // if user is validated
      User user = value.loginVariables.getUser(discuz);
      user.discuz = discuz;
      if (value.errorResult!.key == "login_succeed") {
        // save it in database
        setState(() {
          _loginState = ButtonState.success;
        });
        try {
          final dao = await AppDatabase.getUserDao();

          // search in database first
          User? userInDataBase = dao.findUsersByDiscuzAndUid(discuz, user.uid);
          if (userInDataBase != null) {
            user = userInDataBase;
            await dao.insertWithKey(userInDataBase.key, user);
          } else {
            await dao.insert(user);
          }
          // save it in cookiejar
          List<Cookie> cookies =
              await cookieJar.loadForRequest(Uri.parse(discuz.baseURL));
          PersistCookieJar savedCookieJar =
              await NetworkUtils.getPersistentCookieJarByUser(user);
          log("cookies ${cookies}");
          savedCookieJar.saveFromResponse(Uri.parse(discuz.baseURL), cookies);
          // pop the activity
          // set it
          EasyLoading.showSuccess(
              S.of(context).signInSuccessTitle(user.username, discuz.siteName));
          // handle with security issue


          // to popup a token
          bool allowPush = await UserPreferencesUtils.getPushPreference();
          if (allowPush) {
            showPlatformDialog(
                context: context,
                builder: (_) => PlatformAlertDialog(
                      title: Text(S.of(context).registerPushTokenTitle),
                      content: Text(S.of(context).registerPushTokenMessage),
                      actions: [
                        PlatformDialogAction(
                          child: Text(S.of(context).ok),
                          onPressed: () async {
                            VibrationUtils.vibrateWithClickIfPossible();
                            Provider.of<DiscuzAndUserNotifier>(context,
                                    listen: false)
                                .setUser(user);
                            await Navigator.push(
                                context,
                                platformPageRoute(
                                    context: context,
                                    builder: (context) => PushServicePage()));
                          },
                        ),
                        PlatformDialogAction(
                          child: Text(S.of(context).cancel),
                          onPressed: () {
                            VibrationUtils.vibrateWithClickIfPossible();
                            Provider.of<DiscuzAndUserNotifier>(context,
                                    listen: false)
                                .setUser(user);
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                        )
                      ],
                    ));
          } else {
            Provider.of<DiscuzAndUserNotifier>(context, listen: false)
                .setUser(user);
            Navigator.pop(context);
          }

        } catch (e, s) {
          VibrationUtils.vibrateErrorIfPossible();
          log("${e},${s}");
        }
      } else {
        _captchaController.reloadCaptcha();
        setState(() {
          error =
              DiscuzError(value.errorResult!.key, value.errorResult!.content);
          _loginState = ButtonState.fail;
        });
      }
    }).catchError((onError) {
      VibrationUtils.vibrateErrorIfPossible();
      _captchaController.reloadCaptcha();
      setState(() {
        _loginState = ButtonState.fail;
      });

      switch (onError.runtimeType) {
        case DioException:
          {
            DioException dioError = onError;
            setState(() {
              error = DiscuzError(
                  dioError.message == null
                      ? S.of(context).error
                      : dioError.message!,
                  dioError.type.name,
                  dioError: dioError);
            });
            break;
          }
        default:
          {
            setState(() {
              error = DiscuzError(
                  onError.runtimeType.toString(), onError.toString());
            });
          }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                // title and page
                Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 32.0, vertical: 64.0),
                    child: Center(
                        child: CachedNetworkImage(
                            imageUrl: discuz.getDiscuzAvatarURL(),
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) =>
                                    CircularProgressIndicator(
                                        value: downloadProgress.progress),
                            errorWidget: (context, url, error) => ListTile(
                                  title: Text(discuz.siteName),
                                  subtitle: Text(discuz.baseURL),
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    child: Text(
                                      discuz.siteName.length != 0
                                          ? discuz.siteName[0].toUpperCase()
                                          : S.of(context).anonymous,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18),
                                    ),
                                  ),
                                )))),
                // input fields
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: isCupertino(context)
                      ? BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color:
                              Theme.of(context).disabledColor.withOpacity(0.1))
                      : null,
                  child: Column(
                    children: [
                      PlatformTextFormField(
                          autofillHints: [AutofillHints.username],
                          controller: _accountController,
                          hintText: S.of(context).account,
                          material: (context, platform) {
                            return MaterialTextFormFieldData(
                              decoration: InputDecoration(
                                labelText: S.of(context).account,
                                hintText: S.of(context).account,
                                prefixIcon: Icon(Icons.account_circle),
                              ),
                            );
                          },
                          cupertino: (context, platform) {
                            return CupertinoTextFormFieldData(
                                prefix: Text(S.of(context).account),
                                decoration: BoxDecoration());
                          },
                          validator: ValidationBuilder().required().build()),
                      if (isCupertino(context)) Divider(),
                      PlatformTextFormField(
                          autofillHints: [AutofillHints.password],
                          controller: _passwdController,
                          hintText: S.of(context).password,
                          material: (context, platform) {
                            return MaterialTextFormFieldData(
                              decoration: InputDecoration(
                                labelText: S.of(context).password,
                                prefixIcon: Icon(Icons.vpn_key),
                              ),
                            );
                          },
                          cupertino: (context, platform) {
                            return CupertinoTextFormFieldData(
                                prefix: Text(S.of(context).password),
                                decoration: BoxDecoration());
                          },
                          obscureText: true,
                          validator: ValidationBuilder().required().build()),
                    ],
                  ),
                ),

                CaptchaWidget(
                  _dio,
                  discuz,
                  null,
                  "login",
                  captchaController: _captchaController,
                ),
                if (error != null)
                  Column(
                    children: [
                      ErrorCard(
                        error!,
                        () {
                          _verifyAccountAndPassword();
                        },
                        largeSize: false,
                      ),
                    ],
                  ),
                // remember part
                if (canAuthenticate)
                  Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                      child: Row(children: [
                        Expanded(
                            child: RichText(
                              text: TextSpan(
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  text:S.of(context).rememeberPasswordInApp,
                                  children: [
                                    TextSpan(
                                        text: " "+S.of(context).rememberPasswordInAppDetail,
                                        style: TextStyle(color: Theme.of(context).colorScheme.primary),
                                        recognizer: TapGestureRecognizer()..onTap = (){
                                          VibrationUtils.vibrateWithClickIfPossible();

                                        }
                                    )
                                  ]
                              ),

                            )
                        ),
                        SizedBox(width: 8,),
                        PlatformSwitch(
                            value: _rememberPassword,
                            activeColor: Theme.of(context).colorScheme.primary,
                            onChanged: (value) {
                              VibrationUtils.vibrateWithClickIfPossible();
                              setState(() {
                                _rememberPassword = value;
                              });
                            })
                      ])),

                Center(
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 24.0, horizontal: 4.0),
                    width: double.infinity,
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ProgressButton.icon(
                              maxWidth: 230.0,
                              iconedButtons: {
                                ButtonState.idle: IconedButton(
                                    text: S.of(context).loginTitle,
                                    icon: Icon(Icons.login,
                                        color: Colors.white60),
                                    color:
                                        Theme.of(context).colorScheme.primary),
                                ButtonState.loading: IconedButton(
                                    text: S.of(context).progressButtonLogining,
                                    color: Colors.blue.shade300),
                                ButtonState.fail: IconedButton(
                                    text:
                                        S.of(context).progressButtonLoginFailed,
                                    icon:
                                        Icon(Icons.cancel, color: Colors.white),
                                    color: Colors.red.shade300),
                                ButtonState.success: IconedButton(
                                    text: S
                                        .of(context)
                                        .progressButtonLoginSuccess,
                                    icon: Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                    ),
                                    color: Colors.green.shade400)
                              },
                              onPressed: () {
                                VibrationUtils.vibrateWithClickIfPossible();
                                _verifyAccountAndPassword();
                              },
                              state: _loginState),
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        if (!Platform.isIOS)
                          SizedBox(
                            width: double.infinity,
                            child: PlatformElevatedButton(
                              padding: EdgeInsets.symmetric(
                                  vertical: 16.0, horizontal: 4.0),
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                              child: Text(S.of(context).signInViaBrowser,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondaryContainer)),
                              onPressed: () {
                                VibrationUtils.vibrateWithClickIfPossible();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            LoginByWebviewPage(discuz)));
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                    child: Container(
                  height: 6,
                )),
                if (canAuthenticate)
                  Center(
                      child: Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 32.0, horizontal: 8.0),
                    child: InkWell(
                      child: Icon(
                        Icons.key_rounded,
                        size: 48,
                      ),
                      onTap: () async {
                        VibrationUtils.vibrateWithClickIfPossible();
                        bool isSuccessResult =
                            await SecureStorageUtils.authenticateWithSystem(
                                context);
                        log("is Auth success ${isSuccessResult}");

                        await _checkWithAuthentication();
                      },
                    ),
                  ))
              ],
            ),
          ),
        ));
  }
}
