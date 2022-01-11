import 'dart:collection';
import 'dart:developer';

import 'package:discuz_flutter/JsonResult/SmileyResult.dart';
import 'package:discuz_flutter/JsonResult/ViewThreadResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/dao/BlockUserDao.dart';
import 'package:discuz_flutter/dao/ViewHistoryDao.dart';
import 'package:discuz_flutter/entity/BlockUser.dart';
import 'package:discuz_flutter/entity/DiscuzError.dart';
import 'package:discuz_flutter/entity/Post.dart';
import 'package:discuz_flutter/entity/Smiley.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/entity/ViewHistory.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/screen/BlankScreen.dart';
import 'package:discuz_flutter/screen/EmptyListScreen.dart';
import 'package:discuz_flutter/screen/ExtraFuncInThreadScreen.dart';
import 'package:discuz_flutter/screen/SmileyListScreen.dart';
import 'package:discuz_flutter/utility/ConstUtils.dart';
import 'package:discuz_flutter/utility/DBHelper.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/PostTextFieldUtils.dart';
import 'package:discuz_flutter/utility/RewriteRuleUtils.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:discuz_flutter/widget/CaptchaWidget.dart';
import 'package:discuz_flutter/widget/ErrorCard.dart';
import 'package:discuz_flutter/widget/PollWidget.dart';
import 'package:discuz_flutter/widget/PostTextField.dart';
import 'package:discuz_flutter/widget/PostWidget.dart';
import 'package:discuz_flutter/widget/UserAvatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:dio/dio.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:intl/intl.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:provider/provider.dart';
import 'package:discuz_flutter/provider/ReplyPostNotifierProvider.dart';
import 'InternalWebviewBrowserPage.dart';

class BlockUserPage extends StatelessWidget {
  late final Discuz discuz;


  BlockUserPage(this.discuz);

  @override
  Widget build(BuildContext context) {
    return BlockUserStatefulWidget(discuz);
  }
}

class BlockUserStatefulWidget extends StatefulWidget {
  late final Discuz discuz;


  BlockUserStatefulWidget(this.discuz);

  @override
  _BlockUserState createState() {
    return _BlockUserState(this.discuz);
  }
}

class _BlockUserState extends State<BlockUserStatefulWidget> {
  Discuz _discuz;

  _BlockUserState(this._discuz);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initDb();
  }

  BlockUserDao? _blockUserDao;

  void _initDb() async {
    final db = await DBHelper.getAppDb();
    setState(() {
      _blockUserDao = db.blockUserDao;
    });

  }

  @override
  Widget build(BuildContext context) {
    if(_blockUserDao == null){
      return BlankScreen();
    }
    else{
      return PlatformScaffold(
        appBar: PlatformAppBar(
          title: Text(S.of(context).blockedUserList),
          automaticallyImplyLeading: true,
        ),
        body: StreamBuilder(
          stream: _blockUserDao!.getBlockUserListStream(_discuz.id!),
          builder: (BuildContext context, AsyncSnapshot<List<BlockUser>> snapshot) {
            List<BlockUser>? blockUserList = snapshot.data;
            if (blockUserList == null || blockUserList.isEmpty){
              return EmptyListScreen();
            }
            else{
              return ListView.builder(
                itemCount: blockUserList.length,
                itemBuilder: (context, index){
                  return Dismissible(
                      background: Container(color: Colors.pinkAccent),
                      key: Key(index.toString()),
                      child: InkWell(
                        child: Card(
                          child: Container(
                            width: double.infinity,
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: ListTile(
                                leading: UserAvatar(_discuz, User(null,"","",blockUserList[index].name,"",0,blockUserList[index].uid, 0, _discuz.id!)),
                                title: Text(blockUserList[index].name),
                              )

                            ),
                          ),
                        ),
                      ),
                      onDismissed: (direction) async{
                        _blockUserDao?.deleteBlockUser(blockUserList[index]);
                      },
                  );
                },
              );
            }
          },
        ),
      );
    }
  }

}
