
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class ErrorCard extends StatelessWidget{

  String errorTitle = "";
  String errorDescription = "";

  final VoidCallback? onRefreshCallback;


  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.symmetric(vertical: 64),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,color: Theme.of(context).errorColor,size: 64,),
            SizedBox(height: 6.0,),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(errorDescription, style: Theme.of(context).textTheme.headline5),
                Text(errorTitle, style: Theme.of(context).textTheme.bodyText2,),

              ],
            ),
            SizedBox(height: 6.0,),
            if(onRefreshCallback!=null)
              PlatformElevatedButton(
                child: Text(S.of(context).retry),
                onPressed: () {
                  VibrationUtils.vibrateWithClickIfPossible();
                  onRefreshCallback!();
                },
              ),
          ],
        ),
      ),
    );
  }

  ErrorCard(this.errorTitle, this.errorDescription,this.onRefreshCallback);
}