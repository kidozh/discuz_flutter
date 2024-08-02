
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/AddDiscuzPage.dart';
import 'package:discuz_flutter/page/SettingPage.dart';
import 'package:discuz_flutter/utility/AppPlatformIcons.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class NullDiscuzScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {

    return SafeArea(
        child: Container(

          child: Padding(

              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 32, top: 16),
                    child: Container(
                      width: 128,
                      height: 128,
                      child: CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: Icon(AppPlatformIcons(context).addDiscuzSolid, color: Colors.white, size: 80,),
                      ),
                    ),
                  ),
                  Text(S.of(context).nullDiscuzScreenTitle, style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold
                  ),),
                  SizedBox(height: 8,),
                  Text(S.of(context).nullDiscuzScreenSubtitle, style: Theme.of(context).textTheme.bodyMedium,),
                  SizedBox(height: 32,),
                  SizedBox(
                    width: double.infinity,
                    child: PlatformElevatedButton(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Text(S.of(context).addNewDiscuz, style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),),
                      onPressed: () async{
                        VibrationUtils.vibrateWithClickIfPossible();
                        await Navigator.push(
                            context, platformPageRoute(
                            context: context,builder: (context) => AddDiscuzPage()));
                      },

                    ),
                  ),
                  SizedBox(height: 8,),
                  SizedBox(
                    width: double.infinity,
                    child: PlatformTextButton(

                      child: Text(S.of(context).settings + "   ↗️"),
                      onPressed: () async{
                        VibrationUtils.vibrateWithClickIfPossible();
                        await Navigator.push(
                            context, platformPageRoute(
                            context: context,builder: (context) => SettingPage()));
                      },

                    ),
                  ),
                ],
              )
          ),
        )
    );
  }

}