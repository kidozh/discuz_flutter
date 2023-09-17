
import 'dart:developer';

import 'package:discuz_flutter/JsonResult/DiscuzIndexResult.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/utility/AppPlatformIcons.dart';
import 'package:discuz_flutter/widget/ForumCardWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

// ignore: must_be_immutable
class ForumPartitionWidget extends StatelessWidget{

  ForumPartition _forumPartition;
  List<Forum> _allForumList = [];
  List<Forum> _subForumList = [];

  Discuz _discuz;
  User? _user;

  ForumPartitionWidget(this._discuz,this._user,this._forumPartition, this._allForumList){
    log("${_allForumList.length} in ${_allForumList}");
    _subForumList = this._forumPartition.getForumList(_allForumList);
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.onPrimary,
            child: PlatformListTile(
              leading: Icon(AppPlatformIcons(context).forumOutlined,color: Theme.of(context).colorScheme.primary,),
              title: Text(_forumPartition.name,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: isCupertino(context)?FontWeight.w200: FontWeight.normal,
                ),
              ),
            ),
          )
          ,

          GridView.builder(
              physics: new NeverScrollableScrollPhysics(),
              padding: EdgeInsets.all(0),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  childAspectRatio: 2.6
              ),
              itemCount: _subForumList.length,
              itemBuilder: (context, index){
                Forum subForum = _subForumList[index];
                // log("_subforum length ${_subForumList.length} ${_subForumList}");
                return ForumCardWidget(_discuz,_user,subForum);
              },
          ),
          if(isMaterial(context))
          Divider()
        ],
      ),
    );
  }


}