import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:discuz_flutter/JsonResult/DisplayForumResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/dao/FavoriteForumDao.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/DiscuzError.dart';
import 'package:discuz_flutter/entity/FavoriteForumInDatabase.dart';
import 'package:discuz_flutter/entity/ForumThread.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/entity/ViewHistory.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/InternalWebviewBrowserPage.dart';
import 'package:discuz_flutter/page/PostThreadPage.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/screen/EmptyListScreen.dart';
import 'package:discuz_flutter/utility/AppPlatformIcons.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:discuz_flutter/widget/AppBannerAdWidget.dart';
import 'package:discuz_flutter/widget/DiscuzHtmlWidget.dart';
import 'package:discuz_flutter/widget/ErrorCard.dart';
import 'package:discuz_flutter/widget/ForumThreadWidget.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../utility/EasyRefreshUtils.dart';

class DisplayForumSliverPage extends StatelessWidget {
  late final Discuz discuz;
  late final User? user;
  int fid = 0;

  DisplayForumSliverPage(this.discuz, this.user, this.fid);

  @override
  Widget build(BuildContext context) {
    // try ios
    return DisplayForumSliverStatefulWidget(discuz, user, fid);
  }
}

class DisplayForumSliverStatefulWidget extends StatefulWidget {
  late final Discuz discuz;
  late final User? user;
  int fid = 0;

  DisplayForumSliverStatefulWidget(this.discuz, this.user, this.fid);

  @override
  _DisplayForumSliverState createState() {
    return _DisplayForumSliverState(this.discuz, this.user, this.fid);
  }
}

class _DisplayForumSliverState extends State<DisplayForumSliverStatefulWidget> {
  DisplayForumResult _displayForumResult = DisplayForumResult();
  DiscuzError? _error;
  DisplayForumQuery _displayForumQuery = DisplayForumQuery();
  List<ForumThread> _forumThreadList = [];
  int _page = 1;

  late final Discuz discuz;
  late final User? user;
  int fid = 0;

  bool historySaved = false;

  _DisplayForumSliverState(this.discuz, this.user, this.fid);

  late EasyRefreshController _controller;


  // 反向
  bool _reverse = false;

  // 方向
  Axis _direction = Axis.vertical;

  // Header浮动
  bool _headerFloat = false;

  // 无限加载
  bool _enableInfiniteLoad = true;

  // 控制结束
  bool _enableControlFinish = true;

  // 任务独立
  bool _taskIndependence = false;

  // 震动
  bool _vibration = true;

  // 是否开启刷新
  bool _enableRefresh = true;

  // 是否开启加载
  bool _enableLoad = true;

  // 顶部回弹
  bool _topBouncing = true;

  // 底部回弹
  bool _bottomBouncing = true;
  late Dio dio;
  late MobileApiClient client;

  @override
  void initState() {
    super.initState();
    _controller = EasyRefreshController(controlFinishLoad: true, controlFinishRefresh: true);
    _loadClient();
    _loadFavoriteDao();
  }

  Future<void> _loadClient() async{
    User? user =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
    dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    client = MobileApiClient(dio, baseUrl: discuz.baseURL);
  }

  Future<void> _loadFavoriteDao() async{
    setState(() async{
      favoriteForumDao = await AppDatabase.getFavoriteForumDao();
    });

  }

  Future<IndicatorResult> _invalidateContent() async {
    setState(() {
      _page = 1;
      _forumThreadList = [];
    });
    return await _loadForumContent();
  }

