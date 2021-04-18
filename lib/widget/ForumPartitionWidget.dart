
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/JsonResult/DiscuzIndexResult.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/utility/CustomizeColor.dart';
import 'package:discuz_flutter/utility/GlobalTheme.dart';
import 'package:discuz_flutter/widget/ForumCardWidget.dart';
import 'package:flutter/material.dart';

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
    // TODO: implement build
    final orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.forum_outlined,color: GlobalTheme.getThemeData().primaryColor,),
            title: Text(_forumPartition.name, style: TextStyle(color: GlobalTheme.getThemeData().primaryColor),),

          ),

          GridView.builder(

              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: orientation == Orientation.portrait ? 2 : 3,
                childAspectRatio: 3

              ),
              itemCount: _subForumList.length,
              itemBuilder: (context, index){
                Forum subForum = _subForumList[index];
                // log("_subforum length ${_subForumList.length} ${_subForumList}");
                return ForumCardWidget(_discuz,_user,subForum);
              },
          ),
          Divider()
        ],
      ),
    );
  }


}