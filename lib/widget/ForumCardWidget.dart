import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/JsonResult/DiscuzIndexResult.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/page/DisplayForumSliverPage.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';

// ignore: must_be_immutable
class ForumCardWidget extends StatelessWidget {
  Forum _forum;
  Discuz _discuz;
  User? _user;
  final bool embeddedInGlass;

  ForumCardWidget(
    this._discuz,
    this._user,
    this._forum, {
    this.embeddedInGlass = false,
  });

  @override
  Widget build(BuildContext context) {
    final description = _forum.description.trim();
    final leadingExtent = embeddedInGlass ? 36.0 : 40.0;
    final avatarSize = embeddedInGlass ? 34.0 : 38.0;
    final tile = PlatformListTile(
      contentPadding: embeddedInGlass
          ? const EdgeInsets.symmetric(horizontal: 10, vertical: 6)
          : null,
      leading: SizedBox.square(
        dimension: leadingExtent,
        child: Badge(
          label: _forum.todayPosts != "0" ? Text(_forum.todayPosts) : null,
          isLabelVisible: _forum.todayPosts != "0" ? true : false,
          child: PlatformLiquidGlassAvatar(
            size: avatarSize,
            child: CachedNetworkImage(
              imageUrl: _forum.iconUrl,
              fit: BoxFit.cover,
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  Center(
                child: SizedBox.square(
                  dimension: 16,
                  child: PlatformCircularProgressIndicator(
                    material: (_, __) => MaterialProgressIndicatorData(
                      value: downloadProgress.progress,
                    ),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => ColoredBox(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Icon(
                  PlatformIcons(context).tagSolid,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _forum.name,
            maxLines: description.isNotEmpty ? 1 : 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              height: 1.18,
            ),
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 13,
                height: 1.22,
              ),
            ),
          ],
        ],
      ),
      onTap: () async {
        VibrationUtils.vibrateWithClickIfPossible();
        await Navigator.push(
            context,
            platformPageRoute(
                context: context,
                iosTitle: _forum.name,
                builder: (context) => DisplayForumTwoPanePage(
                      _discuz,
                      _user,
                      _forum.getFid(),
                      forumTitle: _forum.name,
                    )));
      },
    );
    if (embeddedInGlass) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: tile,
      );
    }
    return PlatformCard(margin: const EdgeInsets.all(4), child: tile);
  }
}
