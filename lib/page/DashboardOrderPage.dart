import 'package:flutter/material.dart';
import '../database/AppDatabase.dart';
import '../entity/Discuz.dart';
import '../generated/l10n.dart';
import '../utility/DashboardPreferences.dart';
import '../utility/PlatformAdaptiveWidgets.dart';

String dashboardLabel(S s, String id) => switch (id) {
  'new' => s.newThread,
  'hot' => s.hotThread,
  _ => s.keylolPortal,
};

class DashboardOrderPage extends StatefulWidget {
  final Future<List<Discuz>> Function()? loadSites;
  const DashboardOrderPage({super.key, this.loadSites});
  @override
  State<DashboardOrderPage> createState() => _DashboardOrderPageState();
}

class _DashboardOrderPageState extends State<DashboardOrderPage> {
  List<String> items = [];
  bool loading = true, saving = false;
  String? error;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      await DashboardPreferences.load();
      final sites = widget.loadSites != null
          ? await widget.loadSites!()
          : (await AppDatabase.getDiscuzDao()).findAllDiscuzs();
      final hasKeylol = sites.any(
        (site) => DashboardPreferences.isKeylol(site.baseURL),
      );
      if (mounted)
        setState(() {
          items = DashboardPreferences.visible(
            DashboardPreferences.order.value,
            keylol: hasKeylol,
          );
          loading = false;
        });
    } catch (_) {
      if (mounted)
        setState(() {
          loading = false;
          error = S.of(context).forumLoadFailed;
        });
    }
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    if (saving) return;
    if (newIndex > oldIndex) newIndex--;
    final previous = List<String>.of(items);
    final next = List<String>.of(items)..removeAt(oldIndex);
    next.insert(newIndex, previous[oldIndex]);
    setState(() {
      items = next;
      saving = true;
      error = null;
    });
    try {
      await DashboardPreferences.save(next);
    } catch (_) {
      if (mounted)
        setState(() {
          items = previous;
          error = S.of(context).forumActionFailed;
        });
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return PlatformScaffold(
      appBar: PlatformAppBar(title: Text(s.dashboardOrder)),
      iosContentPadding: true,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(s.dashboardOrderHint),
            ),
            if (error != null) Text(error!),
            if (loading) PlatformCircularProgressIndicator(),
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.all(8),
                buildDefaultDragHandles: false,
                itemCount: items.length,
                onReorder: reorder,
                itemBuilder: (context, index) => PlatformCard(
                  key: ValueKey(items[index]),
                  child: PlatformListTile(
                    leading: Text('${index + 1}'),
                    title: Text(dashboardLabel(s, items[index])),
                    trailing: ReorderableDragStartListener(
                      index: index,
                      enabled: !saving,
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.drag_handle),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
