import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:discuz_flutter/JsonResult/PrivateMessageDetailResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/DiscuzError.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/screen/NullDiscuzScreen.dart';
import 'package:discuz_flutter/screen/NullUserScreen.dart';
import 'package:discuz_flutter/screen/SmileyListScreen.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:discuz_flutter/widget/ErrorCard.dart';
import 'package:discuz_flutter/widget/PrivateMessageDetailWidget.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

import '../utility/AppPlatformIcons.dart';
import '../utility/EasyRefreshUtils.dart';
import 'UserProfilePage.dart';

class PrivateMessageDetailScreen extends StatelessWidget {
  int toUid;
  String toUsername;

  PrivateMessageDetailScreen(this.toUid, this.toUsername);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return PrivateMessageDetailStatefulWidget(toUid, toUsername);
  }
}

class PrivateMessageDetailStatefulWidget extends StatefulWidget {
  int toUid;
  String toUsername;

  PrivateMessageDetailStatefulWidget(this.toUid, this.toUsername);

  _PrivateMessageDetailState createState() {
    return _PrivateMessageDetailState(toUid, toUsername);
  }
}

class _PrivateMessageDetailState
    extends State<PrivateMessageDetailStatefulWidget> {
  late Dio _dio;
  int toUid;
  late MobileApiClient _client;
  PrivateMessageDetailResult result = PrivateMessageDetailResult();
  DiscuzError? _error;
  int _page = 1;
  List<PrivateMessageDetail> _pmList = [];

  late EasyRefreshController _controller;

  String toUsername;

  bool showSmiley = false;

  _PrivateMessageDetailState(this.toUid, this.toUsername);

  // 输入框
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _controller = EasyRefreshController(controlFinishLoad: true, controlFinishRefresh: true);

    _textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _textEditingController.dispose();

  }

  Future<IndicatorResult> _invalidateHotThreadContent(Discuz discuz) async {
    _page = 0;
    setState(() {
      _pmList = [];
    });

    return await _loadPortalPrivateMessage(discuz);
  }

  Future<void> _sendMessage(String message) async{
    Discuz discuz = Provider.of<DiscuzAndUserNotifier>(context, listen: false).discuz!;
    User? user =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
    this._dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    this._client = MobileApiClient(_dio, baseUrl: discuz.baseURL);

    _client.sendPrivateMessageResult(result.variables.formHash, message, toUid).then((value){
      if (value.errorResult!.key == "do_success") {
        EasyLoading.showSuccess(
            '${value.errorResult!.content}(${value.errorResult!.key})');

        // delay
        Future.delayed(Duration(microseconds: 5), () {
          setState(() {
            _textEditingController.clear();
          });
          _invalidateHotThreadContent(discuz);
        });
      } else {
        VibrationUtils.vibrateErrorIfPossible();
        EasyLoading.showError(
            '${value.errorResult!.content}(${value.errorResult!.key})');
      }
    }).catchError((onError) {
      VibrationUtils.vibrateErrorIfPossible();
      EasyLoading.showError('${onError}');
    });
  }

  Future<IndicatorResult> _loadPortalPrivateMessage(Discuz discuz) async {
    User? user =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
    this._dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    this._client = MobileApiClient(_dio, baseUrl: discuz.baseURL);

    // _client.hotThreadRaw(_page).then((value){
    //   log(value);
    //   result = HotThreadResult.fromJson(jsonDecode(value));
    //
    // });

    return await _client.privateMessageDetailResult(toUid, _page).then((value) {
      setState(() {
        result = value;
        _error = null;
        _pmList.addAll(new List.from(value.variables.pmList.reversed));
        // if (_page == 1) {
        //   _pmList = new List.from(value.variables.pmList.reversed);
        // } else {
        //
        // }
      });
      _page = value.variables.page-1;
      _controller.finishRefresh();

      // check for loaded all?
      log("Get HotThread ${_pmList.length} ${value.variables.count}");
      _controller.finishLoad(_pmList.length >= value.variables.count? IndicatorResult.noMore: IndicatorResult.success);

      if (user != null && value.variables.member_uid != user.uid) {
        setState(() {
          _error = DiscuzError(S.of(context).userExpiredTitle(user.username),
              S.of(context).userExpiredSubtitle);
        });
      }

      if (value.getErrorString() != null) {
        EasyLoading.showError(value.getErrorString()!);
      }

      if (value.errorResult != null) {
        setState(() {
          _error =
              DiscuzError(value.errorResult!.key, value.errorResult!.content);
        });
      } else {
        setState(() {
          _error = null;
        });
      }
      if(_pmList.length >= value.variables.count){
        return IndicatorResult.noMore;
      }
      else{
        return IndicatorResult.success;
      }
    }).catchError((onError) {
      VibrationUtils.vibrateErrorIfPossible();
      EasyLoading.showError('${onError}');
      _controller.finishRefresh();
      setState(() {
        _error =
            DiscuzError(onError.runtimeType.toString(), onError.toString());
      });
      return IndicatorResult.fail;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DiscuzAndUserNotifier>(
        builder: (context, discuzAndUser, child) {
      if (discuzAndUser.discuz == null) {
        return PlatformScaffold(
            iosContentBottomPadding: true,
            iosContentPadding: true,
            appBar: PlatformAppBar(),
            body: NullDiscuzScreen(),
        );

      } else if (discuzAndUser.user == null) {
        return PlatformScaffold(
          iosContentBottomPadding: true,
          iosContentPadding: true,
          appBar: PlatformAppBar(),
          body: NullUserScreen(),
        );
      }
      return PlatformScaffold(
        iosContentBottomPadding: true,
        iosContentPadding: true,
        appBar: PlatformAppBar(
          title: Text(toUsername),
          trailingActions: [
            IconButton(
              icon: Icon(AppPlatformIcons(context).userProfileSolid, size: 28,),
              onPressed: () {
                Navigator.push(
                    context,
                    platformPageRoute(
                        context: context,
                        builder: (context) => UserProfilePage(
                            discuzAndUser.discuz!, discuzAndUser.user, toUid)));
              },
            )
          ],
        ),
        body: Column(
          children: [
            if (_error != null)
              ErrorCard(_error!, () {
                _controller.callRefresh();
              }),
            Expanded(
              flex: 1,
              child: LayoutBuilder(
                builder: (context, constraints) {

                  Discuz discuz = discuzAndUser.discuz!;
                  User? user = discuzAndUser.user;
                  return EasyRefresh(
                    refreshOnStart: true,
                    onRefresh:  () async {
                            return await _invalidateHotThreadContent(discuz);
                          },
                    onLoad:  () async {
                            return await _loadPortalPrivateMessage(discuz);
                          }
                        ,
                    child: ListView.builder(itemBuilder: (context, index){
                      return PrivateMessageDetailWidget(
                          discuz, user, _pmList[index]);
                    }, itemCount: _pmList.length,),

                  );
                },
              ),
            ),
            Container(
              child: Container(
                color: Colors.grey[100],
                padding: EdgeInsets.only(
                  left: 15.0,
                  right: 15.0,
                  top: 10.0,
                  bottom: 10.0,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: EdgeInsets.only(
                          left: 5.0,
                          right: 5.0,
                          top: 10.0,
                          bottom: 10.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(
                            4.0,
                          )),
                        ),
                        child: TextField(
                          controller: _textEditingController,
                          decoration: null,
                          style: TextStyle(color: Colors.black),
                          onSubmitted: (value) {
                            if (_textEditingController.text.isNotEmpty) {
                              VibrationUtils.vibrateWithClickIfPossible();
                              _sendMessage( _textEditingController.text);
                              //_sendMsg(_textEditingController.text);

                            }
                          },
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: (){
                        VibrationUtils.vibrateWithClickIfPossible();
                        setState((){
                          showSmiley = !showSmiley;
                        });

                      },
                      child: Container(
                        height: 30.0,
                        width: 30.0,
                        margin: EdgeInsets.only(left: 10.0),
                        child: Icon(showSmiley? Icons.keyboard_rounded :Icons.emoji_emotions, color: Colors.grey.shade700,),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (_textEditingController.text.isNotEmpty) {
                          VibrationUtils.vibrateWithClickIfPossible();
                          _sendMessage( _textEditingController.text);
                        }
                      },
                      child: Container(
                        height: 30.0,
                        width: 60.0,
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(
                          left: 10.0,
                        ),
                        decoration: BoxDecoration(
                          color: _textEditingController.text.isEmpty
                              ? Colors.grey
                              : Colors.green,
                          borderRadius: BorderRadius.all(Radius.circular(
                            4.0,
                          )),
                        ),
                        child: Text(
                          S.of(context).send,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if(showSmiley)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [SmileyListScreen((smiley){
                  print("Smiley is pressed ${smiley.code} ${smiley.relativePath}");
                  final text = _textEditingController.text;
                  String smileyCode = smiley.code.substring(1,smiley.code.length-1);
                  smileyCode = smileyCode.replaceAll(r"\:", ":").replaceAll(r"\{", "{");
                  final selection = _textEditingController.selection;
                  print("replacing ${selection.start} ${selection.end} ${selection.isCollapsed} ${_textEditingController.selection.isDirectional}");
                  if(selection.start == -1 || selection.end == -1){
                    final newText = text + smileyCode;
                    _textEditingController.value = TextEditingValue(
                        text: newText,
                        selection: TextSelection.collapsed(offset: text.length + smileyCode.length)
                    );
                  }
                  else{
                    final newText = text.replaceRange(selection.start, selection.end, smileyCode);
                    _textEditingController.value = TextEditingValue(
                        text: newText,
                        selection: TextSelection.collapsed(offset: selection.baseOffset + smileyCode.length)
                    );
                  }


                })],
              )
          ],
        ),
      );
    });
  }

  Widget getEasyRefreshWidget(Discuz discuz, User? user) {
    return EasyRefresh(
      header: EasyRefreshUtils.i18nClassicHeader(context),
      footer: EasyRefreshUtils.i18nClassicFooter(context),
      refreshOnStart: true,
      controller: _controller,
      onRefresh: () async {
              return _invalidateHotThreadContent(discuz);


            },
      onLoad:() async {
              return await _loadPortalPrivateMessage(discuz);
            },
      child: ListView.builder(
          itemBuilder: (context, index){
            return PrivateMessageDetailWidget(discuz, user, _pmList[index]);
          },
          itemCount: _pmList.length,
      ),
    );
  }
}
