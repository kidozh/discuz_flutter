

import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../generated/l10n.dart';
import '../screen/NotificationScreen.dart';

class DiscuzUserNotificationPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      iosContentPadding: true,
      iosContentBottomPadding: true,
      appBar: PlatformAppBar(
        title: Text(S.of(context).notification),
      ),
      body: NotificationScreen(),
    );
  }

}