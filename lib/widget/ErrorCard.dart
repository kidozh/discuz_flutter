

import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../entity/Discuz.dart';
import '../entity/DiscuzError.dart';
import '../entity/User.dart';
import '../page/InternalWebviewBrowserPage.dart';
import '../page/LoginPage.dart';
import '../provider/DiscuzAndUserNotifier.dart';

class ErrorCard extends StatelessWidget{

  DiscuzError discuzError;
  ErrorType? errorType;


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
              Icon(getErrorIcon(context),color: Theme.of(context).colorScheme.error,size: 48,),
              SizedBox(height: 6.0,),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(discuzError.content, style: Theme.of(context).textTheme.headlineSmall),
                  //Text(getErrorLocalizedKey(context), style: Theme.of(context).textTheme.bodyMedium,),

                ],
              ),
              SizedBox(height: 32.0,),
              if(onRefreshCallback!=null)
                SizedBox(
                  width: double.infinity,
                  child: PlatformElevatedButton(
                    child: Text(S.of(context).retry),
                    onPressed: () {
                      VibrationUtils.vibrateWithClickIfPossible();
                      onRefreshCallback!();
                    },
                  ),
                ),
            ],
          ),
        ),
      );
    }
    else{
      return MaterialBanner(
        leading: Icon(getErrorIcon(context), color: Theme.of(context).colorScheme.error,),
        content: Text("${discuzError.content}"),
        //content: Text("${discuzError.content}(${getErrorLocalizedKey(context)})"),
        actions: [
          if(errorType!= ErrorType.userExpired && onRefreshCallback!=null)
            TextButton(
              child: Text(S.of(context).retry, style: TextStyle(color: Theme.of(context).colorScheme.error),),
              onPressed: () {
                VibrationUtils.vibrateWithClickIfPossible();
                onRefreshCallback!();
              },
            ),
          if(discuzError.key == "AddDiscuzParseError" || discuzError.key == "AddDiscuzDioException")
            TextButton(
              child: Text(S.of(context).contactUsViaEmail),
              onPressed: () async{
                VibrationUtils.vibrateWithClickIfPossible();
                await launchUrl(Uri.parse("mailto:kidozh@gmail.com?subject=${discuzError.errorURL == null?"":discuzError.errorURL}"));
                //Navigator.of(context).pop();
              },

            ),
          if(errorType == ErrorType.userExpired)
            // should directly re-login here
            TextButton(
              child: Text(S.of(context).loginTitle, style: TextStyle(color: Theme.of(context).colorScheme.error),),
              onPressed: () async {
                VibrationUtils.vibrateWithClickIfPossible();
                Discuz? discuz = Provider.of<DiscuzAndUserNotifier>(context,listen: false).discuz;
                User? user = Provider.of<DiscuzAndUserNotifier>(context,listen: false).user;
                if(discuz != null){
                  await Navigator.push(
                      context,
                      platformPageRoute(
                          iosTitle: S.of(context).loginTitle,
                          context: context,
                          builder: (context) => LoginPage(discuz, user?.username)));
                }

              },
            ),
          if(discuzError.key == "mobile_template_no_found" && this.webpageUrl!=null)
            TextButton(
              child: Text(S.of(context).navigateToWebPage, style: TextStyle(color: Theme.of(context).colorScheme.primary),),
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
                          iosTitle: S.of(context).navigateToWebPage,
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
    log("GET Dio ERROR ${discuzError.dioError} ${discuzError.key}");
    if(errorType == ErrorType.userExpired){
      return S.of(context).errorUserExpired;
    }
    else if(discuzError.dioError!=null){
      switch (discuzError.dioError!.type){
        case DioExceptionType.sendTimeout:
          return S.of(context).dioErrorSendTimeout;
        case DioExceptionType.receiveTimeout:
          return S.of(context).dioErrorReceiveTimeout;
        case DioExceptionType.cancel:
          return S.of(context).dioErrorCancel;
        case DioExceptionType.connectionTimeout:
          return S.of(context).dioErrorConnectionTimeout;
        case DioExceptionType.badCertificate:
          return S.of(context).dioErrorBadCertificate;
        case DioExceptionType.badResponse:
          return S.of(context).dioErrorBadResponse;
        case DioExceptionType.connectionError:
          return S.of(context).dioErrorConnectionError;
        case DioExceptionType.unknown:
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
    else if(discuzError.dioError!=null){
      switch (discuzError.dioError!.type){
        case DioExceptionType.sendTimeout:
          return Icons.access_time;
        case DioExceptionType.receiveTimeout:
          return Icons.history_toggle_off_outlined;
        case DioExceptionType.cancel:
          return Icons.cancel_outlined;
        case DioExceptionType.connectionTimeout:
          return Icons.explore_off_outlined;
        case DioExceptionType.badCertificate:
          return Icons.key_off_outlined;
        case DioExceptionType.badResponse:
          return Icons.sms_failed_outlined;
        case DioExceptionType.connectionError:
          return Icons.sync_problem_outlined;
        case DioExceptionType.unknown:
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

