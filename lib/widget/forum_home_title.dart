import 'package:flutter/material.dart';

import '../entity/Discuz.dart';
import '../entity/User.dart';
import '../entity/forum_display_preferences.dart';
import '../generated/l10n.dart';
import '../utility/DashboardPreferences.dart';
import '../utility/PlatformAdaptiveWidgets.dart';

/// Falls back to the app name when forum identity is hidden.
class ForumHomeTitle extends StatelessWidget {
  const ForumHomeTitle({
    super.key,
    required this.discuz,
    required this.user,
    required this.preferences,
    this.dashboard = false,
  });
  final Discuz? discuz;
  final User? user;
  final ForumDisplayPreferences preferences;
  final bool dashboard;

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    Widget title([String? category]) => Text(
      <String>[
        if (discuz == null || !preferences.showForumName) strings.appName,
        if (discuz != null && preferences.showForumName) discuz!.siteName,
        ?category,
        if (discuz != null && preferences.showAccountInfo)
          user == null
              ? strings.incognitoTitle
              : '${user!.username} (${user!.uid})',
      ].join(' · '),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    if (!dashboard || discuz == null || !preferences.mergeHomeNavigation) {
      return title();
    }
    return ValueListenableBuilder<List<String>>(
      valueListenable: DashboardPreferences.order,
      builder: (context, order, _) => ValueListenableBuilder<String?>(
        valueListenable: DashboardPreferences.selectedSection,
        builder: (context, _, _) {
          final ids = DashboardPreferences.visible(
            order,
            keylol: DashboardPreferences.isKeylol(discuz!.baseURL),
          );
          String label(String id) => switch (id) {
            'new' => strings.newThread,
            'hot' => strings.hotThread,
            _ => strings.keylolPortal,
          };
          return PlatformTextButton(
            padding: EdgeInsets.zero,
            onPressed: () => PlatformPopupMenu(
              icon: const Icon(Icons.expand_more),
              options: [
                for (final id in ids)
                  PopupMenuOption(
                    label: label(id),
                    onTap: (_) =>
                        DashboardPreferences.selectedSection.value = id,
                  ),
              ],
            ).show(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: title(label(DashboardPreferences.activeSection(ids))),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.expand_more, size: 18),
              ],
            ),
          );
        },
      ),
    );
  }
}
