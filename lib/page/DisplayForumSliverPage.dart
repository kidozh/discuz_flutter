import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:discuz_flutter/JsonResult/CheckResult.dart';
import 'package:discuz_flutter/JsonResult/DisplayForumResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/dao/ViewHistoryDao.dart';
import 'package:discuz_flutter/entity/DiscuzError.dart';
import 'package:discuz_flutter/entity/ForumThread.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/entity/ViewHistory.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/screen/BlankScreen.dart';
import 'package:discuz_flutter/screen/EmptyScreen.dart';
import 'package:discuz_flutter/utility/DBHelper.dart';
import 'package:discuz_flutter/utility/GlobalTheme.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:discuz_flutter/widget/DiscuzHtmlWidget.dart';
import 'package:discuz_flutter/widget/ErrorCard.dart';
import 'package:discuz_flutter/widget/ForumThreadWidget.dart';
import 'package:discuz_flutter/widget/PlatformSliverAppBar.dart';
import 'package:floor/floor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:dio/dio.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:form_validator/form_validator.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    // TODO: implement createState
    return _DisplayForumSliverState(this.discuz, this.user, this.fid);
  }
}

class _DisplayForumSliverState extends State<DisplayForumSliverStatefulWidget> {
  DisplayForumResult? _displayForumResult = null;
  DiscuzError? _error = null;
  DisplayForumQuery _displayForumQuery = DisplayForumQuery();
  List<ForumThread> _forumThreadList = [];
  int _page = 1;

  late final Discuz discuz;
  late final User? user;
  int fid = 0;

  bool historySaved = false;

  _DisplayForumSliverState(this.discuz, this.user, this.fid);

  late EasyRefreshController _controller;
  late ScrollController _scrollController;

  // 反向
  bool _reverse = false;

  // 方向
  Axis _direction = Axis.vertical;

  // Header浮动
  bool _headerFloat = false;

  // 无限加载
  bool _enableInfiniteLoad = true;