  Future<void> favoriteForum() async{
    FavoriteForumDao favoriteForumDao = await AppDatabase.getFavoriteForumDao();
    favoriteForumDao.insertFavoriteForum(
      FavoriteForumInDatabase(0, _displayForumResult.discuzIndexVariables.member_uid,
          fid, "fid", _displayForumResult.discuzIndexVariables.forum.name,
          _displayForumResult.discuzIndexVariables.forum.description,
          DateTime.now(),
          discuz)
    );
    client.favoriteForumActionResult(_displayForumResult.discuzIndexVariables.formHash, fid).then((value){
      if(value.errorResult!= null && value.errorResult!.key == "do_success"){
        EasyLoading.showSuccess(S.of(context).discuzOperationMessage(value.errorResult!.key, value.errorResult!.content));
      }
      else{
        EasyLoading.showToast(S.of(context).discuzOperationMessage(value.errorResult!.key, value.errorResult!.content));
      }
    });
  }

  Future<void> unfavoriteForum() async{
    FavoriteForumDao favoriteForumDao = await AppDatabase.getFavoriteForumDao();

    FavoriteForumInDatabase? favoriteForumInDatabase = favoriteForumDao.getFavoriteForumByFid(fid, discuz);
    if(favoriteForumInDatabase!= null){
      favoriteForumDao.removeFavoriteForum(favoriteForumInDatabase);
      client.unfavoriteThreadActionResult(_displayForumResult.discuzIndexVariables.formHash, favoriteForumInDatabase.favid).then((value){
        if(value.errorResult!= null && value.errorResult!.key == "do_success"){
          EasyLoading.showSuccess(S.of(context).discuzOperationMessage(value.errorResult!.key, value.errorResult!.content));
        }
        else{
          EasyLoading.showToast(S.of(context).discuzOperationMessage(value.errorResult!.key, value.errorResult!.content));
        }
      });
    }


  }

  Future<void> _saveViewHistory(ForumDetail forumDetail) async {
    // check if needed
    bool allowViewHistory =
        await UserPreferencesUtils.getRecordHistoryEnabled();
    final dao = await AppDatabase.getViewHistoryDao();
    if (!allowViewHistory) {
      historySaved = true;
      return;
    } else {


      ViewHistory? viewHistory = dao.forumExistInDatabase(discuz, fid);
      print("Found forum $viewHistory");
      if (viewHistory == null) {
        // show rule
        _showInformationBottomSheet(context);
      }
    }

    ViewHistory insertViewHistory = ViewHistory(
        forumDetail.name,
        forumDetail.description,
        forumDetail.rules,
        "forum",
        forumDetail.fid,
        "",
        0,
        discuz,
        DateTime.now());
    int primaryKey = await dao.insertViewHistory(insertViewHistory);
    print("save history with primary key ${primaryKey}");
    historySaved = true;
  }

