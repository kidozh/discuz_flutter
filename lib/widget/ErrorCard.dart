import 'package:discuz_flutter/utility/BugReportUtils.dart';

import 'package:dio/dio.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:provider/provider.dart';

import '../entity/Discuz.dart';
import '../entity/DiscuzError.dart';
import '../entity/User.dart';
import '../page/InternalWebviewBrowserPage.dart';
import '../page/LoginPage.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../utility/forum_error.dart';

Future<void> showForumActionError(
  BuildContext context,
  DiscuzError failure, {
  bool dialog = false,
}) async {
  final strings = S.of(context);
  if (!failure.reportable && !dialog) {
    await EasyLoading.showError(failure.content);
    return;
  }
  await showPlatformDialog<void>(
    context: context,
    builder: (dialogContext) => PlatformAlertDialog(
      title: Text(strings.forumActionFailed),
      content: Text(failure.content),
      actions: [
        if (failure.reportable)
          PlatformDialogAction(
            child: Text(strings.reportIssue),
            onPressed: () async {
              Navigator.pop(dialogContext);
              if (context.mounted) await BugReportUtils.openIssuePage(context);
            },
          ),
        PlatformDialogAction(
          child: Text(strings.forumConfirm),
          onPressed: () => Navigator.pop(dialogContext),
        ),
      ],
    ),
  );
}

class ErrorCard extends StatelessWidget {
  final DiscuzError discuzError;
  final ErrorType? errorType;

  final VoidCallback? onRefreshCallback;
  final bool? largeSize;
  final String? webpageUrl;

  bool get _canReportIssue =>
      discuzError.reportable && errorType != ErrorType.userExpired;

  bool get _needsWebPage => switch (forumMessageKey(discuzError.key)) {
    'mobile_template_no_found' || 'forum_webpage_redirect' => true,
    _ => false,
  };

  Widget _reportIssueAction(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          S.of(context).reportIssueHint,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        PlatformTextButton(
          key: const ValueKey('error-report-issue'),
          onPressed: () => BugReportUtils.openIssuePage(context),
          child: Text(S.of(context).reportIssue),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (isCupertino(context) && errorType == ErrorType.userExpired) {
      return Semantics(
        container: true,
        child: PlatformCard(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(discuzError.content),
              const SizedBox(height: 8),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: PlatformTextButton(
                  onPressed: () => _loginAgain(context),
                  child: Text(S.of(context).loginTitle),
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (largeSize != false && !_needsWebPage) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 32.0, horizontal: 8.0),
        child: Container(
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                getErrorIcon(context),
                color: Theme.of(context).colorScheme.error,
                size: 48,
              ),
              SizedBox(height: 24.0),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    discuzError.content,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
              if (errorType == ErrorType.userExpired) SizedBox(height: 64.0),
              if (errorType == ErrorType.userExpired)
                SizedBox(
                  width: double.infinity,
                  child: PlatformElevatedButton(
                    child: Text(
                      S.of(context).loginTitle,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: () => _loginAgain(context),
                  ),
                ),
              SizedBox(height: 16.0),
              if (onRefreshCallback != null)
                SizedBox(
                  width: double.infinity,
                  child: PlatformElevatedButton(
                    child: Text(
                      S.of(context).retry,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    color: Theme.of(context).colorScheme.primaryContainer,
                    onPressed: () {
                      VibrationUtils.vibrateWithClickIfPossible();
                      onRefreshCallback!();
                    },
                  ),
                ),
              if (_canReportIssue) _reportIssueAction(context),
            ],
          ),
        ),
      );
    } else {
      return PlatformCard(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        color: Theme.of(context).colorScheme.secondaryContainer,
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  getErrorIcon(context),
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(discuzError.content)),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  if (errorType != ErrorType.userExpired &&
                      onRefreshCallback != null)
                    PlatformTextButton(
                      child: Text(
                        S.of(context).retry,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      onPressed: () {
                        VibrationUtils.vibrateWithClickIfPossible();
                        onRefreshCallback!();
                      },
                    ),
                  if (errorType == ErrorType.userExpired)
                    // should directly re-login here
                    PlatformTextButton(
                      child: Text(
                        S.of(context).loginTitle,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      onPressed: () => _loginAgain(context),
                    ),
                  if (_needsWebPage && webpageUrl != null)
                    PlatformTextButton(
                      child: Text(
                        S.of(context).navigateToWebPage,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      onPressed: () {
                        VibrationUtils.vibrateWithClickIfPossible();
                        // need go to webpage
                        Discuz? discuz = Provider.of<DiscuzAndUserNotifier>(
                          context,
                          listen: false,
                        ).discuz;
                        User? user = Provider.of<DiscuzAndUserNotifier>(
                          context,
                          listen: false,
                        ).user;
                        if (discuz != null) {
                          Navigator.push(
                            context,
                            platformPageRoute(
                              context: context,
                              iosTitle: S.of(context).navigateToWebPage,
                              builder: (context) => InternalWebviewBrowserPage(
                                discuz,
                                user,
                                webpageUrl!,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                ],
              ),
            ),
            if (_canReportIssue) _reportIssueAction(context),
          ],
        ),
      );
    }
  }

  Future<void> _loginAgain(BuildContext context) async {
    VibrationUtils.vibrateWithClickIfPossible();
    final account = context.read<DiscuzAndUserNotifier>();
    final discuz = account.discuz;
    if (discuz == null) return;
    await Navigator.push(
      context,
      platformPageRoute(
        context: context,
        iosTitle: S.of(context).loginTitle,
        builder: (_) => LoginPage(discuz, account.user?.username),
      ),
    );
    if (context.mounted && account.discuz == discuz) {
      onRefreshCallback?.call();
    }
  }

  ErrorCard(
    this.discuzError,
    this.onRefreshCallback, {
    this.largeSize,
    ErrorType? errorType,
    this.webpageUrl,
  }) : errorType = errorType ?? discuzError.errorType;

  IconData getErrorIcon(BuildContext buildContext) {
    final icons = PlatformIcons(buildContext);
    if (errorType == ErrorType.userExpired) {
      return icons.expiredSession;
    } else if (discuzError.dioError != null) {
      switch (discuzError.dioError!.type) {
        case DioExceptionType.transformTimeout:
          return icons.errorOutline;
        case DioExceptionType.sendTimeout:
          return icons.timeout;
        case DioExceptionType.receiveTimeout:
          return icons.historyTimeout;
        case DioExceptionType.cancel:
          return icons.closeCircled;
        case DioExceptionType.connectionTimeout:
          return icons.wifiWarning;
        case DioExceptionType.badCertificate:
          return icons.shieldWarning;
        case DioExceptionType.badResponse:
          return icons.failedMessage;
        case DioExceptionType.connectionError:
          return icons.failedSync;
        case DioExceptionType.unknown:
          return icons.errorOutline;
      }
    } else if (_needsWebPage) {
      return icons.globe;
    } else {
      return icons.errorOutline;
    }
  }
}
