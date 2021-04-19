import 'dart:developer';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


import 'package:discuz_flutter/page/AddDiscuzPage.dart';
import 'package:discuz_flutter/page/LoginPage.dart';
import 'package:discuz_flutter/screen/DiscuzPortalScreen.dart';
import 'package:discuz_flutter/utility/DBHelper.dart';
import 'package:discuz_flutter/utility/GlobalTheme.dart';
import 'package:discuz_flutter/widget/DiscuzInfoCard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'entity/Discuz.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:discuz_flutter/generated/l10n.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: GlobalTheme.getThemeData(),
      home: MyHomePage(title: "谈坛"),
      // localization
      localizationsDelegates: [
        S.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: S.delegate.supportedLocales,
      builder: EasyLoading.init(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int _bottomNavigationbarIndex = 0;
  late List<Widget> bodies = [];

  //
  Discuz? _selectedDiscuz;
  List<Discuz> _allDiscuzs = [];
  Stream<List<Discuz>>? _discuzListStream;

  _MyHomePageState() {
    _queryDiscuzList();
    bodies = [

    ];
  }

  String getSelectedDiscuzTitle() {
    if (_selectedDiscuz == null) {
      return "还没有添加一个论坛";
    } else {
      return _selectedDiscuz!.siteName;
    }
  }

  void _incrementCounter() {
    _navigateToAddForumPage(context);
  }

  void _navigateToAddForumPage(BuildContext context) async {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => AddDiscuzPage()));
  }

  Widget getBodyWidget(int index){
    if(_selectedDiscuz == null){
      return Text("未选择一个论坛");
    }
    else{
      return DiscuzPortalScreen(_selectedDiscuz!, null);
    }
  }

  void _queryDiscuzList() async {
    final db = await DBHelper.getDiscuzDb();
    final dao = db.discuzDao;

    this._discuzListStream = dao.findAllDiscuzStream();
    _allDiscuzs = await dao.findAllDiscuzs();
    log("recv discuz list ${_allDiscuzs.length}");

    setState(() {
      _selectedDiscuz = _allDiscuzs.first;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).appName),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: DiscuzInfoCard(_selectedDiscuz),
              decoration: BoxDecoration(color: Colors.white),
            ),
            Column(children: [
              ListTile(
                title: Text("登录账号"),
                subtitle: Text("使用账号密码或者网页登录账号"),
                leading: Icon(Icons.person_add),
                onTap: () async {
                  if(_selectedDiscuz!= null){
                    await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage(discuz: _selectedDiscuz!, key: UniqueKey(),))
                    );
                  }
                },
              ),
              Container(
                height: 500,
                child: StreamBuilder<List<Discuz>>(
                  stream: _discuzListStream,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Discuz>> snapshot) {
                    List<Discuz>? discuzList = snapshot.data;
                    log("recv updated discuz ${discuzList}");
                    if (discuzList != null) {
                      log("recv updated discuz ${discuzList.length}");

                      List<Discuz> discuzListNotNull = discuzList;
                      return ListView.builder(
                          itemCount: discuzListNotNull.length,
                          itemBuilder: (context, index) {
                            final eachDiscuz = discuzListNotNull[index];
                            return ListTile(
                              title: Text(eachDiscuz.siteName),
                              subtitle: Text(eachDiscuz.baseURL),
                              onTap: () {
                                setState(() {
                                  _selectedDiscuz = eachDiscuz;
                                });
                              },
                            );
                          });
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
            ]),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavigationbarIndex,
        items: [
          BottomNavigationBarItem(
              icon: new Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: S.of(context).index
          ),
          BottomNavigationBarItem(
              icon: new Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore),
              label: S.of(context).dashboard
          ),
          BottomNavigationBarItem(
              icon: new Icon(Icons.notifications_outlined),
              activeIcon: Icon(Icons.notifications),
              label: S.of(context).notification
          ),
        ],
        onTap: (index){
          setState(() {
            _bottomNavigationbarIndex = index;
          });
        },
      ),
      body: getBodyWidget(_bottomNavigationbarIndex),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: S.of(context).addNewDiscuz,
        child: Icon(Icons.account_tree),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
