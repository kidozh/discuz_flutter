import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

import '../client/MobileApiClient.dart';
import '../entity/Discuz.dart';
import '../entity/User.dart';
import '../generated/l10n.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import 'NetworkUtils.dart';
import 'UserPreferencesUtils.dart';

class MobileSignUtils {
  static final _signing = <(String, int)>{};

  static Future<void> conductMobileSign(
    BuildContext context,
    Discuz discuz,
    User user,
    String formhash,
  ) async {
    final account = context.read<DiscuzAndUserNotifier>();
    final session = account.sessionIdentity;
    final identity = (discuz.baseURL, user.uid);
    if (!_signing.add(identity)) return;
    bool isCurrent() =>
        context.mounted && identical(session, account.sessionIdentity);
    try {
      if (!await UserPreferencesUtils.shouldMobileSign(discuz, user.uid) ||
          !isCurrent())
        return;
      final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
      if (!isCurrent()) return;
      final result = await MobileApiClient(
        dio,
        baseUrl: discuz.baseURL,
      ).mobileSignResult(formhash);
      final message = result.errorResult;
      if (message == null) return;
      await UserPreferencesUtils.putLastMobileSignRecord(discuz, user.uid);
      if (!isCurrent()) return;
      final text = S
          .of(context)
          .discuzOperationMessage(message.key, message.content);
      if (message.key == 'mobilesign_success') {
        EasyLoading.showSuccess(text);
      } else {
        EasyLoading.showError(text);
      }
    } catch (error) {
      log('Unable to sign in to the forum: $error');
    } finally {
      _signing.remove(identity);
    }
  }
}
