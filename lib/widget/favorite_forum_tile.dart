import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/FavoriteForumInDatabase.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/page/DisplayForumSliverPage.dart';
import 'package:discuz_flutter/utility/AppPlatformIcons.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/utility/TimeDisplayUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';

class FavoriteForumTile extends StatelessWidget {
  const FavoriteForumTile({
    required this.discuz,
    required this.user,
    required this.favorite,
    this.showSavedDate = false,
    super.key,
  });

  final Discuz discuz;
  final User? user;
  final FavoriteForumInDatabase favorite;
  final bool showSavedDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return PlatformListTile(
      contentPadding: const EdgeInsetsDirectional.fromSTEB(12, 7, 12, 7),
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(
          AppPlatformIcons(context).forumOutlined,
          size: 17,
          color: colors.onSurfaceVariant,
        ),
      ),
      title: Text(
        favorite.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: showSavedDate
          ? Text(
              TimeDisplayUtils.getLocaledTimeDisplay(context, favorite.date),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            )
          : null,
      trailing: Icon(
        PlatformIcons(context).forward,
        size: 16,
        color: colors.onSurfaceVariant,
      ),
      onTap: () async {
        VibrationUtils.vibrateWithClickIfPossible();
        await Navigator.push(
          context,
          platformPageRoute(
            context: context,
            iosTitle: favorite.title,
            builder: (context) =>
                DisplayForumTwoPanePage(discuz, user, favorite.idKey),
          ),
        );
      },
    );
  }
}