  Future<IndicatorResult> _loadForumContent() async {
    // check the availability
    log("Base url ${discuz.baseURL} ${_page}");
    User? user =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
    var dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    final client = MobileApiClient(dio, baseUrl: discuz.baseURL);

    // client.displayForumRaw(fid.toString(), _page).then((value){
    //   log(value);
    //   DisplayForumResult result = DisplayForumResult.fromJson(jsonDecode(value));
    // });

    if(_displayForumResult.discuzIndexVariables.forum.getThreadCount()!= 0 && _forumThreadList.length >= _displayForumResult.discuzIndexVariables.forum.getThreadCount()){
      _controller.finishLoad(IndicatorResult.noMore);
    }

    print("Request display forum map ${_displayForumQuery.generateForumQueriesMap()}");

    IndicatorResult result = await client
        .displayForumResult(
            fid.toString(), _page, _displayForumQuery.generateForumQueriesMap())
        .then((value) {
      if (!historySaved && _page == 1) {
        _saveViewHistory(value.discuzIndexVariables.forum);
      }

      setState(() {
        _displayForumResult = value;
        _error = null;
        print("GET page ${_page} results");

      });

      if (_page == 1) {
        print("Clearing list since page ${_page} results");
        setState(() {
          _forumThreadList = [];
        });

        setState(() {
          _forumThreadList = value.discuzIndexVariables.forumThreadList;
        });


      } else {
        setState(() {
          _forumThreadList.addAll(value.discuzIndexVariables.forumThreadList);
        });

      }
      _page += 1;
      _controller.finishRefresh();
      _controller.resetFooter();
      _controller.finishLoad(
          _forumThreadList.length >= value.discuzIndexVariables.forum.getThreadCount()?
          IndicatorResult.noMore:
          IndicatorResult.success);

      if (value.getErrorString() != null) {
        EasyLoading.showError(value.getErrorString()!);

      }

      if (value.errorResult != null) {
        setState(() {
          _error =
              DiscuzError(value.errorResult!.key, value.errorResult!.content);
        });
      } else {
        setState(() {
          _error = null;
        });
      }

      // check with user
      if (user != null && value.discuzIndexVariables.member_uid != user.uid) {
        setState(() {
          _error = DiscuzError(S.of(context).userExpiredTitle(user.username),
              S.of(context).userExpiredSubtitle, errorType: ErrorType.userExpired);
        });

      }
      if(_forumThreadList.length >= value.discuzIndexVariables.forum.getThreadCount()){
        return IndicatorResult.noMore;
      }
      else{
        return IndicatorResult.success;
      }


      //log("set successful result ${_displayForumResult} ${_forumThreadList.length}");
    }).catchError((onError) {
      VibrationUtils.vibrateErrorIfPossible();
      //log(onError);
      EasyLoading.showError('${onError}');
      _controller.finishRefresh();


      switch (onError.runtimeType) {
        case DioError:
          {
            DioError dioError = onError;
            log("${dioError.message} >-> ${dioError.type}");
            EasyLoading.showError("${dioError.message} (${dioError})");
            setState((){
              _error =
                  DiscuzError(dioError.message,dioError.type.name, dioError: dioError);
            });

            break;
          }
        default:
          {
            setState(() {
              _error = DiscuzError(
                  onError.runtimeType.toString(), onError.toString());
            });
          }
      }

      return IndicatorResult.fail;


    });
    return result;

  }

  FavoriteForumDao? favoriteForumDao;

