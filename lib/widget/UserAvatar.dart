

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
  double? size = 16;
  bool? disableTap = false;

  double getSize(){
    return this.size == null? 16: this.size!;
  }


  UserAvatar(this.discuz,this.uid, this.username,{this.size, this.disableTap});

  @override
  Widget build(BuildContext context) {
    // touchable
    return InkWell(
      child: ClipRRect(

        borderRadius: BorderRadius.circular(10000.0),
        child: CachedNetworkImage(
          imageUrl: URLUtils.getAvatarURL(discuz, uid.toString()),
          progressIndicatorBuilder: (context, url, downloadProgress) => PlatformCircularProgressIndicator(
            material: (_, __) => MaterialProgressIndicatorData(
                value: downloadProgress.progress
            ),
          ),
          errorWidget: (context, url, error) => Container(
            width: this.size,
            height: this.size,
            child: CircleAvatar(
              backgroundColor: CustomizeColor.getColorBackgroundById(uid),
              child: Text(
                username.length != 0
                    ? username[0].toUpperCase()
                    : S.of(context).anonymous,
                style: TextStyle(color: Colors.white,fontSize: this.getSize() * 0.6),
              ),
            ),
          ),
          imageBuilder: (context, imageProvider) => Container(
            width: this.size,
            height: this.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                  image: imageProvider, fit: BoxFit.cover),
            ),
          ),
        ),
      ),

      onTap: this.disableTap == true? null: () async{
        User? user = Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
        Discuz? discuz = Provider.of<DiscuzAndUserNotifier>(context, listen: false).discuz;
        if(discuz != null){
          VibrationUtils.vibrateWithClickIfPossible();
          await Navigator.push(
              context,
              platformPageRoute(context:context,builder: (context) => UserProfilePage(discuz,user, uid, username: username,)));
        }

      },
    );
  }

}