import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/DiscuzAndUserNotifier.dart';
import '../utility/DashboardPreferences.dart';
import '../generated/l10n.dart';
import '../widget/KeylolMobileTopicWidget.dart';
import '../widget/dashboard_tabs.dart';
import 'NewThreadScreen.dart';
import 'HotThreadScreen.dart';
import 'NullDiscuzScreen.dart';

class DashboardScreen extends StatefulWidget {
  final ValueChanged<int>? onSelectTid;
  const DashboardScreen({super.key, this.onSelectTid});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    DashboardPreferences.load().catchError((Object _) {});
  }

  Widget section(String id) => switch (id) {
    'new' => NewThreadScreen(onSelectTid: widget.onSelectTid),
    'hot' => HotThreadScreen(onSelectTid: widget.onSelectTid),
    _ => KeylolMobileTopicWidget(onSelectTid: widget.onSelectTid),
  };
  @override
  Widget build(BuildContext context) {
    final account = context.watch<DiscuzAndUserNotifier>();
    if (account.discuz == null) return NullDiscuzScreen();
    return ValueListenableBuilder<List<String>>(
      valueListenable: DashboardPreferences.order,
      builder: (context, order, _) {
        // The headline renderer operates on the current forum's session and TIDs.
        final ids = DashboardPreferences.visible(
          order,
          keylol: DashboardPreferences.isKeylol(account.discuz!.baseURL),
        );
        final s = S.of(context);
        String label(String id) => id == 'new'
            ? s.newThread
            : id == 'hot'
            ? s.hotThread
            : s.keylolPortal;
        return ValueListenableBuilder<String?>(
          valueListenable: DashboardPreferences.selectedSection,
          builder: (context, _, _) => DashboardTabs(
            key: ValueKey(account.discuz!.baseURL),
            ids: ids,
            labels: ids.map(label).toList(),
            selectedId: DashboardPreferences.activeSection(ids),
            onSelected: (id) => DashboardPreferences.selectedSection.value = id,
            sectionBuilder: section,
          ),
        );
      },
    );
  }
}

// Compatibility for integrations locating the adaptive dashboard by its old name.
typedef CupertinoDashboardScreen = DashboardScreen;
