import 'package:flutter/widgets.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';

import '../generated/l10n.dart';
import '../screen/NotificationScreen.dart';

class DiscuzUserNotificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      iosContentPadding: false,
      iosContentBottomPadding: true,
      appBar: PlatformAppBar(
        liquidGlassTitle: S.of(context).notification,
        title: Text(S.of(context).notification),
      ),
      body: const NotificationScreen(),
    );
  }
}
