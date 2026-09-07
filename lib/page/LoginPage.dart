import 'package:discuz_flutter/utility/password_store_recovery.dart';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/DiscuzError.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/LoginByWebviewPage.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/utility/AppPlatformIcons.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/SecureStorageUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:discuz_flutter/widget/CaptchaWidget.dart';
import 'package:discuz_flutter/widget/ErrorCard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:form_validator/form_validator.dart';
import 'package:provider/provider.dart';

import '../dao/DiscuzAuthenticationDao.dart';
import '../entity/DiscuzAuthentication.dart';

class LoginPage extends StatelessWidget {
  late final Discuz discuz;
  String? accountName;

  LoginPage(this.discuz, this.accountName);

  @override
  Widget build(BuildContext context) {
    ModalRoute<Object?>? route = ModalRoute.of(context);
    return PlatformScaffold(
        iosContentPadding: true,
        iosContentBottomPadding: true,
        appBar: PlatformAppBar(
          title: Text(discuz.siteName),
          cupertino: (context, platform) => CupertinoNavigationBarData(
              previousPageTitle: (route != null &&
                      route is CupertinoPageRoute<dynamic> &&
                      route.previousTitle.value != null)
                  ? route.previousTitle.value
                  : Provider.of<DiscuzAndUserNotifier>(context, listen: false)
                      .discuz
                      ?.siteName),
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

enum LoginResultStatus { idle, loading }

class _LoginFormFieldState extends State<LoginForumFieldStatefulWidget> {
  late final Discuz discuz;
  String? accountName;
  LoginResultStatus _loginState = LoginResultStatus.idle;
  final _formKey = GlobalKey<FormState>();
  DiscuzError? error = null;

  final TextEditingController _accountController = new TextEditingController();
  final TextEditingController _passwdController = new TextEditingController();
  final CaptchaController _captchaController =
      new CaptchaController(new CaptchaFields("", "login", ""));
  bool canAuthenticate = false;
  bool _rememberPassword = true;
  bool _autofillInProgress = false;
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
    // Capability checks never prompt for authentication or open secure storage.
    try {
      final canAuth = await SecureStorageUtils.canAuthenticated();
      if (!mounted) return;
      setState(() {
        canAuthenticate = canAuth;
        _rememberPassword = canAuth;
      });
      if (canAuth) await _authWithSystemAndAutoFill();
    } catch (_) {
      if (mounted) setState(() => canAuthenticate = false);
    }
  }

  Future<void> _authWithSystemAndAutoFill() async {
    if (_autofillInProgress || !mounted) return;
    _autofillInProgress = true;
    try {
      bool canAuth = await SecureStorageUtils.canAuthenticated();

      if (canAuth) {
        bool isAuthed =
            await SecureStorageUtils.authenticateWithSystem(context);

        if (!mounted) return;
        if (isAuthed) {
          // check into system
          final discuzAuthentificationDao =
              await openPasswordStoreWithRecovery(context);
          if (discuzAuthentificationDao == null) return;
          if (!mounted) return;
          List<DiscuzAuthentication> discuzAuthentificationList =
              discuzAuthentificationDao
                  .getDiscuzAuthenticationListByHost(discuz.host);
          log("The list of authentification ${discuzAuthentificationList.length}");
          if (discuzAuthentificationList.length == 1) {
            // only one element in authentication
            DiscuzAuthentication discuzAuthentification =
                discuzAuthentificationList.first;
            _autoFillLoginForm(discuzAuthentification.account,
                discuzAuthentification.password);
          } else if (discuzAuthentificationList.isEmpty) {
            EasyLoading.showInfo(S.of(context).noAuthenticationFoundInApp);
          } else {
            // multiple choices
            _showAutoFillDialog(discuzAuthentificationList);
          }
        } else {
          EasyLoading.showError(S.of(context).unableToAuthenticate);
        }
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _rememberPassword = false);
      EasyLoading.showError(S.of(context).savedPasswordsUnavailable);
    } finally {
      _autofillInProgress = false;
    }
  }

  Future<void> _autoFillLoginForm(String account, String password) async {
    // first of all set it
    _accountController.text = account;
    _passwdController.text = password;
    EasyLoading.showSuccess(S.of(context).autoFillUsername(account));
    VibrationUtils.vibrateSuccessfullyIfPossible();
  }

  Future<void> _showAutoFillDialog(
      List<DiscuzAuthentication> discuzAuthenticationList) async {
    // cupertino comes first
    showPlatformModalSheet(
        context: context,
        builder: (sheetContext) => SafeArea(
              top: false,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.62,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                      child: Column(
                        children: [
                          Text(
                            S.of(context).autofillDialogTitle,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            S.of(context).autofillDialogSubtitle,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          for (final authentication in discuzAuthenticationList)
                            PlatformListTile(
                              title: Text(authentication.account),
                              leading: const Icon(CupertinoIcons.person),
                              trailing: const Icon(CupertinoIcons.forward),
                              onTap: () {
                                VibrationUtils.vibrateWithClickIfPossible();
                                _autoFillLoginForm(
                                  authentication.account,
                                  authentication.password,
                                );
                                Navigator.of(sheetContext).pop();
                              },
                            ),
                        ],
                      ),
                    ),
                    PlatformTextButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      child: Text(S.of(context).cancel),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ));
  }

  Future<void> _saveAuthentificationToSecureDatabase() async {
    try {
      String account = _accountController.text;
      String password = _passwdController.text;
      DiscuzAuthenticationDao discuzAuthentificationDao =
          await SecureStorageUtils.getDiscuzAuthenticationDao();
      DiscuzAuthentication discuzAuthentification = DiscuzAuthentication();
      discuzAuthentification.account = account;
      discuzAuthentification.password = password;
      discuzAuthentification.discuz_host = discuz.host;
      discuzAuthentification.updateTime = DateTime.now();
      await discuzAuthentificationDao
          .insertDiscuzAuthentication(discuzAuthentification);
    } catch (_) {
      if (mounted) EasyLoading.showError(S.of(context).passwordSaveFailed);
    }
  }

  Dio _dio = Dio();
  late CookieJar cookieJar;

  Future<void> _initDio() async {
    cookieJar = await NetworkUtils.getTemporaryCookieJar();
    _dio = NetworkUtils.getDio();
    NetworkUtils.addCookieManager(_dio, cookieJar);
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
      _loginState = LoginResultStatus.loading;
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
      log('Login response received from ${discuz.host}');
      // if user is validated
      User user = value.loginVariables.getUser(discuz);
      user.discuz = discuz;
      if (value.errorResult!.key == "login_succeed") {
        // save it in database
        setState(() {
          _loginState = LoginResultStatus.idle;
        });
        try {
          final dao = await AppDatabase.getUserDao();

          // search in database first
          User? userInDataBase = dao.findUsersByDiscuzAndUid(discuz, user.uid);
          if (userInDataBase != null) {
            await dao.insertWithKey(userInDataBase.key, user);
          } else {
            await dao.insert(user);
          }
          // save it in cookiejar
          List<Cookie> cookies =
              await cookieJar.loadForRequest(Uri.parse(discuz.baseURL));
          log('Persisting ${cookies.length} login cookies for uid ${user.uid}');
          await NetworkUtils.replacePersistentCookiesForUser(
            user,
            Uri.parse(discuz.baseURL),
            cookies,
          );
          if (!mounted) return;
          // pop the activity
          // set it
          EasyLoading.showSuccess(
              S.of(context).signInSuccessTitle(user.username, discuz.siteName));
          // handle with security issue
          if (_rememberPassword) {
            log("Save authentification to secure storage");
            await _saveAuthentificationToSecureDatabase();
          }
          Provider.of<DiscuzAndUserNotifier>(context, listen: false)
              .setUser(user);

          Navigator.pop(context);
        } catch (e, s) {
          VibrationUtils.vibrateErrorIfPossible();
          log("${e},${s}");
        }
      } else {
        _captchaController.reloadCaptcha();
        setState(() {
          error =
              DiscuzError(value.errorResult!.key, value.errorResult!.content);
          _loginState = LoginResultStatus.idle;
        });
      }
    }).catchError((onError) {
      VibrationUtils.vibrateErrorIfPossible();
      _captchaController.reloadCaptcha();
      setState(() {
        _loginState = LoginResultStatus.idle;
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
                            errorWidget: (context, url, error) =>
                                PlatformListTile(
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
                              text: S.of(context).rememeberPasswordInApp,
                              children: [
                                TextSpan(
                                    text: " " +
                                        S
                                            .of(context)
                                            .rememberPasswordInAppDetail,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        VibrationUtils
                                            .vibrateWithClickIfPossible();
                                        _showAuthenticationDialog();
                                      })
                              ]),
                        )),
                        SizedBox(
                          width: 8,
                        ),
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
                          height: 52,
                          child: PlatformElevatedButton(
                            color: Theme.of(context).colorScheme.primary,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _loginState == LoginResultStatus.idle
                                    ? Icon(
                                        AppPlatformIcons(context)
                                            .loginUserSolid,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      )
                                    : PlatformCircularProgressIndicator(
                                        material: (context, platform) =>
                                            MaterialProgressIndicatorData(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary),
                                        cupertino: (context, platform) =>
                                            CupertinoProgressIndicatorData(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary),
                                      ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(S.of(context).loginTitle,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary))
                              ],
                            ),
                            onPressed: _loginState == LoginResultStatus.idle
                                ? () {
                                    VibrationUtils.vibrateWithClickIfPossible();
                                    _verifyAccountAndPassword();
                                  }
                                : null,
                          ),
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        //if (!Platform.isIOS)
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: PlatformElevatedButton(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _loginState == LoginResultStatus.idle
                                    ? Icon(
                                        AppPlatformIcons(context)
                                            .loginUserInWebSolid,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer,
                                      )
                                    : PlatformCircularProgressIndicator(
                                        material: (context, platform) =>
                                            MaterialProgressIndicatorData(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer),
                                        cupertino: (context, platform) =>
                                            CupertinoProgressIndicatorData(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer),
                                      ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(S.of(context).signInViaBrowser,
                                    style: TextStyle(
                                        color: _loginState ==
                                                LoginResultStatus.idle
                                            ? Theme.of(context)
                                                .colorScheme
                                                .onPrimaryContainer
                                            : Theme.of(context)
                                                .colorScheme
                                                .primary))
                              ],
                            ),
                            onPressed: _loginState == LoginResultStatus.idle
                                ? () {
                                    VibrationUtils.vibrateWithClickIfPossible();
                                    Navigator.push(
                                        context,
                                        platformPageRoute(
                                            iosTitle:
                                                S.of(context).signInViaBrowser,
                                            context: context,
                                            builder: (context) =>
                                                LoginByWebviewPage(discuz)));
                                  }
                                : null,
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
                        AppPlatformIcons(context).authenticationSecureSolid,
                        semanticLabel: S.of(context).autofillDialogTitle,
                        size: 36,
                      ),
                      onTap: () async {
                        VibrationUtils.vibrateWithClickIfPossible();
                        await _authWithSystemAndAutoFill();
                      },
                    ),
                  ))
              ],
            ),
          ),
        ));
  }

  Future<void> _showAuthenticationDialog() async {
    showPlatformModalSheet(
        context: context,
        builder: (context) => Container(
              color: usesLiquidGlass(context)
                  ? Colors.transparent
                  : Theme.of(context).colorScheme.surface,
              padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      AppPlatformIcons(context).authenticationSecureSolid,
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.green.shade700
                          : Colors.green.shade300,
                      size: 48,
                    ),
                  ),
                  Text(S.of(context).authenticationSecurityTitle,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.titleMedium?.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      )),
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                      Platform.isIOS
                          ? S.of(context).authenticationSecurityIosContent
                          : S.of(context).authenticationSecurityAndroidContent,
                      style: TextStyle(
                          color:
                              Theme.of(context).textTheme.displayLarge?.color,
                          fontWeight: FontWeight.normal)),
                ],
              ),
            ));
  }
}
