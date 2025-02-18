

import 'package:discuz_flutter/dao/DiscuzDao.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/AddDiscuzPage.dart';
import 'package:discuz_flutter/page/ExclusiveDiscuzPortalPage.dart';
import 'package:discuz_flutter/screen/BlankScreen.dart';
import 'package:discuz_flutter/screen/NullUserScreen.dart';
import 'package:discuz_flutter/utility/AppPlatformIcons.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_ce_flutter/adapters.dart';

class ManageDiscuzPage extends StatelessWidget{

  @override
  Widget build(BuildContext context) {

    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(S.of(context).manageAccount),
        trailingActions: [
          PlatformIconButton(
            onPressed: () async{
              VibrationUtils.vibrateWithClickIfPossible();
              await Navigator.push(context,
                  platformPageRoute(
                      context:context,
                      iosTitle: S.of(context).addNewDiscuz,
                      builder: (context) => AddDiscuzPage()));
            },
            icon: Icon(Icons.add),
          )
        ],
      ),
      body: ManageDiscuzStateWidget(),
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
    super.initState();
    _initDb();

  }

  void _initDb() async {
    DiscuzDao discuzDao = await AppDatabase.getDiscuzDao();
    setState(() {
      _discuzDao = discuzDao;
    });

  }
  
  Widget _buildSecureIcon(BuildContext context,Discuz discuz){
    if(discuz.baseURL.startsWith("http://")){
      return Icon(AppPlatformIcons(context).inSecureHttpWarningSolid,color: Theme.of(context).splashColor);
    }
    if(discuz.isDiscuzVersion35){
      return Icon(AppPlatformIcons(context).supportDiscuz35Solid, color: Theme.of(context).colorScheme.primary);
    }
    else{
      return Icon(AppPlatformIcons(context).secureHttpsSolid, color: Theme.of(context).colorScheme.secondary,);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if(_discuzDao != null){
      return ValueListenableBuilder(
        valueListenable: _discuzDao!.discuzBox.listenable(),
        builder: (BuildContext context, value, Widget? child) {
          List<Discuz>? discuzList =  _discuzDao!.findAllDiscuzs();
          if(discuzList.isEmpty){
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
                        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                        child: Text(
                          discuz.siteName.length != 0
                              ? discuz.siteName[0].toUpperCase()
                              : S.of(context).anonymous,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer,fontSize: 18),
                        ),
                      ),
                    ),
                    trailing: _buildSecureIcon(context, discuz),
                    onTap: (){
                      VibrationUtils.vibrateWithClickIfPossible();
                      Navigator.push(context,
                          platformPageRoute(
                              context:context,
                              iosTitle: discuz.siteName,
                              builder: (context) => ExclusiveDiscuzPortalPage(discuz)));
                    },
                  ),
                  endActionPane: ActionPane(
                    motion: DrawerMotion(),
                    extentRatio: 0.25,
                    children: [
                      SlidableAction(
                        label: S.of(context).deleteAccount,
                        backgroundColor: Colors.redAccent,
                        icon: Icons.delete,
                        onPressed: (context) {
                          _deleteDiscuz(discuz);
                        },

                      )
                    ],
                  ),
                );
              },
              itemCount: discuzList.length,
            );
          }

        },

      );
      // return StreamBuilder(
      //     stream: _discuzDao!.findAllDiscuzStream(),
      //     builder: (BuildContext context, AsyncSnapshot<List<Discuz>> snapshot){
      //       List<Discuz>? discuzList = snapshot.data;
      //       if(discuzList == null || discuzList.isEmpty){
      //         return NullUserScreen();
      //       }
      //       else {
      //         return ListView.builder(
      //           itemBuilder: (context, index){
      //             Discuz discuz = discuzList[index];
      //             return Slidable(
      //               child: ListTile(
      //                 title: Text(discuz.siteName),
      //                 subtitle: Text(discuz.baseURL),
      //                 leading:  Container(
      //                   // width: 16.0,
      //                   // height: 16.0,
      //                   child: CircleAvatar(
      //                     backgroundColor: Theme.of(context).primaryColor,
      //                     child: Text(
      //                       discuz.siteName.length != 0
      //                           ? discuz.siteName[0].toUpperCase()
      //                           : S.of(context).anonymous,
      //                       style: TextStyle(color: Colors.white,fontSize: 18),
      //                     ),
      //                   ),
      //                 ),
      //                 trailing: _buildSecureIcon(context, discuz),
      //                 onTap: (){
      //                   VibrationUtils.vibrateWithClickIfPossible();
      //                   Navigator.push(context,
      //                       platformPageRoute(context:context,builder: (context) => ExclusiveDiscuzPortalPage(discuz)));
      //                 },
      //               ),
      //               endActionPane: ActionPane(
      //                 motion: DrawerMotion(),
      //                 extentRatio: 0.25,
      //                 children: [
      //                   SlidableAction(
      //                       label: S.of(context).deleteAccount,
      //                       backgroundColor: Colors.redAccent,
      //                       icon: Icons.delete,
      //                       onPressed: (context) {
      //                         _deleteDiscuz(discuz);
      //                       },
      //
      //                   )
      //                 ],
      //               ),
      //             );
      //           },
      //           itemCount: discuzList.length,
      //         );
      //       }
      //
      //     }
      // );
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