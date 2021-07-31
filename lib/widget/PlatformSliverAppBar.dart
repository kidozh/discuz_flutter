

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class PlatformSliverAppBar extends PlatformWidgetBase<CupertinoSliverNavigationBar, SliverAppBar>{
  final Widget? largeTitle;


  /// A widget to place in the middle of the static navigation bar instead of
  /// the [largeTitle].
  ///
  /// This widget is visible in both collapsed and expanded states. The text
  /// supplied in [largeTitle] will no longer appear in collapsed state if a
  /// [middle] widget is provided.
  final Widget? middle;

  /// {@macro flutter.cupertino.CupertinoNavigationBar.trailing}
  ///
  /// This widget is visible in both collapsed and expanded states.
  final List<Widget>? trailingList;


  // final PlatformBuilder<MaterialAppBarData>? material;
  // final PlatformBuilder<CupertinoNavigationBarData>? cupertino;

  const PlatformSliverAppBar({
    Key? key,
    this.largeTitle,
    this.middle,
    this.trailingList,
  }) :super(key: key);

  @override
  CupertinoSliverNavigationBar createCupertinoWidget(BuildContext context) {

    return CupertinoSliverNavigationBar(
        // leading: Material(
        //     child: IconButton(
        //       icon: Icon(PlatformIcons(context).back),
        //       onPressed: () {
        //         Navigator.pop(context);
        //       },
        //     )),
        automaticallyImplyLeading: true,
        automaticallyImplyTitle: true,
        transitionBetweenRoutes: true,

        //middle: this.middle,
        trailing: this.trailingList == null ? null :Material(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: trailingList!
          ),
        ),
        largeTitle: this.largeTitle,
    );


  }

  @override
  SliverAppBar createMaterialWidget(BuildContext context) {
    return SliverAppBar(
      //title: this.middle,
      automaticallyImplyLeading: true,
      floating: false,
      pinned: true,
      snap: false,
      //expandedHeight: 140,
      flexibleSpace: new FlexibleSpaceBar(
        title: this.largeTitle,
        collapseMode: CollapseMode.pin,
      ),
      actions: this.trailingList,

    );
  }
  
  
}