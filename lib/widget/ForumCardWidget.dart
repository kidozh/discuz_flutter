import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/JsonResult/DiscuzIndexResult.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/page/DisplayForumSliverPage.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

// ignore: must_be_immutable
class ForumCardWidget extends StatelessWidget {
  Forum _forum;
  Discuz _discuz;
  User? _user;

  ForumCardWidget(this._discuz, this._user, this._forum);

  @override
  Widget build(BuildContext context) {
    return PlatformWidgetBuilder(
        cupertino: (context, child, target) => Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  border: Border.all(
                      color: Theme.of(context).disabledColor,
                    width: 0.1
                  )
              ),
              child: child,
            ),
        material: (context, child, target) => Card(
              child: child,
            ),
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            child: Badge(
              label: _forum.todayPosts !="0"? Text(_forum.todayPosts) : null,
              isLabelVisible: _forum.todayPosts !="0" ?true: false,
              child: CachedNetworkImage(
                imageUrl: _forum.iconUrl,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    CircularProgressIndicator(value: downloadProgress.progress),
                errorWidget: (context, url, error) => CircleAvatar(
                  backgroundColor:
                  Theme.of(context).colorScheme.secondaryContainer,
                  child: Icon(
                    PlatformIcons(context).tagSolid,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          title: Text(
            _forum.name,
            maxLines: _forum.description.length != 0 ? 1 : 2,
            softWrap: true,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: _forum.description.length != 0
              ? Text(_forum.description, maxLines: 2)
              : null,
          onTap: () async {
            VibrationUtils.vibrateWithClickIfPossible();
            await Navigator.push(
                context,
                platformPageRoute(
                    context: context,
                    builder: (context) => DisplayForumTwoPanePage(
                        _discuz, _user, _forum.getFid(),
                        forumTitle: _forum.name,
                    )));
          },
        ));
  }
}
