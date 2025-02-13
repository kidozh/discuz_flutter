

import 'package:discuz_flutter/dao/UserDao.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/LoginPage.dart';
import 'package:discuz_flutter/screen/BlankScreen.dart';
import 'package:discuz_flutter/screen/NullUserScreen.dart';
import 'package:discuz_flutter/utility/CustomizeColor.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class ManageAccountPage extends StatelessWidget{
  Discuz discuz;

  ManageAccountPage(this.discuz);

  @override
  Widget build(BuildContext context) {

    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(S.of(context).manageAccount),
        trailingActions: [
          PlatformIconButton(
            icon: Icon(Icons.add),
            onPressed: () async{
              VibrationUtils.vibrateWithClickIfPossible();
              await Navigator.push(context,
                  platformPageRoute(
                      context:context,
                      iosTitle: S.of(context).loginTitle,
                      builder: (context) => LoginPage(discuz, null)));
            },
          )
        ],
      ),
      body: ManageAccountStateWidget(discuz),
    );
  }

}

class ManageAccountStateWidget extends StatefulWidget{
  Discuz discuz;

  ManageAccountStateWidget(this.discuz);

  @override
  ManageAccountState createState() {
    // TODO: implement createState
    return ManageAccountState(discuz);
  }

}

class ManageAccountState extends State<ManageAccountStateWidget>{
  Discuz discuz;
  UserDao? _userDao;



  ManageAccountState(this.discuz){
    _initDb();
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initDb();

  }

  void _initDb() async {
    UserDao userDao = await AppDatabase.getUserDao();
    setState((){
      _userDao = userDao;
    });

  }

  Widget _buildUserListWidget(List<User> userList){
    return ListView.builder(
      itemBuilder: (context, index){
        User user = userList[index];
        return Slidable(
          child: ListTile(
            title: Text(user.username),
            subtitle: Text(S.of(context).userIdTitle(user.uid)),
            leading:  Container(
              // width: 16.0,
              // height: 16.0,
              child: CircleAvatar(
                backgroundColor: CustomizeColor.getColorBackgroundById(user.uid),
                child: Text(
                  user.username.length != 0
                      ? user.username[0].toUpperCase()
                      : S.of(context).anonymous,
                  style: TextStyle(color: Colors.white,fontSize: 18),
                ),
              ),
            ),
          ),
          endActionPane: ActionPane(
            motion: DrawerMotion(),
            extentRatio: 0.4,
            children: [
              SlidableAction(
                  label: S.of(context).deleteAccount,
                  backgroundColor: Colors.redAccent,
                  icon: Icons.delete,
                  onPressed: (context) {
                    VibrationUtils.vibrateWithClickIfPossible();
                    _deleteAccount(user);
                  }
              ),
              SlidableAction(
                  label: S.of(context).relogin,
                  backgroundColor: Colors.teal,
                  icon: Icons.refresh,
                  onPressed: (context) {
                    VibrationUtils.vibrateWithClickIfPossible();
                    Navigator.push(context,
                        platformPageRoute(
                            context: context,
                            iosTitle: S.of(context).loginTitle,
                            builder: (context) => LoginPage(discuz, user.username)));
                  },)
            ],
          ),
        );
      },
      itemCount: userList.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if(_userDao != null){
      return ValueListenableBuilder(
        valueListenable: _userDao!.userBox.listenable(),
        builder: (BuildContext context, Box<User> value, Widget? child) {
          List<User> userList = _userDao!.findAllUsersByDiscuz(discuz);
          if(userList.isEmpty){
            return NullUserScreen();
          }
          else {
            return _buildUserListWidget(userList);
          }
        },
      );
    }
    else{
      return BlankScreen();
    }

  }

  _deleteAccount(User user) async{
    if(_userDao!= null){
      await _userDao!.deleteUser(user);
      EasyLoading.showSuccess(S.of(context).deleteAccountSuccessfully(user.username));
    }


  }

}