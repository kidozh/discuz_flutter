import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class ToastUtils {
  // MaterialApp and CupertinoApp replace each other when appearance changes.
  // Reparent the singleton host instead of attaching a second one before the
  // old app subtree is disposed (EasyLoading 4 rejects overlapping hosts).
  static final GlobalKey _loadingHostKey = GlobalKey(debugLabel: 'app-loading');

  static TransitionBuilder easyLoadingBuilder() {
    return (context, child) {
      _configureEasyLoading(context);
      // The host animates this inherited text style. Both app shells must use
      // a resolved style; MaterialApp's debug fallback cannot interpolate with
      // Cupertino's non-inheriting text style during reparenting.
      final textStyle = isCupertino(context)
          ? CupertinoTheme.of(context).textTheme.textStyle
          : Theme.of(context).textTheme.bodyMedium!;
      return DefaultTextStyle(
        style: textStyle.copyWith(inherit: false),
        child: FlutterEasyLoading(key: _loadingHostKey, child: child),
      );
    };
  }

  static Future<void> showSuccessfulToast(String msg) {
    return EasyLoading.showSuccess(msg, duration: Durations.medium1);
  }

  static void showActionToast(
    BuildContext context, {
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    if (!usesAppleTranslucentSurface(context)) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          action: SnackBarAction(label: actionLabel, onPressed: onAction),
        ),
      );
      return;
    }

    final labelColor = CupertinoColors.label.resolveFrom(context);
    final actionColor = Theme.of(context).colorScheme.primary;
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        content: PlatformLiquidGlassCard(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          padding: const EdgeInsetsDirectional.only(
            start: 16,
            top: 8,
            end: 6,
            bottom: 8,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: labelColor, fontSize: 15),
                ),
              ),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                onPressed: () {
                  messenger.hideCurrentSnackBar();
                  onAction();
                },
                child: Text(
                  actionLabel,
                  style: TextStyle(
                    color: actionColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _configureEasyLoading(BuildContext context) {
    final glass = usesAppleTranslucentSurface(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final labelColor = glass
        ? CupertinoColors.label.resolveFrom(context)
        : colors.onInverseSurface;
    final indicatorColor = glass ? labelColor : colors.onInverseSurface;
    final successColor = glass
        ? CupertinoColors.systemGreen.resolveFrom(context)
        : colors.primary;
    final errorColor = glass
        ? CupertinoColors.systemRed.resolveFrom(context)
        : colors.error;
    final infoColor = glass
        ? CupertinoColors.systemBlue.resolveFrom(context)
        : colors.primary;

    EasyLoading.instance
      ..loadingStyle = EasyLoadingStyle.custom
      ..animationStyle = EasyLoadingAnimationStyle.custom
      ..customAnimation = _LiquidGlassToastAnimation()
      ..animationDuration = const Duration(milliseconds: 240)
      ..displayDuration = const Duration(milliseconds: 2200)
      ..radius = glass ? 22 : 12
      ..indicatorSize = glass ? 30 : 32
      ..lineWidth = 2.4
      ..progressWidth = 2.4
      ..contentPadding = EdgeInsets.symmetric(
        horizontal: glass ? 20 : 18,
        vertical: glass ? 16 : 14,
      )
      ..textPadding = const EdgeInsets.only(bottom: 10)
      ..fontSize = 15
      ..textAlign = TextAlign.center
      ..backgroundColor = glass ? Colors.transparent : colors.inverseSurface
      ..boxShadow = glass
          ? const []
          : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.20),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ]
      ..textColor = labelColor
      ..indicatorColor = indicatorColor
      ..progressColor = glass ? colors.primary : indicatorColor
      ..maskColor = Colors.black.withValues(alpha: 0.18)
      ..textStyle = TextStyle(
        color: labelColor,
        fontSize: 15,
        height: 1.25,
        fontWeight: glass ? FontWeight.w600 : FontWeight.w500,
      )
      ..indicatorWidget = glass
          ? CupertinoActivityIndicator(radius: 14, color: indicatorColor)
          : CircularProgressIndicator(strokeWidth: 2.4, color: indicatorColor)
      ..successWidget = Icon(
        glass ? CupertinoIcons.check_mark_circled_solid : Icons.check_circle,
        color: successColor,
        size: glass ? 30 : 32,
      )
      ..errorWidget = Icon(
        glass
            ? CupertinoIcons.exclamationmark_triangle_fill
            : Icons.error_rounded,
        color: errorColor,
        size: glass ? 30 : 32,
      )
      ..infoWidget = Icon(
        glass ? CupertinoIcons.info_circle_fill : Icons.info_rounded,
        color: infoColor,
        size: glass ? 30 : 32,
      );
  }

  // EasyLoading 4 applies safe-area spacing outside the animation child.
  // Wrap the panel itself so the glass and accessible content share bounds.
  static Widget _glassBehindEasyLoading(Widget child) {
    return Builder(
      builder: (context) {
        if (!usesAppleTranslucentSurface(context)) return child;
        return toastGlassPanel(child);
      },
    );
  }

  @visibleForTesting
  static Widget toastGlassPanel(Widget child) => PlatformLiquidGlassCard(
    borderRadius: const BorderRadius.all(Radius.circular(22)),
    child: child,
  );

  // static void showInfoToast(BuildContext context, String msg) {
  //   // EasyLoading.showSuccess(
  //   //   msg,
  //   // );
  //
  //   toastification.show(context: context,
  //       title: Text(msg),
  //       style: ToastificationStyle.fillColored,
  //       autoCloseDuration: const Duration(seconds: 2),
  //       showProgressBar: false,
  //       type: ToastificationType.info,
  //       icon: Icon(AppPlatformIcons(context).check),
  //       alignment: Alignment.topCenter
  //
  //
  //   );
  // }

  // static void showErrorToast(BuildContext context, String msg) {
  //   toastification.show(context: context,
  //     title: Text(msg),
  //     style: ToastificationStyle.fillColored,
  //     autoCloseDuration: const Duration(milliseconds: 500),
  //     type: ToastificationType.error
  //   );
  // }
}

class _LiquidGlassToastAnimation extends EasyLoadingAnimation {
  @override
  Widget buildWidget(
    Widget child,
    AnimationController controller,
    AlignmentGeometry alignment,
  ) {
    final progress = Curves.easeOutCubic.transform(controller.value);
    return Opacity(
      opacity: progress,
      child: Transform.scale(
        scale: 0.94 + (0.06 * progress),
        alignment: alignment,
        child: ToastUtils._glassBehindEasyLoading(child),
      ),
    );
  }
}
