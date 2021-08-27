

import 'package:discuz_flutter/page/ExclusiveDiscuzPortalPage.dart';
import 'package:discuz_flutter/dao/DiscuzDao.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/AddDiscuzPage.dart';
import 'package:discuz_flutter/screen/BlankScreen.dart';
import 'package:discuz_flutter/screen/NullUserScreen.dart';
import 'package:discuz_flutter/utility/CustomizeColor.dart';
import 'package:discuz_flutter/utility/DBHelper.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ManageDiscuzPage extends StatelessWidget{

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).manageAccount),
      ),
      body: ManageDiscuzStateWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          VibrationUtils.vibrateWithClickIfPossible();
          await Navigator.push(context,
              platformPageRoute(context:context,builder: (context) => AddDiscuzPage()));
        },
        tooltip: S.of(context).addNewDiscuz,
        child: Icon(Icons.add),
      ),
    );
  }

}

class ManageDiscuzStateWidget extends StatefulWidget{

  @override
  ManageDiscuzState createState() {
    // TODO: implement createState
    return ManageDiscuzState();
  }

}

class ManageDiscuzState extends State<ManageDiscuzStateWidget>{
  DiscuzDao? _discuzDao;



  ManageAccountState(){
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
      _discuzDao = db.discuzDao;
    });

  }
  
  Widget _buildSecureIcon(BuildContext context,Discuz discuz){
    if(discuz.baseURL.startsWith("http://")){
      return Icon(Icons.privacy_tip,color: Colors.deepOrange);
    }
    else{
      return Icon(Icons.check_circle, color: Colors.teal,);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if(_discuzDao != null){
      return StreamBuilder(
          stream: _discuzDao!.findAllDiscuzStream(),
          builder: (BuildContext context, AsyncSnapshot<List<Discuz>> snapshot){
            List<Discuz>? discuzList = snapshot.data;
            if(discuzList == null || discuzList.isEmpty){
              return NullUserScreen();
            }
            else {
              return ListView.builder(
                itemBuilder: (context, index){
                  Discuz discuz = discuzList[index];
                  return Slidable(
                    child: ListTile(
                      title: Text(discuz.siteName),
                      subtitle: Text(discuz.baseURL),
                      leading:  Container(
                        // width: 16.0,
                        // height: 16.0,
                        child: CircleAvatar(
                          backgroundColor: CustomizeColor.getColorBackgroundById(discuz.id!),
                          child: Text(
                            discuz.siteName.length != 0
                                ? discuz.siteName[0].toUpperCase()
                                : S.of(context).anonymous,
                            style: TextStyle(color: Colors.white,fontSize: 18),
                          ),
                        ),
                      ),
                      trailing: _buildSecureIcon(context, discuz),
                      onTap: (){
                        VibrationUtils.vibrateWithClickIfPossible();
                        Navigator.push(context,
                            platformPageRoute(context:context,builder: (context) => ExclusiveDiscuzPortalPage(discuz)));
                      },
                    ),
                    
                    actionPane: SlidableDrawerActionPane(),
                    actions: [
                      IconSlideAction(
                        caption: S.of(context).deleteAccount,
                        color: Colors.redAccent,
                        icon: Icons.delete,
                        onTap: () {
                          _deleteDiscuz(discuz);
                        },
                      ),
                    ],
                  );
                },
                itemCount: discuzList.length,
              );
            }

          }
      );
    }
    else{
      return BlankScreen();
    }

  }

  _deleteDiscuz(Discuz discuz) async{
    if(_discuzDao!= null){
      await _discuzDao!.deleteDiscuz(discuz);
      EasyLoading.showSuccess(S.of(context).deleteDiscuzSuccessfully(discuz.siteName));
    }


  }

}