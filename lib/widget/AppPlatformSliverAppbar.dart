
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

/// Uses a `SliverAppBar` on material or a `CupertinoSliverNavigationBar` on cupertino
class AppPlatformSliverAppBar extends StatelessWidget {
  final Widget? title;
  final Widget? leading;
  final bool floating;
  final bool snap;
  final bool pinned;
  final bool stretch;
  final List<Widget>? actions;
  final String? previousPageTitle;
  final Widget? flexibleSpace;
  final bool cupertinoTransitionBetweenRoutes;

  const AppPlatformSliverAppBar({
    Key? key,
    this.title,
    this.leading,
    this.floating = false,
    this.snap = false,
    this.pinned = false,
    this.stretch = false,
    this.actions,
    this.previousPageTitle,
    this.flexibleSpace,
    this.cupertinoTransitionBetweenRoutes = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      material: (context, platform) => SliverAppBar(
        title: title,
        leading: leading,
        flexibleSpace: flexibleSpace,
        floating: floating,
        snap: snap,
        pinned: pinned,
        stretch: stretch,
        actions: actions,
      ),
      cupertino: (context, platform) {
        final actions = this.actions;
        final trailing = (actions == null || actions.isEmpty)
            ? null
            : (actions.length == 1)
            ? actions.first
            : Row(
          mainAxisSize: MainAxisSize.min,
          children: actions,
        );
        return CupertinoSliverNavigationBar(
          stretch: stretch,
          largeTitle: title,
          leading: leading,
          previousPageTitle: previousPageTitle,
          trailing: trailing,
          transitionBetweenRoutes: cupertinoTransitionBetweenRoutes,
        );
      },
    );
  }
}