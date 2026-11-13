import 'dart:async';

import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/ExploreWebsitePage.dart';
import 'package:discuz_flutter/page/TestFlightBannerPage.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/screen/ConfigurationScreen.dart';
import 'package:discuz_flutter/screen/DiscuzPortalScreen.dart';
import 'package:discuz_flutter/screen/HotThreadScreen.dart';
import 'package:discuz_flutter/screen/NotificationScreen.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../provider/UserPreferenceNotifierProvider.dart';
import '../widget/forum_home_title.dart';

class ExclusiveDiscuzPortalPage extends StatelessWidget {
  final Discuz _discuz;
  final VoidCallback? onClose;

  ExclusiveDiscuzPortalPage(this._discuz, {this.onClose});

  @override
  Widget build(BuildContext context) {
    return ExclusiveDiscuzPortalStatefulWidget(_discuz, onClose: onClose);
  }
}

class ExclusiveDiscuzPortalStatefulWidget extends StatefulWidget {
  final Discuz _discuz;
  final VoidCallback? onClose;

  ExclusiveDiscuzPortalStatefulWidget(this._discuz, {this.onClose});

  @override
  ExclusiveDiscuzPortalState createState() {
    return ExclusiveDiscuzPortalState(this._discuz);
  }
}

class ExclusiveDiscuzPortalState
    extends State<ExclusiveDiscuzPortalStatefulWidget> {
  Discuz _discuz;
  ExclusiveDiscuzPortalState(this._discuz);

  Future<void> _initDb() async {
    final account = context.read<DiscuzAndUserNotifier>();
    if (_discuz.isSameSite(account.discuz)) return;
    final session = account.sessionIdentity;
    final users = await AppDatabase.getUserDao();
    if (!mounted || !identical(session, account.sessionIdentity)) return;
    account.initDiscuz(
      _discuz,
      user: users.findAllUsersByDiscuz(_discuz).lastOrNull,
    );
  }

  Future<void> _showNotificationIfFirstlyShown() async {
    String flag = await UserPreferencesUtils.getAcceptVersionCodeFlag();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    if (mounted && flag != version) {
      // shown
      Navigator.push(
        context,
        platformPageRoute(
          //iosTitle: S.of(context).testVersion,
          context: context,
          builder: (context) => TestFlightBannerPage(version: version),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    unawaited(_initDb());

    if (widget.onClose == null) unawaited(_showNotificationIfFirstlyShown());
  }

  @override
  Widget build(BuildContext context) {
    final account = context.watch<DiscuzAndUserNotifier>();
    if (!_discuz.isSameSite(account.discuz)) {
      return PlatformScaffold(
        appBar: PlatformAppBar(
          title: Text(_discuz.siteName),
          leading: _previewBackButton,
        ),
        body: const Center(child: PlatformCircularProgressIndicator()),
      );
    }
    return PlatformTabScaffold(
      tabDestinations: [
        TabDestination(
          inactiveIcon: Icon(PlatformIcons(context).globe),
          label: S.of(context).sitePage,
          view: _buildTab(ExploreWebsitePage(key: ValueKey(0))),
        ),
        TabDestination(
          inactiveIcon: Icon(PlatformIcons(context).home),
          label: S.of(context).index,
          view: _buildTab(DiscuzPortalScreen(key: ValueKey(1))),
        ),
        TabDestination(
          inactiveIcon: Icon(PlatformIcons(context).dashboard),
          label: S.of(context).dashboard,
          view: _buildTab(HotThreadScreen()),
        ),
        TabDestination(
          inactiveIcon: Icon(PlatformIcons(context).notificationOutline),
          label: S.of(context).notification,
          view: _buildTab(NotificationScreen()),
        ),
        TabDestination(
          inactiveIcon: Icon(PlatformIcons(context).settings),
          label: S.of(context).settings,
          view: _buildTab(ConfigurationScreen()),
        ),
      ],
    );
  }

  Widget? get _previewBackButton => widget.onClose == null
      ? null
      : PlatformBackButton(onPressed: widget.onClose);

  Widget _buildTab(Widget body) => PlatformScaffold(
    appBar: PlatformAppBar(
      title: ForumHomeTitle(
        discuz: _discuz,
        user: context.watch<DiscuzAndUserNotifier>().user,
        preferences: context
            .watch<UserPreferenceNotifierProvider>()
            .forumDisplay,
      ),
      leading: _previewBackButton,
      automaticallyImplyLeading: false,
    ),
    body: body,
  );

  @override
  void setState(fn) {
    if (this.mounted) {
      super.setState(fn);
    }
  }
}
