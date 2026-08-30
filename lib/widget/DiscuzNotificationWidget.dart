import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/DiscuzNotification.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/CustomizeColor.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/utility/TimeDisplayUtils.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/widget/DiscuzHtmlWidget.dart';
import 'package:flutter/material.dart';

class DiscuzNotificationWidget extends StatelessWidget {
  final DiscuzNotification notification;
  final Discuz discuz;
  final ValueChanged<int>? onSelectTid;

  const DiscuzNotificationWidget(
    this.discuz,
    this.notification, {
    this.onSelectTid,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isNew = notification.isNew == '1';
    return PlatformCard(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      color: isNew ? Theme.of(context).colorScheme.primaryContainer : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (notification.author.isNotEmpty) ...[
                _buildAvatar(context),
                const SizedBox(width: 9),
              ],
              Expanded(
                child: Text(
                  notification.author.isNotEmpty
                      ? notification.author
                      : notification.type.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: notification.author.isEmpty
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                TimeDisplayUtils.getLocaledTimeDisplay(
                  context,
                  notification.dateline,
                ),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DiscuzHtmlWidget(
            discuz,
            notification.note,
            onSelectTid: onSelectTid,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final fallback = ColoredBox(
      color: CustomizeColor.getColorBackgroundById(notification.authorId),
      child: Center(
        child: Text(
          notification.author.isNotEmpty
              ? notification.author[0].toUpperCase()
              : S.of(context).notification[0].toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
    return PlatformLiquidGlassAvatar(
      size: 32,
      child: CachedNetworkImage(
        imageUrl: URLUtils.getAvatarURL(
          discuz,
          notification.authorId.toString(),
        ),
        fit: BoxFit.cover,
        progressIndicatorBuilder: (context, url, progress) => Center(
          child: SizedBox.square(
            dimension: 15,
            child: PlatformCircularProgressIndicator(
              material: (_, __) =>
                  MaterialProgressIndicatorData(value: progress.progress),
            ),
          ),
        ),
        errorWidget: (context, url, error) => fallback,
      ),
    );
  }
}
