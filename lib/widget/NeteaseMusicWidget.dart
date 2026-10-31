import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../generated/l10n.dart';
import '../utility/netease_music_embed.dart';
import '../utility/PlatformAdaptiveWidgets.dart';

/// NetEase's third-party API requires a separate service. Keep the original
/// song accessible without embedding a player or configuring another server.
class NeteaseMusicWidget extends StatelessWidget {
  static const brandColor = Color(0xFFE60026);
  static const iconAsset = 'assets/images/netease_cloud_music.png';

  final NeteaseMusicEmbed embed;
  const NeteaseMusicWidget(this.embed, {super.key});

  Future<void> openSong(BuildContext context) async {
    try {
      if (await launchUrl(
        embed.songUrl,
        mode: LaunchMode.externalApplication,
      )) {
        return;
      }
    } catch (_) {}
    if (!context.mounted) return;
    await showPlatformAlert(
      context: context,
      title: S.of(context).neteaseUnavailable,
      actions: [PlatformAlertAction(label: S.of(context).forumConfirm)],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final light = colors.brightness == Brightness.light;
    final foreground = light ? brandColor : const Color(0xFFFF8295);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: Color.alphaBlend(
          brandColor.withValues(alpha: light ? 0.055 : 0.12),
          colors.surfaceContainerLowest,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: brandColor.withValues(alpha: light ? 0.16 : 0.28),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Semantics(
          link: true,
          child: InkWell(
            onTap: () => openSong(context),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  DecoratedBox(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      iconAsset,
                      width: 36,
                      height: 36,
                      color: brandColor,
                      excludeFromSemantics: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.of(context).neteaseOpenSong,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: foreground,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          embed.songUrl.toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(Icons.open_in_new_rounded, size: 18, color: foreground),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
