import 'package:flutter/widgets.dart';

import '../entity/Discuz.dart';
import '../entity/User.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import 'InternalWebviewBrowserPage.dart';

Future<void> openForumAccountPage(
  BuildContext context,
  Discuz discuz,
  User user,
  Map<String, String> query, {
  String file = 'home.php',
}) => Navigator.of(context).push<void>(
  platformPageRoute(
    context: context,
    builder: (_) => InternalWebviewBrowserPage(
      discuz,
      user,
      Uri.parse(discuz.getBaseURLWithAfterfix())
          .resolve(file)
          .replace(queryParameters: {...query, 'mobile': 'no'})
          .toString(),
    ),
  ),
);
