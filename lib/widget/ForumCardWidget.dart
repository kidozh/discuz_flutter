
import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/JsonResult/DiscuzIndexResult.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/page/DisplayForumSliverPage.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
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
    return Card(
      surfaceTintColor: Theme.of(context).colorScheme.background,
      color: Theme.of(context).colorScheme.background,
      elevation: 2.0,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          child: CachedNetworkImage(
            imageUrl: _forum.iconUrl,
            progressIndicatorBuilder: (context, url, downloadProgress) => CircularProgressIndicator(value: downloadProgress.progress),
            errorWidget: (context, url, error) => CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              child: Icon(PlatformIcons(context).tagSolid, color: Theme.of(context).colorScheme.onSecondaryContainer, size: 20,),
            ),
          ),
        ),
        title: Text(_forum.name,maxLines: 1, softWrap: true),
        subtitle: Text(_forum.description, maxLines: 2),
        onTap: () async{
          VibrationUtils.vibrateWithClickIfPossible();
          await Navigator.push(
              context,
              platformPageRoute(context:context,builder: (context) => DisplayForumTwoPanePage(_discuz, _user, _forum.getFid()))
          );
        },
      ),
    );
  }


}