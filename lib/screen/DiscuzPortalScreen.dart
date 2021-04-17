
import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:discuz_flutter/JsonResult/DiscuzIndexResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/DiscuzError.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/utility/GlobalTheme.dart';
import 'package:discuz_flutter/widget/ErrorCard.dart';
import 'package:discuz_flutter/widget/ForumPartitionWidget.dart';
import 'package:flutter/material.dart';

class DiscuzPortalScreen extends StatelessWidget {
  Discuz _discuz;
  User? _user;

  DiscuzPortalScreen(this._discuz, this._user);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return DiscuzPortalStatefulWidget(_discuz, _user);
  }
}

class DiscuzPortalStatefulWidget extends StatefulWidget {
  Discuz _discuz;
  User? _user;

  DiscuzPortalStatefulWidget(this._discuz, this._user);

  _DiscuzPortalState createState() {
    return _DiscuzPortalState(_discuz, _user);
  }
}

class _DiscuzPortalState extends State<DiscuzPortalStatefulWidget> {
  Discuz _discuz;
  User? _user;
  late Dio _dio;
  late MobileApiClient _client;
  bool _isLoading = false;
  DiscuzIndexResult? result = null;
  DiscuzError? _error;
  bool _loaded = false;

  _DiscuzPortalState(this._discuz, this._user) {
    this._dio = Dio();
    this._client = MobileApiClient(_dio, baseUrl: _discuz.baseURL);

  }

  void _loadPortalContent() {
    setState(() {
      _isLoading = true;
    });

    _client.getDiscuzPortalRaw().then((value) {
      log(value);
      DiscuzIndexResult result = DiscuzIndexResult.fromJson(jsonDecode(value));
    });

    _client.getDiscuzPortalResult().then((value) {
      // render page
      setState(() {
        result = value;
        _isLoading = false;
      });
    }).catchError((onError) {
      log(onError);
      setState(() {
        _error =
            DiscuzError(onError.runtimeType.toString(), onError.toString());
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if(!_loaded){
      _loaded = true;
      _loadPortalContent();
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if(_isLoading)
            LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation(
                  GlobalTheme.getThemeData().primaryColor),
            ),
          if(_error!=null)
            ErrorCard(_error!.key, _error!.content),
          if(result!=null)
            ListView.builder(
                shrinkWrap: true,
                itemCount: result == null
                    ? 0
                    : result!.discuzIndexVariables.forumPartitionList.length,
                itemBuilder: (context, index) {
                  List<ForumPartition> forumPartitionList =
                      result!.discuzIndexVariables.forumPartitionList;
                  List<Forum> _allForumList =
                      result!.discuzIndexVariables.forumList;
                  ForumPartition forumPartition = forumPartitionList[index];
                  //log("Forum partition length ${result!.discuzIndexVariables.forumPartitionList.length} all ${_allForumList.length}" );
                  return ForumPartitionWidget(forumPartition, _allForumList);
                }
            )
        ],
      ),
    );
  }
}
