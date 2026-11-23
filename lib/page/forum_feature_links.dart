import 'package:flutter/material.dart';

import '../client/ForumInteractionClient.dart';
import '../client/discuz_web_client.dart';
import '../client/forum_community.dart';
import '../client/forum_site_features.dart';
import '../entity/Discuz.dart';
import '../entity/User.dart';
import '../utility/NetworkUtils.dart';
import 'forum_community_page.dart';

typedef _SiteScope = ({
  Object session,
  String site,
  int uid,
  ForumSiteFeature feature,
});
final _features = <_SiteScope, ({DateTime expires, Future<bool> result})>{};

Future<bool> forumFeatureAvailable(
  Object session,
  Discuz discuz,
  User user,
  ForumSiteFeature feature,
) {
  final key = (
    session: session,
    site: discuz.siteIdentity,
    uid: user.uid,
    feature: feature,
  );
  final now = DateTime.now();
  _features.removeWhere((_, entry) => !entry.expires.isAfter(now));
  if (_features[key] case final existing?) return existing.result;

  Future<bool> check() async {
    try {
      final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
      try {
        final web = DiscuzWebClient(
          ForumInteractionClient(dio, discuz.baseURL),
        );
        final page = await web.read(web.page(feature.file, feature.query));
        return feature.available(web, page.uri, page.document);
      } finally {
        dio.close();
      }
    } catch (_) {
      _features.remove(key);
      return false;
    }
  }

  if (_features.length >= 60) _features.remove(_features.keys.first);
  final result = check();
  _features[key] = (expires: now.add(const Duration(hours: 1)), result: result);
  return result;
}

Future<void> openForumCollections(
  BuildContext context,
  Discuz discuz,
  User user,
) => openCommunity(context, discuz, CommunitySection.myCollections);

Future<void> openForumTasks(BuildContext context, Discuz discuz, User user) =>
    openCommunity(context, discuz, CommunitySection.tasks);

Future<void> openForumModeration(
  BuildContext context,
  Discuz discuz,
  User user,
  int fid,
) => openCommunity(
  context,
  discuz,
  CommunitySection.pendingThreads,
  params: {'fid': '$fid'},
);
