import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utility/PlatformAdaptiveWidgets.dart';

/// Retains visible category navigation, including Material's swipe gesture.
class DashboardTabs extends StatefulWidget {
  const DashboardTabs({
    super.key,
    required this.ids,
    required this.labels,
    required this.selectedId,
    required this.onSelected,
    required this.sectionBuilder,
  });
  final List<String> ids;
  final List<String> labels;
  final String selectedId;
  final ValueChanged<String> onSelected;
  final Widget Function(String id) sectionBuilder;

  @override
  State<DashboardTabs> createState() => _DashboardTabsState();
}

class _DashboardTabsState extends State<DashboardTabs>
    with TickerProviderStateMixin {
  late TabController _controller;
  bool _syncing = false;

  int get _selectedIndex =>
      widget.ids.indexOf(widget.selectedId).clamp(0, widget.ids.length - 1);

  @override
  void initState() {
    super.initState();
    _createController();
  }

  void _createController() {
    _controller = TabController(
      length: widget.ids.length,
      initialIndex: _selectedIndex,
      vsync: this,
    )..addListener(_handleSelection);
  }

  void _handleSelection() {
    if (_syncing || _controller.indexIsChanging) return;
    final id = widget.ids[_controller.index];
    if (id != widget.selectedId) widget.onSelected(id);
  }

  @override
  void didUpdateWidget(DashboardTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.ids, widget.ids)) {
      _controller.dispose();
      _createController();
    } else if (_controller.index != _selectedIndex) {
      _syncing = true;
      _controller.index = _selectedIndex;
      _syncing = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isMaterial(context)) {
      return Column(
        children: [
          TabBar(
            controller: _controller,
            tabs: [
              for (var index = 0; index < widget.ids.length; index++)
                Tab(
                  height: 40,
                  icon: Icon(
                    switch (widget.ids[index]) {
                      'new' => CupertinoIcons.today_fill,
                      'hot' => Icons.whatshot,
                      _ => Icons.today,
                    },
                    size: 22,
                    semanticLabel: widget.labels[index],
                  ),
                ),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _controller,
              children: [
                for (final id in widget.ids) widget.sectionBuilder(id),
              ],
            ),
          ),
        ],
      );
    }
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: PlatformSegmentedControl(
              labels: widget.labels,
              selectedIndex: _selectedIndex,
              onValueChanged: (index) => widget.onSelected(widget.ids[index]),
            ),
          ),
          Expanded(
            child: KeyedSubtree(
              key: ValueKey(widget.selectedId),
              child: widget.sectionBuilder(widget.ids[_selectedIndex]),
            ),
          ),
        ],
      ),
    );
  }
}
