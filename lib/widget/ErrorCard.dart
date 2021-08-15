
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/CustomizeColor.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';

class ErrorCard extends StatelessWidget{

  String errorTitle = "";
  String errorDescription = "";

  final VoidCallback onRefreshCallback;


  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return MaterialBanner(
      leading: CircleAvatar(
        child: Icon(Icons.error_outline,color: Colors.white,),
        backgroundColor: Colors.redAccent,
      ),
      content: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(errorTitle, style: Theme.of(context).textTheme.subtitle1,),
            Text(errorDescription, style: Theme.of(context).textTheme.caption)
          ],
      ),
      actions: [
        TextButton(
          child: Text(S.of(context).retry),
          onPressed: () {
            VibrationUtils.vibrateWithClickIfPossible();
            onRefreshCallback();
          },
        ),
      ],

    );
  }

  ErrorCard(this.errorTitle, this.errorDescription,this.onRefreshCallback);
}