
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/CustomizeColor.dart';
import 'package:flutter/material.dart';

class ErrorCard extends StatelessWidget{

  String errorTitle = "";
  String errorDescription = "";

  final VoidCallback onRefreshCallback;


  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return MaterialBanner(
      leading: CircleAvatar(child: Icon(Icons.error_outline),),
      content: Column(
          children: [
            Text(errorTitle, style: Theme.of(context).textTheme.headline3,),
            Text(errorDescription, style: Theme.of(context).textTheme.bodyText1)
          ],
      ),
      actions: [
        TextButton(
          child: Text(S.of(context).retry),
          onPressed: () {
            onRefreshCallback();
          },
        ),
      ],

    );
  }

  ErrorCard(this.errorTitle, this.errorDescription,this.onRefreshCallback);
}