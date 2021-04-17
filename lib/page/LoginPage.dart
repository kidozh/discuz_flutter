import 'dart:convert';
import 'dart:developer';
import 'package:discuz_flutter/JsonResult/LoginResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/utility/DBHelper.dart';
import 'package:discuz_flutter/utility/GlobalTheme.dart';
import 'package:discuz_flutter/widget/ErrorCard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:dio/dio.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:form_validator/form_validator.dart';

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
  bool _isLoading = false;
  final TextEditingController _accountController = new TextEditingController();
  final TextEditingController _passwdController = new TextEditingController();

  _LoginFormFieldState(@required this.discuz){}

  void _verifyAccountAndPassword() {

    String account = _accountController.text;
    String password = _passwdController.text;
    log("Recv url " + discuz.baseURL);
    // check the availability
    final dio = Dio();
    final client = MobileApiClient(dio, baseUrl: discuz.baseURL);
    setState(() {
      _isLoading = true;
    });

    client.sendLoginRequestInString(account, password).then((value) {
      log(value);
      LoginResult.fromJson(jsonDecode(value));

    });

    client.sendLoginRequest(account,password).then((value) {
      setState(() {
        _isLoading = false;
        error = "";
      });
      // check if the
      log("Recv a result ${value}");
      // if user is validated
      if(value.errorResult!.key == "login_succeed"){
        _saveDiscuzUserInDb(discuz, value.loginVariables.getUser(discuz));
      }
      else{
        setState(() {
          error = value.errorResult!.content;
        });
      }

    }).catchError((onError) {
      setState(() {
        _isLoading = false;
      });
      log(onError);


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

  Future<void> _saveDiscuzUserInDb(Discuz discuz, User user) async {
    try{
      final db = await DBHelper.getDiscuzDb();
      final dao = db.discuzDao;

      dao.insertDiscuz(discuz);
      // pop the activity
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('成功添加用户(${user.username})至${discuz.siteName}论坛')));
      Navigator.pop(context);
    }
    catch(e,s){
      log("${e},${s}");
    }

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
              if (_isLoading)
                LinearProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(
                      GlobalTheme.getThemeData().primaryColor),
                ),
              Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(
                    child: SvgPicture.asset(
                      "assets/images/login-user.svg",
                      semanticsLabel: '登录账号logo',
                      allowDrawingOutsideViewBox: true,
                      width: MediaQuery.of(context).size.width * 0.5,
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
                    ErrorCard("发生错误", error),
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
                        child: ElevatedButton(
                          style: ButtonStyle(

                          ),
                          child: Text("登录",style: TextStyle(color: Colors.white),),
                          onPressed: (){
                            _verifyAccountAndPassword();
                          },
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
