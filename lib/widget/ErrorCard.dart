
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
    return Card(
      child: Padding(
        padding: EdgeInsets.all(0.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.error_outline, color: CustomizeColor.error),
              title: Text(errorTitle),
              subtitle: Text(errorDescription),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  child: Text(S.of(context).retry),
                  onPressed: () {
                    onRefreshCallback();
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
      )

    );
  }

  ErrorCard(this.errorTitle, this.errorDescription,this.onRefreshCallback);
}