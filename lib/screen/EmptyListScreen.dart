

import 'package:discuz_flutter/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class EmptyListScreen extends StatelessWidget{
  EmptyItemType emptyItemType = EmptyItemType.others;

  EmptyListScreen(this.emptyItemType);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 64, horizontal: 16),
      child: Center(
          child: SizedBox(
            height: 200.0,
            width: 300.0,
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 50.0,
                    height: 50.0,
                    child: getSpinkitWidget(context),
                  ),
                  Container(
                    child: Text(getTitleString(context)),
                  )
                ],
              ),
            ),
          )),
    );
  }

  Widget getSpinkitWidget(BuildContext context){
    switch(emptyItemType){

      case EmptyItemType.thread:
        return SpinKitChasingDots(
          color: Theme.of(context).colorScheme.primary,
          size: 25.0,
        );
        break;
      case EmptyItemType.post:
        return SpinKitFadingGrid(
          color: Theme.of(context).colorScheme.primary,
          size: 25.0,
        );
        break;
      case EmptyItemType.user:
        return SpinKitSquareCircle(
          color: Theme.of(context).colorScheme.primary,
          size: 25.0,
        );
        break;
      case EmptyItemType.forum:
        return SpinKitWanderingCubes(
          color: Theme.of(context).colorScheme.primary,
          size: 25.0,
        );
        break;
      case EmptyItemType.trustHost:
        return SpinKitWave(
          color: Theme.of(context).colorScheme.primary,
          size: 25.0,
        );
        break;
      case EmptyItemType.history:
        return SpinKitSpinningLines(
          color: Theme.of(context).colorScheme.primary,
          size: 25.0,
        );
        break;
      case EmptyItemType.notification:
        return SpinKitThreeBounce(
          color: Theme.of(context).colorScheme.primary,
          size: 25.0,
        );
        break;
      case EmptyItemType.others:
        return SpinKitWave(
          color: Theme.of(context).colorScheme.primary,
          size: 25.0,
        );
        break;
    }
  }

  String getTitleString(BuildContext context){
    switch(emptyItemType){
      case EmptyItemType.trustHost:{
        return S.of(context).emptyTrustHost;
        break;
      }
      case EmptyItemType.thread:
        return S.of(context).emptyThreads;
        break;
      case EmptyItemType.post:
        return S.of(context).emptyPosts;
        break;
      case EmptyItemType.user:
        return S.of(context).emptyUser;
        break;
      case EmptyItemType.forum:
        return S.of(context).emptyForum;
        break;
      case EmptyItemType.history:
        return S.of(context).emptyHistory;
        break;
      case EmptyItemType.others:
        return S.of(context).emptyListDescription;
        break;
      case EmptyItemType.notification:
        return S.of(context).emptyNotification;
        break;
  }

}

}

enum EmptyItemType{
  thread,
  post,
  user,
  forum,
  trustHost,
  history,
  notification,
  others,

}