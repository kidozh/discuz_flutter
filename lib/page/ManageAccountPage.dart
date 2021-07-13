

import 'package:discuz_flutter/dao/UserDao.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/LoginPage.dart';
import 'package:discuz_flutter/screen/BlankScreen.dart';
import 'package:discuz_flutter/screen/NullUserScreen.dart';
import 'package:discuz_flutter/utility/CustomizeColor.dart';
import 'package:discuz_flutter/utility/DBHelper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ManageAccountPage extends StatelessWidget{
  Discuz discuz;

  ManageAccountPage(this.discuz);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).manageAccount),
      ),
      body: ManageAccountStateWidget(discuz),
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          await Navigator.push(context,
              platformPageRoute(context:context,builder: (context) => LoginPage(discuz, null)));
        },
        tooltip: S.of(context).addNewDiscuz,
        child: Icon(Icons.add),
      ),
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
    final db = await DBHelper.getAppDb();
    setState(() {
      _userDao = db.userDao;
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
          actionPane: SlidableDrawerActionPane(),
          actions: [
            IconSlideAction(
              caption: S.of(context).deleteAccount,
              color: Colors.redAccent,
              icon: Icons.delete,
              onTap: () {
                _deleteAccount(user);
              },
            ),
            IconSlideAction(
              caption: S.of(context).relogin,
              color: Colors.teal,
              icon: Icons.refresh,
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginPage(discuz, user.username)));
              },
            ),
          ],
        );
      },
      itemCount: userList.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if(_userDao != null){
      return StreamBuilder(
          stream: _userDao!.findAllUsersStreamByDiscuzId(discuz.id!),
          builder: (BuildContext context, AsyncSnapshot<List<User>> snapshot){
            List<User>? userList = snapshot.data;
            if(userList == null || userList.isEmpty){
              return NullUserScreen();
            }
            else {
              return _buildUserListWidget(userList);
            }

          }
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