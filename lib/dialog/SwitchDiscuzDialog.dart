import 'dart:developer';

import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DiscuzDialogItem extends StatelessWidget {
  Discuz discuz;

  DiscuzDialogItem(
      {required Key key,
      required this.discuz,
      required this.onPressed,
      this.onLongPressed})
      : super(key: key);

  final VoidCallback onPressed;
  final VoidCallback? onLongPressed;

  @override
  Widget build(BuildContext context) {
    Discuz _selecteddiscuz =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false).discuz!;
    log(_selecteddiscuz.siteName.toString());
    return PlatformCard(
        child: PlatformListTile(
      leading: _selecteddiscuz == discuz
          ? Icon(
              PlatformIcons(context).checkMark,
              color: Colors.green,
            )
          : Icon(PlatformIcons(context).forumOutline),
      onTap: onPressed,
      title: Text(discuz.siteName.toString()),
      subtitle: Text(discuz.baseURL.toString()),
      onLongPress: onLongPressed,
    ));
  }
}

class SimpleDialogItem extends StatelessWidget {
  const SimpleDialogItem(
      {required Key key,
      required this.icon,
      required this.color,
      required this.text,
      required this.onPressed,
      this.onLongPressed})
      : super(key: key);

  final IconData icon;
  final Color color;
  final String text;
  final VoidCallback onPressed;
  final VoidCallback? onLongPressed;

  @override
  Widget build(BuildContext context) {
    return PlatformListTile(
      leading: Icon(icon, size: 32, color: color),
      title: Text(text, overflow: TextOverflow.ellipsis),
      onTap: onPressed,
      onLongPress: onLongPressed,
    );
  }
}
