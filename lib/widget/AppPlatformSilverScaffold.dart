

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
    return PlatformWidget(
      material: (_,__)=> Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: false,
              snap: false,
              pinned: false,
              expandedHeight: 160.0,
              flexibleSpace: const FlexibleSpaceBar(
                title: Text("TITKEssssssssssssssssssdddddddddddddddddddddeeeeeeeeeeef"),
              ),
              actions: trailingActions,
            ),
            this.child
          ],
        ),
      ),
      cupertino: (_,__)=> CupertinoPageScaffold(
        child: CustomScrollView(
          slivers: [
            CupertinoSliverNavigationBar(
              leading: leading,
              middle: title,
              // When the "middle" parameter is implemented, the larget title is only visible
              // when the CupertinoSliverNavigationBar is fully expanded.
              largeTitle: title,
              trailing: createCupertinoSliverNavigationBarTrailingWidget(),
            ),
            SliverFillRemaining(
                child: this.child
            ),
          ]
        ),
        //onLongPress: this.onLongPress,
      ),
    );
  }
  
}