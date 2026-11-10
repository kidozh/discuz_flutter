import 'package:dio/dio.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:flutter/cupertino.dart';

import '../JsonResult/BaseResult.dart';
import '../entity/DiscuzError.dart';
import '../entity/User.dart';
import '../generated/l10n.dart';

class EasyRefreshUtils {
  static DiscuzError? responseError(
    BuildContext context,
    BaseResult result,
    User? user,
    int memberUid,
  ) {
    final apiError = result.getErrorString();
    if (apiError != null) {
      return DiscuzError(
        result.errorResult?.key ?? S.of(context).error,
        result.errorResult?.content ?? apiError,
      );
    }
    if (user != null && memberUid != user.uid) {
      return DiscuzError(
        S.of(context).userExpiredTitle(user.username),
        S.of(context).userExpiredSubtitle,
        errorType: ErrorType.userExpired,
      );
    }
    return null;
  }

  static DiscuzError requestError(BuildContext context, Object error) {
    if (error is DioException) {
      return DiscuzError(
        error.message ?? S.of(context).error,
        error.type.name,
        dioError: error,
      );
    }
    return DiscuzError(error.runtimeType.toString(), error.toString());
  }

  static Header i18nClassicHeader(
    BuildContext context, {
    IndicatorPosition position = IndicatorPosition.above,
    bool safeArea = true,
  }) {
    if (isCupertino(context)) {
      return CupertinoHeader(
        position: position == IndicatorPosition.above
            ? IndicatorPosition.behind
            : position,
        safeArea: safeArea,
        foregroundColor: CupertinoColors.secondaryLabel.resolveFrom(context),
        userWaterDrop: false,
        hapticFeedback: true,
      );
    }
    return ClassicHeader(
      position: position,
      safeArea: safeArea,
      dragText: S.of(context).easyRefreshClassicHeaderDragText,
      armedText: S.of(context).easyRefreshClassicHeaderArmedText,
      readyText: S.of(context).easyRefreshClassicHeaderReadyText,
      processingText: S.of(context).easyRefreshClassicHeaderProcessingText,
      processedText: S.of(context).easyRefreshClassicHeaderProcessedText,
      noMoreText: S.of(context).easyRefreshClassicHeaderNoMoreText,
      failedText: S.of(context).easyRefreshClassicHeaderFailedText,
      messageText: S.of(context).easyRefreshClassicHeaderMessageText,
    );
  }

  static Footer i18nClassicFooter(
    BuildContext context, {
    bool safeArea = true,
  }) {
    if (isCupertino(context)) {
      return CupertinoFooter(
        safeArea: safeArea,
        foregroundColor: CupertinoColors.secondaryLabel.resolveFrom(context),
        userWaterDrop: false,
        emptyWidget: const SizedBox.shrink(),
      );
    }
    return ClassicFooter(
      safeArea: safeArea,
      dragText: S.of(context).easyRefreshClassicFooterDragText,
      armedText: S.of(context).easyRefreshClassicFooterArmedText,
      readyText: S.of(context).easyRefreshClassicFooterReadyText,
      processingText: S.of(context).easyRefreshClassicFooterProcessingText,
      processedText: S.of(context).easyRefreshClassicFooterProcessedText,
      noMoreText: S.of(context).easyRefreshClassicFooterNoMoreText,
      failedText: S.of(context).easyRefreshClassicFooterFailedText,
      messageText: S.of(context).easyRefreshClassicFooterMessageText,
    );
  }
}
