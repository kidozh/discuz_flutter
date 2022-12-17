

import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

import '../entity/Discuz.dart';
import '../entity/DiscuzError.dart';
import '../entity/User.dart';
import '../page/InternalWebviewBrowserPage.dart';
import '../provider/DiscuzAndUserNotifier.dart';

class ErrorCard extends StatelessWidget{

  DiscuzError discuzError;
  ErrorType? errorType;
  DioError? dioError;


  final VoidCallback? onRefreshCallback;
  bool? largeSize = true;
  String? webpageUrl = null;


  @override
  Widget build(BuildContext context) {

    if(errorType!= ErrorType.userExpired && (largeSize == null || largeSize == true ) && (discuzError.key!= "mobile_template_no_found")){
      return Padding(padding: EdgeInsets.symmetric(vertical: 32.0, horizontal: 8.0),
        child: Container(
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(getErrorIcon(context),color: Theme.of(context).errorColor,size: 64,),
              SizedBox(height: 6.0,),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(discuzError.content, style: Theme.of(context).textTheme.headline5),
                  Text(getErrorLocalizedKey(context), style: Theme.of(context).textTheme.bodyText2,),

                ],
              ),
              SizedBox(height: 16.0,),
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
    else{
      return MaterialBanner(
        leading: Icon(getErrorIcon(context), color: Theme.of(context).errorColor,),
        content: Text("${discuzError.content}(${getErrorLocalizedKey(context)})"),
        actions: [
          if(onRefreshCallback!=null)
            TextButton(
              child: Text(S.of(context).retry, style: TextStyle(color: Theme.of(context).errorColor),),
              onPressed: () {
                VibrationUtils.vibrateWithClickIfPossible();
                onRefreshCallback!();
              },
            ),
          if(discuzError.key == "mobile_template_no_found" && this.webpageUrl!=null)
            TextButton(
              child: Text(S.of(context).navigateToWebPage, style: TextStyle(color: Theme.of(context).errorColor),),
              onPressed: () {
                VibrationUtils.vibrateWithClickIfPossible();
                // need go to webpage
                Discuz? discuz =
                    Provider.of<DiscuzAndUserNotifier>(context, listen: false).discuz;
                User? user =
                    Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
                if(discuz!=null){
                  Navigator.push(
                      context,
                      platformPageRoute(
                          context: context,
                          builder: (context) => InternalWebviewBrowserPage(
                              discuz,
                              user,
                              webpageUrl!)));
                }
              },
            ),
        ],
      );
    }

  }

  ErrorCard(this.discuzError,this.onRefreshCallback, {this.largeSize, this.errorType, this.webpageUrl});

  String getErrorLocalizedKey(BuildContext context){
    log("GET Dio ERROR ${dioError} ${discuzError.key}");
    if(errorType == ErrorType.userExpired){
      return S.of(context).errorUserExpired;
    }
    else if(dioError!=null){
      switch (dioError!.type){
        case DioErrorType.connectTimeout:
          return S.of(context).dioErrorConnectionTimeout;
        case DioErrorType.sendTimeout:
          return S.of(context).dioErrorSendTimeout;
        case DioErrorType.receiveTimeout:
          return S.of(context).dioErrorReceiveTimeout;
        case DioErrorType.response:
          return S.of(context).dioErrorResponse;
        case DioErrorType.cancel:
          return S.of(context).dioErrorCancel;
        case DioErrorType.other:
          return S.of(context).dioErrorOther;
      }
    }
    else if(discuzError.key == "mobile_template_no_found"){
      return S.of(context).mobileTemplateNotFound;
    }
    else{
      return discuzError.key;
    }
  }

  IconData getErrorIcon(BuildContext buildContext){
    if(errorType == ErrorType.userExpired){
      return Icons.person_add_disabled;
    }
    else if(dioError!=null){
      switch (dioError!.type){
        case DioErrorType.connectTimeout:
          return Icons.explore_off_outlined;
        case DioErrorType.sendTimeout:
          return Icons.access_time;
        case DioErrorType.receiveTimeout:
          return Icons.history_toggle_off_outlined;
        case DioErrorType.response:
          return Icons.sms_failed_outlined;
        case DioErrorType.cancel:
          return Icons.cancel_outlined;
        case DioErrorType.other:
          return Icons.error_outline;
      }
    }
    else if(discuzError.key == "mobile_template_no_found"){
      return Icons.explore_outlined;
    }
    else{
      return Icons.error_outline;
    }
  }
}

