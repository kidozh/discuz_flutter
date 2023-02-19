

import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/CustomizeColor.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

import '../page/UserProfilePage.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../utility/VibrationUtils.dart';

class UserAvatar extends StatelessWidget{
  int uid = 0;
  String username = "";
  Discuz discuz;
  double? width = 16;
  double? height = 16;


  UserAvatar(this.discuz,this.uid, this.username,{this.width, this.height});

  @override
  Widget build(BuildContext context) {
    // touchable
    return InkWell(
      child: ClipRRect(

        borderRadius: BorderRadius.circular(10000.0),
        child: CachedNetworkImage(
          imageUrl: URLUtils.getAvatarURL(discuz, uid.toString()),
          progressIndicatorBuilder: (context, url, downloadProgress) => CircularProgressIndicator(value: downloadProgress.progress),
          errorWidget: (context, url, error) => Container(
            width: this.width,
            height: this.height,
            child: CircleAvatar(
              backgroundColor: CustomizeColor.getColorBackgroundById(uid),
              child: Text(
                username.length != 0
                    ? username[0].toUpperCase()
                    : S.of(context).anonymous,
                style: TextStyle(color: Colors.white,fontSize: 18),
              ),
            ),
          ),
          imageBuilder: (context, imageProvider) => Container(
            width: this.width,
            height: this.height,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                  image: imageProvider, fit: BoxFit.cover),
            ),
          ),
        ),
      ),
      onTap: () async{
        User? user = Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
        Discuz? discuz = Provider.of<DiscuzAndUserNotifier>(context, listen: false).discuz;
        if(discuz != null){
          VibrationUtils.vibrateWithClickIfPossible();
          await Navigator.push(
              context,
              platformPageRoute(context:context,builder: (context) => UserProfilePage(discuz,user, uid)));
        }

      },
    );
  }

}