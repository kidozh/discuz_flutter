

import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/CustomizeColor.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class UserAvatar extends StatelessWidget{
  User user;
  int uid = 0;
  Discuz discuz;


  UserAvatar(this.discuz,this.user);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return CachedNetworkImage(
      imageUrl: URLUtils.getAvatarURL(discuz, user.uid.toString()),
      progressIndicatorBuilder: (context, url, downloadProgress) => CircularProgressIndicator(value: downloadProgress.progress),
      errorWidget: (context, url, error) => Container(
        // width: 16.0,
        // height: 16.0,
        child: CircleAvatar(
          backgroundColor: CustomizeColor.getColorBackgroundById(user.uid),
          child: Text(
            user.username.length != 0
                ? user.username[0].toUpperCase()
                : S.of(context).anonymous,
            style: TextStyle(color: Colors.white,fontSize: 18),
          ),
        ),
      ),
      imageBuilder: (context, imageProvider) => Container(
        // width: 16.0,
        // height: 16.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
              image: imageProvider, fit: BoxFit.cover),
        ),
      ),
    );
  }

}