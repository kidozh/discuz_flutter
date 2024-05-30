
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/AddDiscuzPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class NullDiscuzScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {

    return SafeArea(
        child: Container(
          child: Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(Icons.announcement),
                    title: Text(S.of(context).nullDiscuzTitle),
                    subtitle: Text(S.of(context).nullDiscuzSubTitle),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      TextButton(
                        child: Text(S.of(context).addNewDiscuz),
                        onPressed: () async{
                          await Navigator.push(
                              context, platformPageRoute(
                              context: context,builder: (context) => AddDiscuzPage()));
                        },
                      ),
                      const SizedBox(width: 16),

                    ],
                  )
                ],
              )
          ),
        )
    );
  }

}