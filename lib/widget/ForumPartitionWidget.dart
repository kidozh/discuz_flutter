import 'dart:developer';

import 'package:discuz_flutter/JsonResult/DiscuzIndexResult.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/utility/AppPlatformIcons.dart';
import 'package:discuz_flutter/widget/ForumCardWidget.dart';
import 'package:flutter/material.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';

// ignore: must_be_immutable
class ForumPartitionWidget extends StatelessWidget {
  ForumPartition _forumPartition;
  List<Forum> _allForumList = [];
  List<Forum> _subForumList = [];

  Discuz _discuz;
  User? _user;

  ForumPartitionWidget(
      this._discuz, this._user, this._forumPartition, this._allForumList) {
    log("${_allForumList.length} in ${_allForumList}");
    _subForumList = this._forumPartition.getForumList(_allForumList);
  }

  @override
  Widget build(BuildContext context) {
    if (usesLiquidGlass(context)) {
      return PlatformLiquidGlassCard(
        margin: const EdgeInsets.fromLTRB(8, 10, 8, 5),
        padding: const EdgeInsets.only(bottom: 2),
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PlatformListTile(
              leading: Icon(
                AppPlatformIcons(context).forumOutlined,
                color: Theme.of(context).colorScheme.primary,
                size: 18,
              ),
              title: Text(
                _forumPartition.name,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Divider(
              height: 1,
              indent: 12,
              endIndent: 12,
              color: Theme.of(context)
                  .colorScheme
                  .outlineVariant
                  .withValues(alpha: 0.45),
            ),
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 2),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                mainAxisExtent: 64,
              ),
              itemCount: _subForumList.length,
              itemBuilder: (context, index) => ForumCardWidget(
                _discuz,
                _user,
                _subForumList[index],
                embeddedInGlass: true,
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PlatformCard(
          margin: const EdgeInsets.fromLTRB(8, 12, 8, 4),
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.18),
          child: PlatformListTile(
            leading: Icon(
              AppPlatformIcons(context).forumOutlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              _forumPartition.name,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 300, childAspectRatio: 2.6),
          itemCount: _subForumList.length,
          itemBuilder: (context, index) {
            Forum subForum = _subForumList[index];
            // log("_subforum length ${_subForumList.length} ${_subForumList}");
            return ForumCardWidget(_discuz, _user, subForum);
          },
        )
        // if(isCupertino(context))
        // Divider()
      ],
    );
  }
}
