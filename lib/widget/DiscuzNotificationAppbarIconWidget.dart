


import 'package:discuz_flutter/provider/DiscuzNotificationProvider.dart';
import 'package:discuz_flutter/utility/AppPlatformIcons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class DiscuzNotificationAppbarIconWidget extends StatelessWidget{
  @override
  Widget build(BuildContext context) {

    return Consumer<DiscuzNotificationProvider>(
      builder: (context, discuzNotification, child){
        if(discuzNotification.noticeCount.getPrompt() == 0){
          return Container();
        }
        else{
          return IconButton(
            icon: Badge.count(
                count: discuzNotification.noticeCount.getPrompt(),
                child: Icon(AppPlatformIcons(context).notificationSolid),
            ),
            onPressed: () {
                // go to notification

            },

          );
        }
      },
    );
  }

}