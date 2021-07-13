
import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/JsonResult/DiscuzIndexResult.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/page/DisplayForumPage.dart';
import 'package:discuz_flutter/utility/CustomizeColor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

// ignore: must_be_immutable
class ForumCardWidget extends StatelessWidget{

  Forum _forum;
  Discuz _discuz;
  User? _user;

  ForumCardWidget(this._discuz,this._user,this._forum);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ListTile(
      leading: CachedNetworkImage(
        imageUrl: _forum.iconUrl,
        progressIndicatorBuilder: (context, url, downloadProgress) => CircularProgressIndicator(value: downloadProgress.progress),
        errorWidget: (context, url, error) => Icon(Icons.forum_outlined),
      ),
      title: Text(_forum.name),
      subtitle: Container(
        child: Text(_forum.description),
      ),
      onTap: () async{
        await Navigator.push(
            context,
            platformPageRoute(context:context,builder: (context) => DisplayForumPage(_discuz, _user, _forum.getFid()))
        );
      },
    );
  }


}