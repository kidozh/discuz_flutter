import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/JsonResult/SmileyResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/dao/SmileyDao.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/Smiley.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/screen/NullDiscuzScreen.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'BlankScreen.dart';

typedef SmileyPressedFunc = void Function(Smiley);

class SmileyListScreen extends StatelessWidget {
  SmileyPressedFunc onSmileyPressed;

  SmileyListScreen(this.onSmileyPressed);

  @override
  Widget build(BuildContext context) {
    return SmileyListStatefulWidget(onSmileyPressed);
  }

}

class SmileyListStatefulWidget extends StatefulWidget {
  SmileyPressedFunc smileyValueGetter;

  SmileyListStatefulWidget(this.smileyValueGetter);

  @override
  State<SmileyListStatefulWidget> createState() {
    return SmileyListState(this.smileyValueGetter);
  }

}

class SmileyListState extends State<SmileyListStatefulWidget> {
  SmileyPressedFunc smileyValueGetter;

  SmileyListState(this.smileyValueGetter);

  SmileyResult? result;
  late SmileyDao _smileyDao;
  List<Smiley> _savedSmileyList = [];

  @override
  void initState() {
    super.initState();
    _initDB();
    _loadSmilesInfo();
  }

  void _initDB() async {

    _smileyDao = await AppDatabase.getSmileyDao();
    Discuz? discuz = Provider
        .of<DiscuzAndUserNotifier>(context, listen: false)
        .discuz;
    if (discuz == null) {
      return;
    }
    var smileyList = await _smileyDao.findAllSmileyByDiscuz(discuz);
    setState(() {
      _savedSmileyList = smileyList;
    });
  }