  @override
  Widget build(BuildContext context) {

    return PlatformScaffold(
      appBar: PlatformAppBar(
        //middle: Text(S.of(context).forumDisplayTitle),
        trailingActions: [
          if(favoriteForumDao != null)
            ValueListenableBuilder(
              valueListenable: favoriteForumDao!.favoriteForumBox.listenable(),
              builder: (BuildContext context, value, Widget? child) {
                FavoriteForumInDatabase? favoriteForumInDb = favoriteForumDao!.getFavoriteForumByFid(fid, discuz);
                if(favoriteForumInDb == null){
                  return IconButton(
                    icon: Icon(PlatformIcons(context).favoriteOutline,size: 24),
                    onPressed: () {
                      VibrationUtils.vibrateWithClickIfPossible();
                      favoriteForum();
                    },
                  );
                }
                else{
                  return IconButton(
                    icon: Icon(PlatformIcons(context).favoriteSolid,size: 24, color: Theme.of(context).primaryColor,),
                    onPressed: () {
                      VibrationUtils.vibrateWithClickIfPossible();
                      unfavoriteForum();
                    },
                  );
                }
              },
            ),
          if(user != null)
          IconButton(
              icon: Icon(AppPlatformIcons(context).publishPostOutlined,size: 24),
              onPressed: () {
                if(_displayForumResult.discuzIndexVariables.forum.fid != 0){
                  VibrationUtils.vibrateWithClickIfPossible();
                  Navigator.push(
                      context,
                      platformPageRoute(
                          context: context,
                          builder: (context) => PostThreadPage(discuz,_displayForumResult.discuzIndexVariables.forum.fid, 0)));
                }
                else{
                  EasyLoading.showInfo(S.of(context).loading);
                }

              }),
          PopupMenuButton(
            icon: Icon(PlatformIcons(context).ellipsis, size: 24,),
            itemBuilder: (context) => [
              PopupMenuItem<int>(
                child: Text(S.of(context).forumInformation),
                value: 3,
              ),
              PopupMenuItem<int>(
                child: Text(S.of(context).forumSortPosts),
                value: 4,
              ),
              PopupMenuItem<int>(
                child: Text(S.of(context).openViaInternalBrowser),
                value: 0,
              ),
              PopupMenuItem<int>(
                child: Text(S.of(context).share),
                value: 1,
              )
            ],
            onSelected: (int pos) {
              VibrationUtils.vibrateWithClickIfPossible();
              switch (pos) {
                case 0:
                  {
                    Navigator.push(
                        context,
                        platformPageRoute(
                            context: context,
                            builder: (context) => InternalWebviewBrowserPage(
                                discuz,
                                user,
                                URLUtils.getForumDisplayURL(discuz, fid))));
                    break;
                  }
                case 1:{
                  Share.share(URLUtils.getForumDisplayURL(discuz, fid), subject: _displayForumResult.discuzIndexVariables.forum.name);
                  break;
                }
                case 3:{
                  VibrationUtils.vibrateWithClickIfPossible();
                  _showInformationBottomSheet(context);
                  break;
                }
                case 4:{
                  VibrationUtils.vibrateWithClickIfPossible();
                  _showForumFilterBottomSheet(context);
                  break;
                }
              }
            },
          )
        ],
        title: _displayForumResult == null
            ? Text(S.of(context).forumDisplayTitle,overflow: TextOverflow.ellipsis)
            : Text(_displayForumResult.discuzIndexVariables.forum.name,overflow: TextOverflow.ellipsis),
        backgroundColor: Theme.of(context).navigationBarTheme.backgroundColor?.withOpacity(0.5),
      ),
      body: SafeArea(
        child: EasyRefresh(
          controller: _controller,

          header: EasyRefreshUtils.i18nClassicHeader(context),
          footer: EasyRefreshUtils.i18nClassicFooter(context),
          refreshOnStart: true,
          onRefresh: () async {
            return await _invalidateContent();

          },
          onLoad: () async {
            return await _loadForumContent();
          },

          child: CustomScrollView(
            slivers: <Widget>[

              if (_error != null)
                SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, _) {
                        return ErrorCard(_error!, () {
                          _controller.callRefresh();
                        }, errorType: _error!.errorType,);
                      },
                      childCount: 1,
                    )),
              // check with sub forum
              if(_displayForumResult.discuzIndexVariables.subForumList.isNotEmpty)
                SliverList(delegate: SliverChildBuilderDelegate(
                        (context, index){
                      var subForum = _displayForumResult.discuzIndexVariables.subForumList[index];
                      return Card(
                        color: Theme.of(context).primaryColor,
                        child: ListTile(
                          title: Text(subForum.name, style: TextStyle(color: Theme.of(context).primaryTextTheme.bodyText1?.color),),
                          leading: Icon(Icons.forum, color: Theme.of(context).primaryTextTheme.bodyText1?.color),
                          trailing: Icon(Icons.arrow_forward, color: Theme.of(context).primaryTextTheme.bodyText1?.color),
                          onTap: () async {
                            VibrationUtils.vibrateWithClickIfPossible();
                            await Navigator.push(
                                context,
                                platformPageRoute(context:context,builder: (context) => DisplayForumSliverPage(discuz, user, subForum.fid))
                            );
                          },
                        ),
                      );
                    },
                    childCount: _displayForumResult.discuzIndexVariables.subForumList.length
                )
                ),
              if(_forumThreadList.isEmpty)
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return EmptyListScreen(EmptyItemType.thread);
                  }, childCount: 1),

                ),

              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    log("${_forumThreadList[index].subject} ${_forumThreadList}");
                    return Column(
                      children: [
                        ForumThreadWidget(discuz, user, _forumThreadList[index],
                            _displayForumResult.discuzIndexVariables.threadType),
                        if(index % 10 == 0 && index != 0)
                          AppBannerAdWidget(),
                      ],
                    );
                  },
                  childCount: _forumThreadList.length,
                ),
              ),
            ],
          ),


        ),
      ),
    );
  }

  void _showInformationBottomSheet(BuildContext context) {
    showModalBottomSheet(
        isScrollControlled: false,
        context: context,
        builder: (context) {
          return Scrollable(
            viewportBuilder: (BuildContext context, ViewportOffset position) {
              return ListView(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.description_outlined,
                          color: Colors.blue,
                        ),
                      ),
                      Expanded(
                          child: DiscuzHtmlWidget(
                              discuz,
                              _displayForumResult
                                  .discuzIndexVariables.forum.description))
                    ],
                  ),
                  Divider(),
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.rule,
                          color: Colors.redAccent,
                        ),
                      ),
                      Expanded(
                          child: DiscuzHtmlWidget(
                              discuz,
                              _displayForumResult.discuzIndexVariables.forum.rules))
                    ],
                  )
                ],
              );
            },
          );
        });
  }

  void _showForumFilterBottomSheet(BuildContext context) {
    List<ThreadTypeInfo> threadTypeList = [];
    if (_displayForumResult.discuzIndexVariables.threadType != null) {
      ThreadType threadType =
          _displayForumResult.discuzIndexVariables.threadType!;
      //Map<String, String> idNameMap = threadType.idNameMap;
      threadTypeList = threadType.getThreadTypeList();
    }
    showModalBottomSheet(
        isScrollControlled: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Scrollable(
              viewportBuilder: (BuildContext context, ViewportOffset position) {
                return ListView(
                  children: [
                    if (threadTypeList.isNotEmpty)
                      Column(
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.category,
                                  color: Colors.blue,
                                ),
                              ),
                              Expanded(
                                  child: Text(
                                      S.of(context).forumFilterTypeIdTitle))
                            ],
                          ),
                          Wrap(
                            children: List<Widget>.generate(
                                threadTypeList.length, (int index) {
                              ThreadTypeInfo threadTypeInfo =
                                  threadTypeList[index];
                              return ChoiceChip(
                                label: Text(threadTypeInfo.typeName),
                                selected: _displayForumQuery.typeId ==
                                    threadTypeInfo.typeId,
                                onSelected: (bool selected) {
                                  VibrationUtils.vibrateWithClickIfPossible();
                                  setState(() {
                                    _displayForumQuery.setTypeId(
                                        threadTypeInfo.typeId, selected);
                                  });
                                },
                              );
                            }),
                          )
                        ],
                      ),
                    if (threadTypeList.isNotEmpty) Divider(),
                    Column(
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.sort,
                                color: Colors.blue,
                              ),
                            ),
                            Expanded(
                                child:
                                    Text(S.of(context).forumFilterSortByTitle))
                          ],
                        ),
                        Wrap(
                          children: [
                            ChoiceChip(
                              label:
                                  Text(S.of(context).forumFilterSortByLastPost),
                              selected:
                                  _displayForumQuery.orderBy == "lastpost",
                              onSelected: (bool selected) {
                                VibrationUtils.vibrateWithClickIfPossible();
                                setState(() {
                                  _displayForumQuery.setOrderBy(
                                      "lastpost", true);
                                });
                              },
                            ),
                            ChoiceChip(
                              label:
                                  Text(S.of(context).forumFilterSortByNewPost),
                              selected:
                                  _displayForumQuery.orderBy == "dateline",
                              onSelected: (bool selected) {
                                VibrationUtils.vibrateWithClickIfPossible();
                                setState(() {
                                  _displayForumQuery.setOrderBy(
                                      "dateline", selected);
                                });
                              },
                            ),
                            ChoiceChip(
                              label: Text(S.of(context).forumFilterSortByView),
                              selected: _displayForumQuery.orderBy == "views",
                              onSelected: (bool selected) {
                                VibrationUtils.vibrateWithClickIfPossible();
                                setState(() {
                                  _displayForumQuery.setOrderBy(
                                      "views", selected);
                                });
                              },
                            ),
                            ChoiceChip(
                              label: Text(S.of(context).forumFilterSortByHeat),
                              selected: _displayForumQuery.orderBy == "heats",
                              onSelected: (bool selected) {
                                VibrationUtils.vibrateWithClickIfPossible();
                                setState(() {
                                  _displayForumQuery.setOrderBy(
                                      "heats", selected);
                                });
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                    Divider(),
                    Column(
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.apps_outlined,
                                color: Colors.blue,
                              ),
                            ),
                            Expanded(
                                child: Text(
                                    S.of(context).forumFilterSpecialTypeTitle))
                          ],
                        ),
                        Wrap(
                          children: [
                            ChoiceChip(
                              label: Text(
                                  S.of(context).forumFilterSpecialTypePoll),
                              selected:
                                  _displayForumQuery.specialType == "poll",
                              onSelected: (bool selected) {
                                VibrationUtils.vibrateWithClickIfPossible();
                                setState(() {
                                  _displayForumQuery.setSpecialType(
                                      "poll", selected);
                                });
                              },
                            ),
                            ChoiceChip(
                              label: Text(
                                  S.of(context).forumFilterSpecialTypeDebate),
                              selected:
                                  _displayForumQuery.specialType == "debate",
                              onSelected: (bool selected) {
                                VibrationUtils.vibrateWithClickIfPossible();
                                setState(() {
                                  _displayForumQuery.setSpecialType(
                                      "debate", selected);
                                });
                              },
                            ),
                            ChoiceChip(
                              label: Text(
                                  S.of(context).forumFilterSpecialTypeActivity),
                              selected:
                                  _displayForumQuery.specialType == "activity",
                              onSelected: (bool selected) {
                                VibrationUtils.vibrateWithClickIfPossible();
                                setState(() {
                                  _displayForumQuery.setSpecialType(
                                      "activity", selected);
                                });
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                    Divider(),
                    Column(
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.access_time,
                                color: Colors.blue,
                              ),
                            ),
                            Expanded(
                                child: Text(S.of(context).forumFilterTimeTitle))
                          ],
                        ),
                        Wrap(
                          children: [
                            ChoiceChip(
                              label: Text(S.of(context).forumFilterTimeToday),
                              selected: _displayForumQuery.dateline == 86400,
                              onSelected: (bool selected) {
                                VibrationUtils.vibrateWithClickIfPossible();
                                setState(() {
                                  _displayForumQuery.setDateline(
                                      86400, selected);
                                });
                              },
                            ),
                            ChoiceChip(
                              label:
                                  Text(S.of(context).forumFilterTimeThisWeek),
                              selected: _displayForumQuery.dateline == 604800,
                              onSelected: (bool selected) {
                                VibrationUtils.vibrateWithClickIfPossible();
                                setState(() {
                                  _displayForumQuery.setDateline(
                                      604800, selected);
                                });
                              },
                            ),
                            ChoiceChip(
                              label:
                                  Text(S.of(context).forumFilterTimeThisMonth),
                              selected: _displayForumQuery.dateline == 2592000,
                              onSelected: (bool selected) {
                                VibrationUtils.vibrateWithClickIfPossible();
                                setState(() {
                                  _displayForumQuery.setDateline(
                                      2592000, selected);
                                });
                              },
                            ),
                            ChoiceChip(
                              label: Text(
                                  S.of(context).forumFilterTimeThisQuarter),
                              selected: _displayForumQuery.dateline == 7948800,
                              onSelected: (bool selected) {
                                VibrationUtils.vibrateWithClickIfPossible();
                                setState(() {
                                  _displayForumQuery.setDateline(
                                      7948800, selected);
                                });
                              },
                            ),
                            ChoiceChip(
                              label:
                                  Text(S.of(context).forumFilterTimeThisYear),
                              selected: _displayForumQuery.dateline == 31536000,
                              onSelected: (bool selected) {
                                VibrationUtils.vibrateWithClickIfPossible();
                                setState(() {
                                  _displayForumQuery.setDateline(
                                      31536000, selected);
                                });
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                    Divider(),
                    Column(
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.whatshot_outlined,
                                color: Colors.blue,
                              ),
                            ),
                            Expanded(
                                child:
                                    Text(S.of(context).forumFilterStatusTitle))
                          ],
                        ),
                        Wrap(
                          children: [
                            ChoiceChip(
                              avatar: Icon(Icons.verified_outlined),
                              label:
                                  Text(S.of(context).forumFilterStatusDigest),
                              selected: _displayForumQuery.filter == "digest",
                              onSelected: (bool selected) {
                                VibrationUtils.vibrateWithClickIfPossible();
                                setState(() {
                                  _displayForumQuery.setDigest(selected);
                                });
                              },
                            ),
                            ChoiceChip(
                              avatar: Icon(Icons.whatshot_rounded),
                              label: Text(S.of(context).forumFilterStatusHot),
                              selected: _displayForumQuery.filter == "hot",
                              onSelected: (bool selected) {
                                VibrationUtils.vibrateWithClickIfPossible();
                                setState(() {
                                  _displayForumQuery.setHot(selected);
                                });
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                );
              },
            );
          });
        }).whenComplete(() {
          setState(() {
            _forumThreadList = [];
          });
          //print("Closing the dialog");
        _controller.callRefresh();
    });
  }
}

class DisplayForumActionControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.favorite_border),
          onPressed: () {
            // add to favorite
          },
        ),
        IconButton(icon: Icon(Icons.info_outlined), onPressed: () {})
      ],
    );
  }
}

class DisplayForumQuery {
  int typeId = 0, dateline = 0;
  String specialType = "", orderBy = "lastpost";
  String filter = "";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DisplayForumQuery &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId &&
          dateline == other.dateline &&
          specialType == other.specialType &&
          orderBy == other.orderBy &&
          filter == other.filter;

  @override
  int get hashCode =>
      typeId.hashCode ^
      dateline.hashCode ^
      specialType.hashCode ^
      orderBy.hashCode ^
      filter.hashCode;

  void setTypeId(int typeId, bool selected) {
    if (selected) {
      this.typeId = typeId;
    } else {
      this.typeId = 0;
    }
  }

  void setDateline(int dateline, bool selected) {
    if (selected) {
      this.dateline = dateline;
    } else {
      this.dateline = 0;
    }
  }

  void setSpecialType(String specialType, bool selected) {
    if (selected) {
      this.specialType = specialType;
    } else {
      this.specialType = "";
    }
  }

  void setOrderBy(String orderBy, bool selected) {
    if (selected) {
      this.orderBy = orderBy;
    } else {
      this.orderBy = "";
    }
  }

  void setFilter(String filter, bool selected) {
    if (selected) {
      this.filter = filter;
    } else {
      this.filter = "";
    }
  }

  void setHot(bool selected) {
    if (selected) {
      this.filter = "hot";
    } else {
      this.filter = "";
    }
  }

  void setDigest(bool selected) {
    if (selected) {
      this.filter = "digest";
    } else {
      this.filter = "";
    }
  }

  Map<String, String> generateForumQueriesMap() {
    Map<String, String> forumQueriesMap = {};
    if (typeId != 0) {
      forumQueriesMap["filter"] = "typeid";
      forumQueriesMap["typeid"] = typeId.toString();
    }

    if (specialType != "") {
      forumQueriesMap["filter"] = "specialtype";
      forumQueriesMap["specialtype"] = specialType;
    }

    if (dateline != 0) {
      forumQueriesMap["filter"] = "dateline";
      forumQueriesMap["dateline"] = dateline.toString();
    }

    if (orderBy != "lastpost") {
      forumQueriesMap["orderby"] = orderBy;
    }

    if (filter != "") {
      forumQueriesMap["filter"] = filter;
      if (filter == "digest") {
        forumQueriesMap["digest"] = "1";
      }
    }

    return forumQueriesMap;
  }
}
