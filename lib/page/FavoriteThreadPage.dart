

import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/JsonResult/FavoriteThreadResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/dao/FavoriteThreadDao.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/FavoriteThreadInDatabase.dart';
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

import 'UserProfilePage.dart';
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
  late AppDatabase db;
  late FavoriteThreadDao _favoriteThreadDao;
  Stream<List<FavoriteThreadInDatabase>> _streamInDb = Stream.fromIterable([]);
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
    _favoriteThreadDao = db.favoriteThreadDao;
    setState(() {
      _streamInDb = _favoriteThreadDao.getFavoriteThreadListStream(_discuz.id!);
    });

    var dio = await NetworkUtils.getDioWithPersistCookieJar(_user);
    client = MobileApiClient(dio, baseUrl: _discuz.baseURL);
    _loadDataFromServer();
  }

  void _loadDataFromServer() async{
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
        await this._favoriteThreadDao.getFavoriteThreadByTid(favoriteThread.id, _discuz.id!);
        print("Get favoriteThread In DB ${favoriteThreadInDatabase}");
        if(favoriteThreadInDatabase == null){
          // insert it
          int insertId = await _favoriteThreadDao.insertFavoriteThread(favoriteThread.toDb(_discuz));
          print("Inserted id ${insertId}");
        }
        else if(favoriteThreadInDatabase.favid != favoriteThread.favId){
          favoriteThreadInDatabase.favid = favoriteThread.favId;
          int insertId = await _favoriteThreadDao.insertFavoriteThread(favoriteThreadInDatabase);
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
    return StreamBuilder(
        stream: _streamInDb,
        builder: (context, AsyncSnapshot<List<FavoriteThreadInDatabase>> snapshot){
          if(snapshot.data!=null && snapshot.data!.length!= 0){
            return ListView.builder(
                itemBuilder:(context, index){
                  return FavoriteThreadCardWidget(_discuz, _user, snapshot.data![index]);
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

class FavoriteThreadCardWidget extends StatelessWidget{
  FavoriteThreadInDatabase favoriteThreadInDatabase;
  Discuz discuz;
  User? user;
  FavoriteThreadCardWidget(this.discuz, this.user,this.favoriteThreadInDatabase);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: ListTile(
        title: Hero(
          tag: ConstUtils.HERO_TAG_THREAD_SUBJECT,
          child: Text(favoriteThreadInDatabase.title, style: Theme.of(context).textTheme.headline6,),
        ),
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
              platformPageRoute(context:context,builder: (context) => ViewThreadSliverPage( discuz,  user, favoriteThreadInDatabase.idInServer,
                passedSubject: favoriteThreadInDatabase.title,
              ))
          );
        },


      ),
    );
  }

}

