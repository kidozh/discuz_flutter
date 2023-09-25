

import 'package:discuz_flutter/utility/SecureStorageUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../dao/DiscuzAuthenticationDao.dart';
import '../generated/l10n.dart';
import '../utility/AppPlatformIcons.dart';

class DiscuzAuthenticationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DiscuzAuthenticationState();
  }
  
}

class DiscuzAuthenticationState extends State<DiscuzAuthenticationPage>{

  AuthenticationStatus authenticationStatus = AuthenticationStatus.could_not_authenticate;

  DiscuzAuthenticationDao? discuzAuthenticationDao = null;

  @override
  void initState() {
    super.initState();
    _loadAuthenticationStatus();
  }

  Future<void> _loadAuthenticationStatus() async{
    AuthenticationStatus _status =  await SecureStorageUtils.getAuthenticationStatus();
    setState(() {
      authenticationStatus = _status;
    });

    if(_status == AuthenticationStatus.can_authenticate){
      await _loadAuthenticationList();
    }
  }

  Future<void> _loadAuthenticationList() async{
    bool result = await SecureStorageUtils.authenticateWithSystem(context);
    if(!result){
      setState(() {
        authenticationStatus = AuthenticationStatus.failed;
      });
    }
    else{
      // success
      discuzAuthenticationDao = await SecureStorageUtils.getDiscuzAuthenticationDao();

      setState(() {
        authenticationStatus = AuthenticationStatus.success;
      });

    }
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      iosContentPadding: true,
      appBar: PlatformAppBar(
        title: Text(S.of(context).discuzAuthenticationTitle),
      ),
      body: failedAuthenticateWidget,
    );
  }

  Widget get deviceNotSupportedWidget => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.max,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(8),
              child: Icon(AppPlatformIcons(context).deviceNotSupportSolid,
                color: Theme.of(context).colorScheme.error,
                size: 36,
              ),
            ),
            Text(S.of(context).authenticationStatusDeviceNotSupported, style: TextStyle(
              color: Theme.of(context).textTheme.titleMedium?.color,
              fontSize: 24,
            )),
          ],
        ),
      )
    ],
  );

  Widget get cannotAuthenticateWidget => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.max,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(8),
              child: Icon(AppPlatformIcons(context).authenticationUnableSolid,
                color: Theme.of(context).colorScheme.error,
                size: 36,
              ),
            ),
            Text(S.of(context).authenticationStatusCannotAuthenticate, style: TextStyle(
              color: Theme.of(context).textTheme.titleMedium?.color,
              fontSize: 24,
            )),
          ],
        ),
      )
    ],
  );

  Widget get failedAuthenticateWidget => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.max,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(8),
              child: Icon(AppPlatformIcons(context).authenticationFailedSolid,
                color: Theme.of(context).colorScheme.error,
                size: 36,
              ),
            ),
            Text(S.of(context).authenticationStatusFailed, style: TextStyle(
              color: Theme.of(context).textTheme.titleMedium?.color,
              fontSize: 24,
            )),
            SizedBox(height: 48,),
            SizedBox(
              width: double.infinity,
              child: PlatformElevatedButton(
                child: Text(S.of(context).retry),
                onPressed: () async {
                  VibrationUtils.vibrateWithClickIfPossible();
                  await _loadAuthenticationList();
                },
              ),
            )

          ],
        ),
      )
    ],
  );

  Widget getAuthenticationListPage(){
    return ListView();
  }



}