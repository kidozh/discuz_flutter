
import 'package:discuz_flutter/utility/CustomizeColor.dart';
import 'package:flutter/material.dart';

class ErrorCard extends StatelessWidget{

  String errorTitle = "";
  String errorDescription = "";



  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Card(
      color: CustomizeColor.errorBackground,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.error_outline, color: CustomizeColor.error),
              title: Text(errorTitle,style: TextStyle(color: CustomizeColor.error),),
              subtitle: Text(errorDescription,style: TextStyle(color: CustomizeColor.error)),
            )
          ],
        ),
      )

    );
  }

  ErrorCard(this.errorTitle, this.errorDescription);
}