import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../generated/l10n.dart';
import '../utility/netease_music_embed.dart';
import '../utility/PlatformAdaptiveWidgets.dart';

/// NetEase's third-party API requires a separate service. Keep the original
/// song accessible without embedding a player or configuring another server.
class NeteaseMusicWidget extends StatelessWidget {
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
  Widget build(BuildContext context) => PlatformListTile(
    leading: const Icon(Icons.music_note_outlined),
    title: Text(S.of(context).neteaseOpenSong),
    subtitle: Text(embed.songUrl.toString()),
    onTap: () => openSong(context),
  );
}
