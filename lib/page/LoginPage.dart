import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:discuz_flutter/JsonResult/LoginResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/DBHelper.dart';
import 'package:discuz_flutter/utility/GlobalTheme.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/widget/ErrorCard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:dio/dio.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:form_validator/form_validator.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';

class LoginPage extends StatelessWidget {
  late final Discuz discuz;

  LoginPage({required Key key, required this.discuz}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("登录账号至 ${discuz.siteName}"),

        ),
        body: LoginForumFieldStatefulWidget(discuz));
  }
}

class LoginForumFieldStatefulWidget extends StatefulWidget {
  late final Discuz discuz;

  LoginForumFieldStatefulWidget(@required this.discuz){}
  @override
  _LoginFormFieldState createState() {
    // TODO: implement createState
    return _LoginFormFieldState(discuz);
  }
}

class _LoginFormFieldState
    extends State<LoginForumFieldStatefulWidget> {
  late final Discuz discuz;

  final _formKey = GlobalKey<FormState>();
  String error = "";
  ButtonState _loginState = ButtonState.idle;
  final TextEditingController _accountController = new TextEditingController();
  final TextEditingController _passwdController = new TextEditingController();

  _LoginFormFieldState(@required this.discuz){}

  void _verifyAccountAndPassword() async{
    // create a dio
    var dio =  Dio();
    PersistCookieJar cookieJar = await NetworkUtils.getTemporaryCookieJar();
    dio.interceptors.add(CookieManager(cookieJar));

    String account = _accountController.text;
    String password = _passwdController.text;

    log("Recv url " + discuz.baseURL);
    // check the availability
    final client = MobileApiClient(dio, baseUrl: discuz.baseURL);
    setState(() {
      _loginState = ButtonState.loading;
    });

    // client.sendLoginRequestInString(account, password).then((value) {
    //   log(value);
    //   var res = LoginResult.fromJson(jsonDecode(value));
    //   log(res.toString());
    //
    // });

    client.sendLoginRequest(account,password).then((value) async {
      setState(() {

        error = "";
      });
      // check if the
      log("Recv a result ${value}");
      // if user is validated
      User user = value.loginVariables.getUser(discuz);
      if(value.errorResult!.key == "login_succeed"){
        // save it in database
        setState(() {
          _loginState = ButtonState.success;
        });
        try{
          final db = await DBHelper.getAppDb();
          final dao = db.userDao;

          int primaryKey = await dao.insert(user);

          // save it in cookiejar
          List<Cookie> cookies = await cookieJar.loadForRequest(Uri.parse(discuz.baseURL));
          PersistCookieJar savedCookieJar = await NetworkUtils.getPersistentCookieJarByUserId(primaryKey);
          log("cookies ${cookies}");
          savedCookieJar.saveFromResponse(Uri.parse(discuz.baseURL), cookies);
          // pop the activity
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('成功添加用户(${user.username})至${discuz.siteName}论坛')));
          Navigator.pop(context);
        }
        catch(e,s){
          log("${e},${s}");
        }
      }
      else{
        setState(() {
          error = value.errorResult!.content;
          _loginState = ButtonState.fail;
        });
      }

    })
    //     .catchError((onError) {
    //   setState(() {
    //     _isLoading = false;
    //   });
    //   log(onError);
    //
    //
    //   switch (onError.runtimeType) {
    //
    //     case DioError:
    //       {
    //         error = onError.message;
    //
    //         break;
    //       }
    //     default:
    //       {
    //         setState(() {
    //           error = onError.toString();
    //         });
    //       }
    //   }
    // })
    ;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 4.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // title and page
              Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(
                    child: SvgPicture.asset(
                      "assets/images/login-user.svg",
                      semanticsLabel: '登录账号logo',
                      allowDrawingOutsideViewBox: true,
                      width: MediaQuery.of(context).size.width * 0.4,
                    ),
                  )),
              // input fields
              new TextFormField(
                controller: _accountController,
                decoration: new InputDecoration(

                  labelText: "账号",
                  hintText: "账号",
                  prefixIcon: Icon(Icons.account_box),
                ),
                validator: ValidationBuilder().required().build()
              ),
              new TextFormField(
                controller: _passwdController,
                decoration: new InputDecoration(

                  labelText: "密码",
                  prefixIcon: Icon(Icons.vpn_key),
                ),
                obscureText: true,
                validator: ValidationBuilder().required().build()
              ),
              if (error.isNotEmpty)
                Column(
                  children: [
                    ErrorCard("发生错误", error,(){
                      _verifyAccountAndPassword();
                    }),
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
                                  icon: Icon(Icons.send,color: Colors.white),
                                  color: Colors.deepPurple.shade500),
                              ButtonState.loading:
                              IconedButton(
                                  text: S.of(context).progressButtonLogining,
                                  color: Colors.deepPurple.shade700),
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
                              _verifyAccountAndPassword();
                            },
                            state: _loginState
                        ),
                      ),

                      SizedBox(
                        width: double.infinity,
                        child: TextButton(onPressed: (){

                        }, child: Text("忘记密码？",style: TextStyle(color:Colors.black54),)),
                      ),
                      Row(
                          children: <Widget>[
                            Expanded(
                                child: Divider()
                            ),

                            Text(" 或者 ",style: TextStyle(color: Colors.black26),),

                            Expanded(
                                child: Divider()
                            ),
                          ]
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 8,horizontal: 0),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(child:
                        Text("使用网页验证"),
                            onPressed: (){

                            }),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(child:
                        Text("注册账号"),
                            onPressed: (){

                            }),
                      )

                    ],
                  ),
                ),
              ),

            ],
          ),
        ));
  }
}
