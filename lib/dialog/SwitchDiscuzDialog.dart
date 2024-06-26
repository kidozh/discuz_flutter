

import 'dart:developer';

import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DiscuzDialogItem extends StatelessWidget {
  Discuz discuz;

  DiscuzDialogItem(
      {required Key key, required this.discuz, required this.onPressed, this.onLongPressed})
      : super(key: key);

  final VoidCallback onPressed;
  final VoidCallback? onLongPressed;

  @override
  Widget build(BuildContext context) {
    Discuz _selecteddiscuz = Provider.of<DiscuzAndUserNotifier>(context, listen: false).discuz!;
    log(_selecteddiscuz.siteName.toString());
    return Card(
        child: ListTile(
          leading: _selecteddiscuz == discuz? Icon(Icons.check, color: Colors.green,): Icon(Icons.forum),
          onTap: onPressed,
          title: Text(discuz.siteName.toString()),
          subtitle: Text(discuz.baseURL.toString()),
          onLongPress: onLongPressed,
        )
    );
  }
}

class SimpleDialogItem extends StatelessWidget {
  const SimpleDialogItem({required Key key, required this.icon, required this.color, required this.text, required this.onPressed, this.onLongPressed})
      : super(key: key);

  final IconData icon;
  final Color color;
  final String text;
  final VoidCallback onPressed;
  final VoidCallback? onLongPressed;

  @override
  Widget build(BuildContext context) {
    return SimpleDialogOption(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 36.0, color: color),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 16.0),
            child: Text(text, overflow: TextOverflow.ellipsis,),
          ),
        ],
      ),

    );
  }
}