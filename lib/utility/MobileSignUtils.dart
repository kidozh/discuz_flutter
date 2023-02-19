
import 'package:dio/dio.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../client/MobileApiClient.dart';
import '../entity/Discuz.dart';
import '../entity/User.dart';
import '../generated/l10n.dart';
import 'NetworkUtils.dart';

class MobileSignUtils{
  static Future<void> conductMobileSign(BuildContext context, Discuz discuz, User user, String formhash) async{
    // check with current discuz and user?
    bool shouldMobileSign = await UserPreferencesUtils.shouldMobileSign(discuz, user.uid);
    if(shouldMobileSign){
      // load the retrofit
      Dio dio = await NetworkUtils.getDioWithPersistCookieJar(user);
      MobileApiClient client = MobileApiClient(dio, baseUrl: discuz.baseURL);
      // fetch it
      client.mobileSignResult(formhash).then((value) async{
        // user may sign elsewhere
        await UserPreferencesUtils.putLastMobileSignRecord(discuz, user.uid);
        if(value.errorResult!= null && value.errorResult?.key == "mobilesign_success"){
          EasyLoading.showSuccess(S.of(context).discuzOperationMessage(value.errorResult?.key.toString() as Object,
              value.errorResult?.content as Object));
          await UserPreferencesUtils.putLastMobileSignRecord(discuz, user.uid);
        }
        else{
          EasyLoading.showError(S.of(context).discuzOperationMessage(value.errorResult?.key.toString() as Object,
              value.errorResult?.content as Object));
        }
      });
    }
  }
}