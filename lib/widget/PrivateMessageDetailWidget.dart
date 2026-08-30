import 'package:discuz_flutter/JsonResult/PrivateMessageDetailResult.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/widget/DiscuzHtmlWidget.dart';
import 'package:discuz_flutter/widget/UserAvatar.dart';
import 'package:flutter/material.dart';

class PrivateMessageDetailWidget extends StatelessWidget {
  final PrivateMessageDetail message;
  final Discuz discuz;
  final User user;
  final bool groupedWithNewer;
  final bool groupedWithOlder;
  final bool showTimestamp;
  final bool isPending;
  final bool sendFailed;
  final bool animateEntrance;
  final VoidCallback? onRetry;

  const PrivateMessageDetailWidget(
    this.discuz,
    this.user,
    this.message, {
    this.groupedWithNewer = false,
    this.groupedWithOlder = false,
    this.showTimestamp = false,
    this.isPending = false,
    this.sendFailed = false,
    this.animateEntrance = false,
    this.onRetry,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isMine = message.msgFromId == user.uid;
    final animationsDisabled = MediaQuery.disableAnimationsOf(context);
    final duration = animationsDisabled || !animateEntrance
        ? Duration.zero
        : const Duration(milliseconds: 280);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: animateEntrance ? 0 : 1, end: 1),
      duration: duration,
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0, 1),
          child: Transform.translate(
            offset: Offset((isMine ? 18 : -18) * (1 - value), 5 * (1 - value)),
            child: Transform.scale(
              scale: 0.86 + (0.14 * value),
              alignment: isMine ? Alignment.bottomRight : Alignment.bottomLeft,
              child: child,
            ),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          10,
          groupedWithOlder ? 2 : 8,
          10,
          groupedWithNewer ? 1 : 3,
        ),
        child: Column(
          children: [
            if (showTimestamp)
              Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 2),
                child: Text(
                  message.readableString,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withValues(alpha: 0.72),
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            Row(
              mainAxisAlignment:
                  isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!isMine) ...[
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: groupedWithNewer
                        ? const SizedBox.shrink()
                        : UserAvatar(
                            discuz,
                            message.msgFromId,
                            message.msgFromName,
                            size: 30,
                          ),
                  ),
                  const SizedBox(width: 7),
                ],
                Flexible(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width * 0.76,
                    ),
                    child: Column(
                      crossAxisAlignment: isMine
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        _MessageBubble(
                          discuz: discuz,
                          message: message.message,
                          isMine: isMine,
                          hasTail: !groupedWithNewer,
                        ),
                        if (isPending)
                          const Padding(
                            padding: EdgeInsets.only(top: 4, right: 5),
                            child: SizedBox.square(
                              dimension: 11,
                              child: PlatformCircularProgressIndicator(),
                            ),
                          ),
                        if (sendFailed)
                          PlatformTextButton(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            onPressed: onRetry,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.error_rounded,
                                  size: 15,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  S.of(context).retry,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (isMine) const SizedBox(width: 2),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Discuz discuz;
  final String message;
  final bool isMine;
  final bool hasTail;

  const _MessageBubble({
    required this.discuz,
    required this.message,
    required this.isMine,
    required this.hasTail,
  });

  BorderRadius get _borderRadius => BorderRadius.only(
        topLeft: const Radius.circular(20),
        topRight: const Radius.circular(20),
        bottomLeft: Radius.circular(!isMine && hasTail ? 6 : 20),
        bottomRight: Radius.circular(isMine && hasTail ? 6 : 20),
      );

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: DefaultTextStyle.merge(
        style: TextStyle(
          color:
              isMine ? Colors.white : Theme.of(context).colorScheme.onSurface,
        ),
        child: DiscuzHtmlWidget(
          discuz,
          message,
          textColor: isMine ? Colors.white : null,
        ),
      ),
    );

    if (!isMine) {
      return PlatformLiquidGlassCard(
        borderRadius: _borderRadius,
        child: content,
      );
    }

    final primary = Theme.of(context).colorScheme.primary;
    return ClipRRect(
      borderRadius: _borderRadius,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.alphaBlend(Colors.white.withValues(alpha: 0.10), primary),
              primary,
            ],
          ),
          borderRadius: _borderRadius,
        ),
        child: content,
      ),
    );
  }
}
