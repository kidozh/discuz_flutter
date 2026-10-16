import 'package:flutter/material.dart';

import '../entity/Discuz.dart';
import '../entity/User.dart';
import '../entity/forum_display_preferences.dart';
import '../generated/l10n.dart';

/// Falls back to the app name when forum identity is hidden.
class ForumHomeTitle extends StatelessWidget {
  const ForumHomeTitle({
    super.key,
    required this.discuz,
    required this.user,
    required this.preferences,
  });
  final Discuz? discuz;
  final User? user;
  final ForumDisplayPreferences preferences;

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    return Text(
      [
        if (discuz == null || !preferences.showForumName) strings.appName,
        if (discuz != null && preferences.showForumName) discuz!.siteName,
        if (discuz != null && preferences.showAccountInfo)
          user == null
              ? strings.incognitoTitle
              : '${user!.username} (${user!.uid})',
      ].join(' · '),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