  // 控制结束
  bool _enableControlFinish = false;

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = EasyRefreshController();
    _scrollController = ScrollController();
    //_invalidateContent();
    // init ad
  }

  void _invalidateContent() {
    setState(() {
      _page = 1;
    });
    _loadForumContent();
  }

  void _saveViewHistory(ForumDetail forumDetail) async {
    // check if needed
    bool allowViewHistory =
        await UserPreferencesUtils.getRecordHistoryEnabled();
    if (!allowViewHistory) {
      historySaved = true;
      return;
    }

    // prepare database
    final db = await DBHelper.getAppDb();
    ViewHistoryDao viewHistoryDao = db.viewHistoryDao;

    ViewHistory insertViewHistory = ViewHistory(
        null,
        forumDetail.name,
        forumDetail.description,
        forumDetail.rules,
        "forum",
        forumDetail.fid,
        "",
        0,
        discuz.id!,
        DateTime.now());
    int primaryKey = await viewHistoryDao.insertViewHistory(insertViewHistory);
    print("save history with primary key ${primaryKey}");
    historySaved = true;
  }

  Future<void> _loadForumContent() async {
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

    client
        .displayForumResult(
            fid.toString(), _page, _displayForumQuery.generateForumQueriesMap())
        .then((value) {
      if (!historySaved && _page == 1) {
        _saveViewHistory(value.discuzIndexVariables.forum);
      }

      setState(() {
        _displayForumResult = value;
        _error = null;
        if (_page == 1) {
          _forumThreadList = value.discuzIndexVariables.forumThreadList;
        } else {
          _forumThreadList.addAll(value.discuzIndexVariables.forumThreadList);
          _forumThreadList = _forumThreadList;
        }
        _page += 1;
      });

      if (!_enableControlFinish) {
        _controller.resetLoadState();
        _controller.finishRefresh();
      }
      // check for loaded all?
      if (!_enableControlFinish) {
        _controller.finishLoad(
            noMore: _forumThreadList.length >=
                value.discuzIndexVariables.forum.getThreadCount());
      }

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
              S.of(context).userExpiredSubtitle);
        });
      }

      log("set successful result ${_displayForumResult} ${_forumThreadList.length}");
    }).catchError((onError) {
      throw(onError);
      log(onError);
      EasyLoading.showError('${onError}');
      if (!_enableControlFinish) {
        _controller.resetLoadState();
        _controller.finishRefresh();
      }
      switch (onError.runtimeType) {
        case DioError:
          {
            _error =
                DiscuzError(onError.runtimeType.toString(), onError.toString());
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
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return PlatformScaffold(
      iosContentBottomPadding: true,
      iosContentPadding: true,
      appBar: PlatformAppBar(
        //middle: Text(S.of(context).forumDisplayTitle),
        trailingActions: [
          IconButton(
              icon: Icon(Icons.filter_alt_outlined),
              onPressed: () {
                _showForumFilterBottomSheet(context);
              }),
          IconButton(
              icon: Icon(PlatformIcons(context).helpOutline),
              onPressed: () {
                _showInformationBottomSheet(context);
              })
        ],
        title: _displayForumResult == null
            ? Text(S.of(context).forumDisplayTitle)
            : Text(_displayForumResult!.discuzIndexVariables.forum.name),
      ),
      body: EasyRefresh.custom(
        enableControlFinishRefresh: true,
        enableControlFinishLoad: true,
        taskIndependence: _taskIndependence,
        controller: _controller,
        scrollController: _scrollController,
        reverse: _reverse,
        scrollDirection: _direction,
        topBouncing: _topBouncing,
        bottomBouncing: _bottomBouncing,
        emptyWidget: _forumThreadList.length == 0 ? EmptyScreen() : null,
        header: _enableRefresh
            ? ClassicalHeader(
                enableInfiniteRefresh: false,
                bgColor: _headerFloat
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                // infoColor: _headerFloat ? Colors.black87 : Theme.of(context).primaryColor,
                textColor: Theme.of(context).textTheme.headline1!.color == null
                    ? Theme.of(context).primaryColorDark
                    : Theme.of(context).textTheme.headline1!.color!,
                float: _headerFloat,
                enableHapticFeedback: _vibration,
                refreshText: S.of(context).pullToRefresh,
                refreshReadyText: S.of(context).releaseToRefresh,
                refreshingText: S.of(context).refreshing,
                refreshedText: S.of(context).refreshed,
                refreshFailedText: S.of(context).refreshFailed,
                noMoreText: S.of(context).noMore,
                infoText: S.of(context).updateAt,
              )
            : null,
        footer: _enableLoad
            ? ClassicalFooter(
                enableInfiniteLoad: _enableInfiniteLoad,
                textColor: Theme.of(context).textTheme.headline1!.color == null
                    ? Theme.of(context).primaryColorDark
                    : Theme.of(context).textTheme.headline1!.color!,
                enableHapticFeedback: _vibration,
                loadText: S.of(context).pushToLoad,
                loadReadyText: S.of(context).releaseToLoad,
                loadingText: S.of(context).loading,
                loadedText: S.of(context).loaded,
                loadFailedText: S.of(context).loadFailed,
                noMoreText: S.of(context).noMore,
                infoText: S.of(context).updateAt,
              )
            : null,
        onRefresh: _enableRefresh
            ? () async {
                _invalidateContent();
                if (!_enableControlFinish) {
                  _controller.resetLoadState();
                  _controller.finishRefresh();
                }
              }
            : null,
        onLoad: _enableLoad
            ? () async {
                _loadForumContent();
              }
            : null,
        firstRefresh: true,
        firstRefreshWidget: Container(
          width: double.infinity,
          height: double.infinity,
          child: Center(
              child: SizedBox(
            height: 200.0,
            width: 300.0,
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 50.0,
                    height: 50.0,
                    child: SpinKitFadingCube(
                      color: Theme.of(context).primaryColor,
                      size: 25.0,
                    ),
                  ),
                  Container(
                    child: Text(S.of(context).loading),
                  )
                ],
              ),
            ),
          )),
        ),
        slivers: <Widget>[

          if (_error != null)
            SliverList(

                delegate: SliverChildBuilderDelegate(

                    (context, _){
                      return ErrorCard(_error!.key, _error!.content, () {
                        _controller.callRefresh();
                      });
                    },
                    childCount : 1,
            )),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                log("${_forumThreadList[index].subject} ${_forumThreadList}");
                if (index != 0 && index % 10 == 0) {
                  return Column(
                    children: [
                      Consumer<DiscuzAndUserNotifier>(
                          builder: (context, discuzAndUser, child) {
                        return ForumThreadWidget(
                            discuz,
                            discuzAndUser.user,
                            _forumThreadList[index],
                            _displayForumResult!
                                .discuzIndexVariables.threadType);
                      }),
                      Divider(),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      ForumThreadWidget(discuz, user, _forumThreadList[index],
                          _displayForumResult!.discuzIndexVariables.threadType),
                      Divider(),
                    ],
                  );
                }
              },
              childCount: _forumThreadList.length,
            ),
          ),
        ],
      ),
    );
  }

  void _showInformationBottomSheet(BuildContext context) {
    if (_displayForumResult != null) {
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
                                _displayForumResult!
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
                                _displayForumResult!
                                    .discuzIndexVariables.forum.rules))
                      ],
                    )
                  ],
                );
              },
            );
          });
    }
  }

  void _showForumFilterBottomSheet(BuildContext context) {
    List<ThreadTypeInfo> threadTypeList = [];
    if (_displayForumResult != null &&
        _displayForumResult!.discuzIndexVariables.threadType != null) {
      ThreadType threadType =
          _displayForumResult!.discuzIndexVariables.threadType!;
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
                                _displayForumQuery.setDateline(
                                    31536000, selected);
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
                              selected: false,
                              onSelected: (bool selected) {},
                            ),
                            ChoiceChip(
                              avatar: Icon(Icons.whatshot_rounded),
                              label: Text(S.of(context).forumFilterStatusHot),
                              selected: false,
                              onSelected: (bool selected) {},
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
      print("Closing the dialog");
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
    }

    return forumQueriesMap;
  }
}
