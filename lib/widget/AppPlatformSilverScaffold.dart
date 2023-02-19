

import 'package:discuz_flutter/widget/AppPlatformSliverAppbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class AppPlatformSilverScaffold extends StatelessWidget{
  final Widget title;

  Widget? leading;

  Widget child;

  final List<Widget>? trailingActions;

  AppPlatformSilverScaffold({required this.child, required this.title, this.leading, this.trailingActions});

  Widget? createCupertinoSliverNavigationBarTrailingWidget(){
    return trailingActions?.isEmpty ?? true
        ? null
        : Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: trailingActions!,
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return PlatformScaffold(
      body: CustomScrollView(
        slivers: [
          AppPlatformSliverAppBar(
            title: this.title,
            leading: this.leading,
            floating: false,
            snap: false,
            pinned: true,
            actions: trailingActions,

          ),
          SliverFillRemaining(
            child: this.child,
          )
        ],
      ),
    );
  }
  
}