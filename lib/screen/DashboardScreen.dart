import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../utility/DashboardPreferences.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import '../generated/l10n.dart';
import '../widget/KeylolMobileTopicWidget.dart';
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
  String? selected;
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
        if (isMaterial(context))
          return DefaultTabController(
            key: ValueKey('${account.discuz!.baseURL}:${ids.join(',')}'),
            length: ids.length,
            child: Column(
              children: [
                TabBar(
                  tabs: [
                    for (final id in ids)
                      Tab(
                        icon: Icon(
                          id == 'new'
                              ? CupertinoIcons.today_fill
                              : id == 'hot'
                              ? Icons.whatshot
                              : Icons.today,
                          semanticLabel: label(id),
                        ),
                      ),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [for (final id in ids) section(id)],
                  ),
                ),
              ],
            ),
          );
        final active = ids.contains(selected) ? selected! : ids.first;
        return SafeArea(
          bottom: false,
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: PlatformSegmentedControl(
                  labels: ids.map(label).toList(),
                  selectedIndex: ids.indexOf(active),
                  onValueChanged: (index) =>
                      setState(() => selected = ids[index]),
                ),
              ),
              Expanded(
                child: KeyedSubtree(
                  key: ValueKey('${account.discuz!.baseURL}:$active'),
                  child: section(active),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Compatibility for integrations locating the adaptive dashboard by its old name.
typedef CupertinoDashboardScreen = DashboardScreen;
