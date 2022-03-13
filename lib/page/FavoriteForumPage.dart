

import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/JsonResult/FavoriteForumResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/dao/FavoriteForumDao.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/FavoriteForumInDatabase.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/screen/EmptyListScreen.dart';
import 'package:discuz_flutter/utility/ConstUtils.dart';
import 'package:discuz_flutter/utility/CustomizeColor.dart';
import 'package:discuz_flutter/utility/DBHelper.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/TimeDisplayUtils.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

import 'DisplayForumSliverPage.dart';
import 'UserProfilePage.dart';
import 'ViewThreadSliverPage.dart';

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

  // database
  late AppDatabase db;
  late FavoriteForumDao _FavoriteForumDao;
  Stream<List<FavoriteForumInDatabase>> _streamInDb = Stream.fromIterable([]);
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
    db = await DBHelper.getAppDb();
    _FavoriteForumDao = db.favoriteForumDao;
    setState(() {
      _streamInDb = _FavoriteForumDao.getFavoriteForumListStream(_discuz.id!);
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
        await this._FavoriteForumDao.getFavoriteForumByTid(favoriteForum.id, _discuz.id!);
        print("Get FavoriteForum In DB ${FavoriteForumInDatabase}");
        if(favoriteForumInDatabase == null){
          // insert it
          int insertId = await _FavoriteForumDao.insertFavoriteForum(favoriteForum.toDb(_discuz));
          print("Inserted id ${insertId}");
        }
        else if(favoriteForumInDatabase.favid != favoriteForum.favId){
          favoriteForumInDatabase.favid = favoriteForum.favId;
          int insertId = await _FavoriteForumDao.insertFavoriteForum(favoriteForumInDatabase);
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
    return StreamBuilder(
        stream: _streamInDb,
        builder: (context, AsyncSnapshot<List<FavoriteForumInDatabase>> snapshot){
          if(snapshot.data!=null && snapshot.data!.length!= 0){
            return ListView.builder(
                itemBuilder:(context, index){
                  return FavoriteForumCardWidget(_discuz, _user, snapshot.data![index]);
                },

                itemCount: snapshot.data?.length
            );
          }
          else{
            return EmptyListScreen();
          }

        }
    );

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

