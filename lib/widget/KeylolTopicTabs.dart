import 'dart:math' as math;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';

import '../utility/PlatformAdaptiveWidgets.dart';

/// Lazily pages through topics and remembers each list's reading position.
class KeylolTopicTabs extends StatefulWidget {
  final List<String> titles;
  final IndexedWidgetBuilder topicBuilder;

  const KeylolTopicTabs(
      {required this.titles, required this.topicBuilder, super.key});

  @override
  State<KeylolTopicTabs> createState() => _KeylolTopicTabsState();
}

class _KeylolTopicTabsState extends State<KeylolTopicTabs> {
  final _bucket = PageStorageBucket();
  final _pageController = PageController(keepPage: false);
  final _tabScrollController = ScrollController();
  final _tabsKey = GlobalKey();
  final _selection = ValueNotifier<int>(0);
  int get _selectedIndex => _selection.value;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-reveal the selected label after rotation, text scaling or RTL changes.
    MediaQuery.of(context);
    Directionality.of(context);
    _synchronizeAfterLayout();
  }

  @override
  void didUpdateWidget(KeylolTopicTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.titles, widget.titles)) {
      _selection.value = widget.titles.isEmpty
          ? 0
          : _selectedIndex.clamp(0, widget.titles.length - 1).toInt();
      _synchronizeAfterLayout();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabScrollController.dispose();
    _selection.dispose();
    super.dispose();
  }

  void _synchronizeAfterLayout({bool syncPage = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.titles.isEmpty) return;
      if (syncPage &&
          _pageController.hasClients &&
          _pageController.page != _selectedIndex.toDouble()) {
        _pageController.jumpToPage(_selectedIndex);
      }
      final box = _tabsKey.currentContext?.findRenderObject();
      if (!_tabScrollController.hasClients ||
          box is! RenderBox ||
          !box.hasSize) {
        return;
      }
      final position = _tabScrollController.position;
      final center =
          8 + (_selectedIndex + .5) * box.size.width / widget.titles.length;
      final target = (center - position.viewportDimension / 2)
          .clamp(0.0, position.maxScrollExtent)
          .toDouble();
      _tabScrollController.animateTo(target,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic);
    });
  }

  void _selectTopic(int index) {
    if (index < 0 || index >= widget.titles.length) return;
    _selection.value = index;
    // A distant tap should not construct every intervening forum list.
    if (_pageController.hasClients) _pageController.jumpToPage(index);
    _synchronizeAfterLayout();
  }

  void _onPageChanged(int index) {
    if (index == _selectedIndex) return;
    _selection.value = index;
    _synchronizeAfterLayout(syncPage: false);
  }

  Widget _topic(int index) => KeyedSubtree(
        key: PageStorageKey('keylol-topic-$index'),
        child:
            Builder(builder: (context) => widget.topicBuilder(context, index)),
      );

  @override
  Widget build(BuildContext context) {
    if (widget.titles.isEmpty) return const SizedBox.shrink();
    if (isCupertino(context)) {
      return PageStorage(
        bucket: _bucket,
        child: Column(
          children: [
            ValueListenableBuilder<int>(
                valueListenable: _selection,
                builder: (context, index, _) =>
                    LayoutBuilder(builder: (context, constraints) {
                      final control = PlatformSegmentedControl(
                        key: _tabsKey,
                        labels: widget.titles,
                        selectedIndex: index,
                        color: Theme.of(context).colorScheme.primary,
                        onValueChanged: _selectTopic,
                      );
                      return SingleChildScrollView(
                        controller: _tabScrollController,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                              minWidth: math.max(0, constraints.maxWidth - 16)),
                          child: usesLiquidGlass(context)
                              ? KeylolScrollableTabHitRegion(
                                  labels: widget.titles,
                                  selectedIndex: index,
                                  onSelected: _selectTopic,
                                  child: control,
                                )
                              : control,
                        ),
                      );
                    })),
            Expanded(
                child: PageView.builder(
              controller: _pageController,
              itemCount: widget.titles.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (_, index) => _topic(index),
            )),
          ],
        ),
      );
    }
    return DefaultTabController(
      length: widget.titles.length,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabs: widget.titles.map((title) => Tab(text: title)).toList(),
            labelColor: Theme.of(context).colorScheme.primary,
            indicatorColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor:
                Theme.of(context).brightness == Brightness.light
                    ? Colors.black54
                    : Colors.white54,
            unselectedLabelStyle:
                Theme.of(context).brightness == Brightness.light
                    ? Theme.of(context).textTheme.bodyMedium
                    : Theme.of(context).textTheme.titleMedium,
          ),
          Expanded(
              child: TabBarView(
                  children: List.generate(widget.titles.length, _topic))),
        ],
      ),
    );
  }
}

/// UIKit's segmented control claims horizontal/pan gestures. Keep its native
/// glass rendering, but let Flutter handle taps and the parent handle scrolling.
class KeylolScrollableTabHitRegion extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final Widget child;

  const KeylolScrollableTabHitRegion(
      {required this.labels,
      required this.selectedIndex,
      required this.onSelected,
      required this.child,
      super.key});

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          ExcludeSemantics(child: IgnorePointer(child: child)),
          Positioned.fill(
              child: Row(children: [
            for (var index = 0; index < labels.length; index++)
              Expanded(
                  child: Semantics(
                button: true,
                selected: index == selectedIndex,
                label: labels[index],
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onSelected(index),
                  child: const SizedBox.expand(),
                ),
              )),
          ])),
        ],
      );
}
