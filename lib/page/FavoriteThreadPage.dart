

import 'package:discuz_flutter/JsonResult/FavoriteThreadResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/dao/FavoriteThreadDao.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/FavoriteThreadInDatabase.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/screen/BlankScreen.dart';
import 'package:discuz_flutter/screen/EmptyListScreen.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/TimeDisplayUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'ViewThreadSliverPage.dart';

class FavoriteThreadPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(S.of(context).favoriteThread),
        // trailingActions: [
        //   PlatformIconButton(
        //     onPressed: () async{
        //       VibrationUtils.vibrateWithClickIfPossible();
        //       // sync information from
        //     },
        //     icon: Icon(Icons.sync),
        //   )
        // ],
      ),
      body: FavoriteThreadStatefulWidget(),
    );
  }

}


class FavoriteThreadStatefulWidget extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return FavoriteThreadState();
  }

}

class FavoriteThreadState extends State<FavoriteThreadStatefulWidget>{

  late Discuz _discuz;
  late User? _user;

  // database
  FavoriteThreadDao? _favoriteThreadDao;

  int progress = 0;
  late MobileApiClient client;


  @override
  void initState() {
    super.initState();
    // get user and discuz from provider
    _user = Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
    _discuz = Provider.of<DiscuzAndUserNotifier>(context, listen: false).discuz!;
    // check with local data
    _loadDb();

  }

  Future<void> _loadDb() async{

    _favoriteThreadDao = await AppDatabase.getFavoriteThreadDao();
    setState(() {
      _favoriteThreadDao = _favoriteThreadDao;
    });

    var dio = await NetworkUtils.getDioWithPersistCookieJar(_user);
    client = MobileApiClient(dio, baseUrl: _discuz.baseURL);
    if(_user!= null){
      _loadDataFromServer();
    }

  }

  Future<void> _loadDataFromServer() async{
    // initial trial
    int page = 1;
    await fetchDataByPage(page, []);
  }

  Future<void> fetchDataByPage(int page, List<FavoriteThread> favoriteThreadList) async{
    print("load favorite thread data ${page}");
    client.favoriteThreadResult(page).then((value) async {

      int totalNumber = value.variables.count;
      List<FavoriteThread> favoriteThreadListInServer = value.variables.pmList;
      favoriteThreadList.addAll(favoriteThreadListInServer);
      print("Recv favorite thread data ${value} / ${totalNumber}");
      for(var favoriteThread in favoriteThreadListInServer){
        // save them one by one
        FavoriteThreadInDatabase? favoriteThreadInDatabase =
        await this._favoriteThreadDao!.getFavoriteThreadByTid(favoriteThread.id, _discuz);
        print("Get favoriteThread In DB ${favoriteThreadInDatabase}");
        if(favoriteThreadInDatabase == null){
          // insert it
          int insertId = await _favoriteThreadDao!.insertFavoriteThread(favoriteThread.toDb(_discuz));
          print("Inserted id ${insertId}");
        }
        else if(favoriteThreadInDatabase.favid != favoriteThread.favId){
          favoriteThreadInDatabase.favid = favoriteThread.favId;
          int insertId = await _favoriteThreadDao!.insertFavoriteThread(favoriteThreadInDatabase);
        }
      }

      if(totalNumber<= favoriteThreadList.length){
        // should finish all and refresh data
        if(totalNumber > 0){
          EasyLoading.showSuccess(S.of(context).syncSuccessfullyWithServer(totalNumber));
        }


      }
      else{
        // save the data into database

        EasyLoading.showProgress(favoriteThreadList.length/ totalNumber);

        fetchDataByPage(page+1, favoriteThreadList);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if(_favoriteThreadDao == null){
      return BlankScreen();
    }
    else{
      return ValueListenableBuilder(
        valueListenable: _favoriteThreadDao!.favoriteThreadBox.listenable(),
        builder: (BuildContext context, Box<FavoriteThreadInDatabase> value, Widget? child) {
          List<FavoriteThreadInDatabase> favoriteList = _favoriteThreadDao!.getFavoriteThreadList(_discuz);
          if(favoriteList.isNotEmpty){
            return ListView.builder(
                itemBuilder:(context, index){
                  return FavoriteThreadCardWidget(_discuz, _user, favoriteList[index]);
                },

                itemCount: favoriteList.length
            );
          }
          else{
            return EmptyListScreen(EmptyItemType.thread);
          }
        },
      );
    }

  }

}

class FavoriteThreadCardWidget extends StatelessWidget{
  FavoriteThreadInDatabase favoriteThreadInDatabase;
  Discuz discuz;
  User? user;
  FavoriteThreadCardWidget(this.discuz, this.user,this.favoriteThreadInDatabase);

  @override
  Widget build(BuildContext context) {
    return PlatformWidgetBuilder(

      material: (context, child, platform) => Card(
        elevation: 2.0,
        child: child,
      ),
      cupertino: (_, child, __) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if(child!= null)
            child,
          Divider()

        ],
      ),

      child: ListTile(
        title: Text(favoriteThreadInDatabase.title, style: Theme.of(context).textTheme.bodyLarge,),
        subtitle: RichText(
          text: TextSpan(
            text: "",
            style: DefaultTextStyle.of(context).style,
            children: <TextSpan>[
              //TextSpan(text: S.of(context).publishAt, style: TextStyle(fontWeight: FontWeight.w300)),
              TextSpan(text: favoriteThreadInDatabase.author, style: TextStyle(color: Theme.of(context).primaryColor)),
              TextSpan(text: " · "),
              TextSpan(text: TimeDisplayUtils.getLocaledTimeDisplay(context,favoriteThreadInDatabase.date)),
            ],
          ),
        ),
        onTap: () async {
          VibrationUtils.vibrateWithClickIfPossible();
          await Navigator.push(
              context,
              platformPageRoute(context:context,
                  iosTitle: favoriteThreadInDatabase.title.length > 12? S.of(context).viewThreadTitle: favoriteThreadInDatabase.title,
                  builder: (context) => ViewThreadSliverPage( discuz,  user, favoriteThreadInDatabase.idInServer,
                passedSubject: favoriteThreadInDatabase.title,
              ))
          );
        },


      ),
    );
  }

}

