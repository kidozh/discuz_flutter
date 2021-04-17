
import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/JsonResult/DiscuzIndexResult.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/utility/CustomizeColor.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ForumCardWidget extends StatelessWidget{

  Forum _forum;

  ForumCardWidget(this._forum);

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
      subtitle: Text(_forum.description),
      dense: true,
    );
  }


}