  void _loadSmilesInfo() async {
    Discuz? discuz = Provider
        .of<DiscuzAndUserNotifier>(context, listen: false)
        .discuz;
    if (discuz == null) {
      return;
    }
    User? user =
        Provider
            .of<DiscuzAndUserNotifier>(context, listen: false)
            .user;
    final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    final client = MobileApiClient(dio, baseUrl: discuz.baseURL);
    print("load smiley");
    client.smileyResult().then((value) {
      print("load result ${value}");
      print("load smiley ${value.variables.smilies}");
      setState(() {
        result = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Discuz? discuz = Provider
        .of<DiscuzAndUserNotifier>(context, listen: false)
        .discuz;
    if (discuz == null) {
      return NullDiscuzScreen();
    }
    else {
      List<Tab> smileyTab = [];
      List<List<Smiley>> smileyList = [];
      List<Widget> tabBarViewList = [];
      // add saved smiley first
      smileyTab.add(Tab(text: S.of(context).savedSmileyTabTitle,));


      tabBarViewList.add(SavedSmileyTabView(smileyValueGetter));
      if (result == null) {
        
      }
      else {
        smileyList.addAll(result!.variables.smilies);
        print("Smiley ${smileyList.length}");
        for (int i = 0; i < smileyList.length; i++) {
          smileyTab.add(Tab(text: S.of(context).smileyLabel(i + 1),));
        }

        for (int i = 0; i < smileyList.length; i++) {
          List<Smiley> currentSmiley = smileyList[i];
          List<Widget> smileyImageList = [];

          for (int j = 0; j < currentSmiley.length; j++) {
            Smiley smiley = currentSmiley[j];
            smileyImageList.add(
              InkWell(
                  onTap: () async{
                    VibrationUtils.vibrateWithClickIfPossible();
                    smileyValueGetter(smiley);

                    // add to smiley
                    // check whether exist
                    Smiley? smileyInDb = await _smileyDao.findSmileyByDiscuzIdAndCode(discuz, smiley.code);
                    log("on tap smiley $smiley ${smileyInDb}");
                    if(smileyInDb != null){
                      smileyInDb.dateTime = DateTime.now();
                      smiley.discuz = discuz;
                      _smileyDao.insertSmileyWithKey(smileyInDb.key,smileyInDb);
                    }
                    else{
                      smiley.discuz = discuz;
                      _smileyDao.insertSmiley(smiley);
                    }

                  },
                  child: CachedNetworkImage(
                    imageUrl: discuz.baseURL + "/static/image/smiley/" +
                        currentSmiley[j].relativePath,
                    progressIndicatorBuilder: (context, url,
                        downloadProgress) =>
                        PlatformCircularProgressIndicator(
                            material: (context, platform) => MaterialProgressIndicatorData(
                              value: downloadProgress.progress
                            ),
                            cupertino: (context, platform) => CupertinoProgressIndicatorData(
                              color: Theme.of(context).colorScheme.primary
                            ),
                            ),
                    errorWidget: (context, url, error) =>
                        Icon(Icons.image_not_supported),
                  )
              ),

            );
          }
          tabBarViewList.add(
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 6,
                padding: EdgeInsets.all(4.0),
                children: smileyImageList,
              )
          );
        }


        
      }
      return Container(
        height: MediaQuery.of(context).size.height*0.25,
        child: DefaultTabController(
            length: smileyTab.length,
            child: Column(
              children: [
                TabBar(
                  tabs: smileyTab,
                  isScrollable: true,
                  labelColor: Theme
                      .of(context)
                      .colorScheme.primary,
                  unselectedLabelColor: Colors.grey,
                ),
                Expanded(
                    child: TabBarView(children: tabBarViewList))

              ],
            )
        ),
      );
    }
  }
}

class SavedSmileyTabView extends StatelessWidget{
  SmileyPressedFunc smileyValueGetter;
  SavedSmileyTabView(this.smileyValueGetter);

  @override
  Widget build(BuildContext context) {
    return SavedSmileyTabViewStatefulWidget(smileyValueGetter);
  }

}

class SavedSmileyTabViewStatefulWidget extends StatefulWidget{
  SmileyPressedFunc smileyValueGetter;
  SavedSmileyTabViewStatefulWidget(this.smileyValueGetter);
  @override
  SavedSmileyTabViewState createState() {

    return SavedSmileyTabViewState(this.smileyValueGetter);
  }

}

class SavedSmileyTabViewState extends State<SavedSmileyTabViewStatefulWidget>{
  SmileyPressedFunc smileyValueGetter;
  SmileyDao? _smileyDao;
  SavedSmileyTabViewState(this.smileyValueGetter);

  @override
  void initState() {
    super.initState();
    _initDB();
  }

  void _initDB() async {
    SmileyDao smileyDao = await AppDatabase.getSmileyDao();
    setState((){
      _smileyDao = smileyDao;
    });

    Discuz? discuz = Provider
        .of<DiscuzAndUserNotifier>(context, listen: false)
        .discuz;
    if (discuz == null) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    Discuz? discuz = Provider
        .of<DiscuzAndUserNotifier>(context, listen: false)
        .discuz;
    if(_smileyDao==null){
      return BlankScreen();
    }
    if(discuz == null){
      return NullDiscuzScreen();
    }
    else{
      return ValueListenableBuilder(
        valueListenable: _smileyDao!.smileyBox.listenable(),
        builder: (BuildContext context, Box<Smiley> value, Widget? child) {
          List<Smiley> smileyData = _smileyDao!.findAllSmileyByDiscuz(discuz);
          if(smileyData.isEmpty){
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_forward),
                Text(S.of(context).noSmileyFoundInDB)
              ],
            );
          }
          else{
            List<Widget> smileyImageList = [];
            for (int j = 0; j < smileyData.length; j++) {
              Smiley smiley = smileyData[j];
              // log("on Database smiley $smiley");
              smileyImageList.add(
                InkWell(
                    onTap: () async{
                      VibrationUtils.vibrateWithClickIfPossible();
                      smileyValueGetter(smiley);
                      // add to smiley
                      // check whether exist
                      if(smiley.key!=null){
                        smiley.dateTime = DateTime.now();
                        _smileyDao!.insertSmileyWithKey(smiley.key,smiley);
                      }
                      log("pressed smiley ${smiley} ${smiley.key} ");


                    },
                    child: CachedNetworkImage(
                      imageUrl: discuz.baseURL + "/static/image/smiley/" +
                          smiley.relativePath,
                      progressIndicatorBuilder: (context, url,
                          downloadProgress) =>
                          CircularProgressIndicator(
                              value: downloadProgress.progress),
                      errorWidget: (context, url, error) =>
                          Icon(Icons.image_not_supported),
                    )
                ),

              );
            }
            return GridView.count(
              shrinkWrap: true,
              crossAxisCount: 6,
              padding: EdgeInsets.all(4.0),
              children: smileyImageList,
            );
          }
        },

      );
    }

  }

}
