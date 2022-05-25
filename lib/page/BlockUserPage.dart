
import 'package:discuz_flutter/dao/BlockUserDao.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/entity/BlockUser.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/screen/BlankScreen.dart';
import 'package:discuz_flutter/screen/EmptyListScreen.dart';
import 'package:discuz_flutter/widget/UserAvatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/generated/l10n.dart';

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

    setState(() async{
      _blockUserDao = await AppDatabase.getBlockUserDao();
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
          stream: _blockUserDao!.getBlockUserListStream(_discuz),
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
                                leading: UserAvatar(_discuz, User("","",blockUserList[index].name,"",0,blockUserList[index].uid, 0, _discuz)),
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
