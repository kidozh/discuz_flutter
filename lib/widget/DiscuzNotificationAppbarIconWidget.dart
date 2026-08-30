import 'package:discuz_flutter/page/DiscuzUserNotificationPage.dart';
import 'package:discuz_flutter/provider/DiscuzNotificationProvider.dart';
import 'package:discuz_flutter/utility/AppPlatformIcons.dart';
import 'package:flutter/material.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:provider/provider.dart';

import '../generated/l10n.dart';
import '../utility/VibrationUtils.dart';

bool hasDiscuzNotification(BuildContext context) {
  final discuzNotification = Provider.of<DiscuzNotificationProvider>(context);
  return discuzNotification.noticeCount.newprompt +
          discuzNotification.noticeCount.newmypost >
      0;
}

PlatformIconButton buildDiscuzNotificationAppbarIcon(BuildContext context) {
  final discuzNotification = Provider.of<DiscuzNotificationProvider>(context);
  final count = discuzNotification.noticeCount.newprompt +
      discuzNotification.noticeCount.newmypost;
  final icon = Icon(
    count > 0
        ? AppPlatformIcons(context).notificationSolid
        : AppPlatformIcons(context).discuzNotificationOutlined,
    size: isCupertino(context) ? 18 : 24,
    semanticLabel: S.of(context).notification,
  );

  return PlatformIconButton(
    padding: EdgeInsets.zero,
    liquidGlassSymbol: count > 0 ? 'bell.fill' : 'bell',
    icon: count > 0
        ? Badge.count(
            count: count,
            alignment: AlignmentDirectional.topEnd,
            child: icon,
          )
        : icon,
    onPressed: () async {
      VibrationUtils.vibrateWithClickIfPossible();
      await Navigator.push(
        context,
        platformPageRoute(
          context: context,
          iosTitle: S.of(context).notification,
          builder: (context) => DiscuzUserNotificationPage(),
        ),
      );
    },
  );
}

class DiscuzNotificationAppbarIconWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return hasDiscuzNotification(context)
        ? buildDiscuzNotificationAppbarIcon(context)
        : const SizedBox.shrink();
  }
}
