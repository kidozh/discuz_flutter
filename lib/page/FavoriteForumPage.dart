

import 'package:discuz_flutter/JsonResult/FavoriteForumResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/dao/FavoriteForumDao.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/FavoriteForumInDatabase.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/screen/BlankScreen.dart';
import 'package:discuz_flutter/screen/EmptyListScreen.dart';
import 'package:discuz_flutter/utility/ConstUtils.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/TimeDisplayUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'DisplayForumSliverPage.dart';

class FavoriteForumPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(S.of(context).favoriteForum),

      ),
      body: FavoriteForumStatefulWidget(),
    );
  }

}


class FavoriteForumStatefulWidget extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return FavoriteForumState();
  }

}

class FavoriteForumState extends State<FavoriteForumStatefulWidget>{

  late Discuz _discuz;
  late User? _user;


  late FavoriteForumDao _favoriteForumDao;
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

  void _loadDb() async{

    _favoriteForumDao = await AppDatabase.getFavoriteForumDao();
    setState(() {
      _favoriteForumDao = _favoriteForumDao;
    });

    var dio = await NetworkUtils.getDioWithPersistCookieJar(_user);
    client = MobileApiClient(dio, baseUrl: _discuz.baseURL);
    if(_user!= null){
      _loadDataFromServer();
    }

  }

  void _loadDataFromServer() async{
    // initial trial
    int page = 1;
    await fetchDataByPage(page, []);
  }

  Future<void> fetchDataByPage(int page, List<FavoriteForum> FavoriteForumList) async{
    print("load favorite forum data ${page}");
    client.favoriteForumResult(page).then((value) async {

      int totalNumber = value.variables.count;
      List<FavoriteForum> FavoriteForumListInServer = value.variables.pmList;
      FavoriteForumList.addAll(FavoriteForumListInServer);
      print("Recv favorite forum data ${value} / ${totalNumber}");
      for(var favoriteForum in FavoriteForumListInServer){
        // save them one by one
        FavoriteForumInDatabase? favoriteForumInDatabase =
        this._favoriteForumDao.getFavoriteForumByFid(favoriteForum.id, _discuz);
        print("Get FavoriteForum In DB ${FavoriteForumInDatabase}");
        if(favoriteForumInDatabase == null){
          // insert it
          int insertId = await _favoriteForumDao.insertFavoriteForum(favoriteForum.toDb(_discuz));
          print("Inserted id ${insertId}");
        }
        else if(favoriteForumInDatabase.favid != favoriteForum.favId){
          favoriteForumInDatabase.favid = favoriteForum.favId;
          int insertId = await _favoriteForumDao.insertFavoriteForum(favoriteForumInDatabase);
        }
      }

      if(totalNumber<= FavoriteForumList.length){
        // should finish all and refresh data
        if(totalNumber > 0){
          EasyLoading.showSuccess(S.of(context).syncSuccessfullyWithServer(totalNumber));
        }


      }
      else{
        // save the data into database

        EasyLoading.showProgress(FavoriteForumList.length/ totalNumber);

        fetchDataByPage(page+1, FavoriteForumList);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if(_favoriteForumDao == null){
      return BlankScreen();
    }
    else{
      return ValueListenableBuilder(
        valueListenable: _favoriteForumDao.favoriteForumBox.listenable(),
        builder: (BuildContext context, Box<FavoriteForumInDatabase> value, Widget? child) {
          List<FavoriteForumInDatabase> favoriteForumList = _favoriteForumDao!.getFavoriteForumList(_discuz);
          if(favoriteForumList.isNotEmpty){
            return ListView.builder(
                itemBuilder:(context, index){
                  return FavoriteForumCardWidget(_discuz, _user, favoriteForumList[index]);
                },

                itemCount: favoriteForumList.length
            );
          }
          else{
            return EmptyListScreen();
          }
        },

      );
    }
  }

}

class FavoriteForumCardWidget extends StatelessWidget{
  FavoriteForumInDatabase favoriteForumInDatabase;
  Discuz discuz;
  User? user;
  FavoriteForumCardWidget(this.discuz, this.user,this.favoriteForumInDatabase);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: ListTile(
        leading: Icon(Icons.forum_rounded),
        title: Hero(
          tag: ConstUtils.HERO_TAG_FORUM_TITLE,
          child: Text(favoriteForumInDatabase.title, style: Theme.of(context).textTheme.headline6,),
        ),
        subtitle: Text(TimeDisplayUtils.getLocaledTimeDisplay(context, favoriteForumInDatabase.date)),
        onTap: () async {
          VibrationUtils.vibrateWithClickIfPossible();
          await Navigator.push(
              context,
              platformPageRoute(context:context,builder: (context) => DisplayForumSliverPage(discuz, user, favoriteForumInDatabase.idKey))
          );
        },


      ),
    );
  }

}

