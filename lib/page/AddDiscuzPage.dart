import 'dart:convert';
import 'dart:developer';

import 'package:discuz_flutter/JsonResult/CheckResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/utility/DBHelper.dart';
import 'package:discuz_flutter/utility/GlobalTheme.dart';
import 'package:discuz_flutter/widget/ErrorCard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:dio/dio.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:form_validator/form_validator.dart';

class AddDiscuzPage extends StatelessWidget {
  AddDiscuzPage({Key? key}):super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("添加一个论坛"),
        ),
        body: AddDiscuzForumFieldStatefulWidget());
  }
}

class AddDiscuzForumFieldStatefulWidget extends StatefulWidget {
  AddDiscuzForumFieldStatefulWidget({Key? key}):super(key: key);
  @override
  _AddDiscuzFormFieldState createState() {
    // TODO: implement createState
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
    await dao.insertDiscuz(discuz);
    // pop the activity
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('成功添加${discuz.siteName}论坛')));
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
    // TODO: implement build

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
                  decoration: new InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "网页地址",
                    hintText: "键入网页地址，如https://bbs.nwpu.edu.cn",
                    helperText: "网页地址通常是论坛服务的地址",
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
                ButtonBar(
                  children: [
                    TextButton(
                      child: Text("取消添加"),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    ElevatedButton(
                      child: Text("检查并添加"),
                      onPressed: () {
                        log("Press the elevated button");
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text('访问网页API中')));
                          _checkApiAvailable();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("您输入的内容似乎不正确？")));
                        }
                      },
                    )
                  ],
                )
              ],
            ),
          )),
        );
  }
}
