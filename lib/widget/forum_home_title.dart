import 'package:flutter/material.dart';

import '../entity/Discuz.dart';
import '../entity/User.dart';
import '../entity/forum_display_preferences.dart';
import '../generated/l10n.dart';
import '../utility/DashboardPreferences.dart';
import '../utility/PlatformAdaptiveWidgets.dart';

/// Shares the category selection with the dashboard, freeing its extra header.
class ForumHomeTitle extends StatelessWidget {
  const ForumHomeTitle({
    super.key,
    required this.discuz,
    required this.user,
    required this.preferences,
    required this.dashboard,
  });
  final Discuz? discuz;
  final User? user;
  final ForumDisplayPreferences preferences;
  final bool dashboard;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<List<String>>(
    valueListenable: DashboardPreferences.order,
    builder: (context, order, _) => ValueListenableBuilder<String?>(
      valueListenable: DashboardPreferences.selectedSection,
      builder: (context, _, _) {
        final strings = S.of(context);
        final ids = DashboardPreferences.visible(
          order,
          keylol: DashboardPreferences.isKeylol(discuz?.baseURL ?? ''),
        );
        final active = DashboardPreferences.activeSection(ids);
        String label(String id) => switch (id) {
          'new' => strings.newThread,
          'hot' => strings.hotThread,
          _ => strings.keylolPortal,
        };
        final combined =
            dashboard && discuz != null && preferences.compactHeader;
        final parts = <String>[
          if (discuz == null) strings.appName,
          if (discuz != null && preferences.showForumName) discuz!.siteName,
          if (combined) label(active),
          if (discuz != null && preferences.showAccountInfo)
            user == null
                ? strings.incognitoTitle
                : '${user!.username} (${user!.uid})',
        ];
        final title = Text(
          parts.join(' · '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
        if (!combined) return title;
        return Semantics(
          button: true,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => PlatformPopupMenu(
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
            child: SizedBox(
              height: 44,
              child: Row(
                children: [
                  Expanded(child: title),
                  const Icon(Icons.expand_more, size: 18),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}
