


import 'package:discuz_flutter/page/DiscuzUserNotificationPage.dart';
import 'package:discuz_flutter/provider/DiscuzNotificationProvider.dart';
import 'package:discuz_flutter/utility/AppPlatformIcons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

import '../utility/VibrationUtils.dart';

class DiscuzNotificationAppbarIconWidget extends StatelessWidget{
  @override
  Widget build(BuildContext context) {

    return Consumer<DiscuzNotificationProvider>(
      builder: (context, discuzNotification, child){
        if(discuzNotification.noticeCount.newprompt == 0 && discuzNotification.noticeCount.newmypost == 0){
          return Container();
        }
        else{
          return PlatformIconButton(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
            icon: Badge.count(
                count: discuzNotification.noticeCount.newprompt + discuzNotification.noticeCount.newmypost,
                alignment: AlignmentDirectional.topEnd,
                child: Icon(AppPlatformIcons(context).notificationSolid),
            ),
            onPressed: () async {
                // go to notification
                VibrationUtils.vibrateWithClickIfPossible();
                await Navigator.push(
                    context,
                    platformPageRoute(context:context,builder: (context) => DiscuzUserNotificationPage())
                );

            },

          );
        }
      },
    );
  }

}