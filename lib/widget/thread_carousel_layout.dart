import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';

import '../utility/app_motion.dart';

/// Uses the feed pane's width so a wide window can show several promotions.
class ThreadCarouselLayout extends StatefulWidget {
  const ThreadCarouselLayout({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.compact = true,
    this.isLoading = false,
    this.autoPlay = true,
  }) : assert(itemCount > 0 || isLoading);

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final bool compact;
  final bool isLoading;
  final bool autoPlay;

  static const maxCardWidth = 480.0;
  static const _minTileWidth = 360.0;

  @override
  State<ThreadCarouselLayout> createState() => _ThreadCarouselLayoutState();
}

class _ThreadCarouselLayoutState extends State<ThreadCarouselLayout>
    with WidgetsBindingObserver {
  static const _loopStart = 10000;
  PageController? _controller;
  Timer? _timer;
  double? _viewportFraction;
  int _count = 0;
  int _currentPage = 0;
  int _selectedIndex = 0;
  bool _loop = false;
  bool _allowAutoPlay = false;
  bool _dragging = false;
  bool _foreground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _foreground =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _syncTimer();
  }

  void _syncTimer() {
    if (!_allowAutoPlay || !_foreground || _dragging) {
      _timer?.cancel();
      _timer = null;
      return;
    }
    _timer ??= Timer.periodic(const Duration(seconds: 5), (_) {
      final controller = _controller;
      if (!mounted ||
          controller == null ||
          !controller.hasClients ||
          ModalRoute.of(context)?.isCurrent == false) {
        return;
      }
      controller.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void _configureController(double fraction, bool loop) {
    if (_controller != null &&
        _viewportFraction == fraction &&
        _count == widget.itemCount &&
        _loop == loop) {
      return;
    }
    final old = _controller;
    _loop = loop;
    _count = widget.itemCount;
    _viewportFraction = fraction;
    _selectedIndex = loop ? _selectedIndex.clamp(0, _count - 1) : 0;
    _currentPage = (loop ? _loopStart : 0) + _selectedIndex;
    _controller = PageController(
      viewportFraction: fraction,
      initialPage: _currentPage,
    );
    // Let the previous PageView detach before disposing its controller.
    if (old != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final availableWidth = constraints.hasBoundedWidth
          ? constraints.maxWidth
          : MediaQuery.sizeOf(context).width;
      final capacity = (availableWidth / ThreadCarouselLayout._minTileWidth)
          .floor()
          .clamp(1, 3);
      final visibleCards = widget.isLoading
          ? capacity
          : math.min(widget.itemCount, capacity);
      final width = math.min(
        availableWidth,
        visibleCards * ThreadCarouselLayout.maxCardWidth,
      );
      final tiled = visibleCards > 1;
      final hasMore = widget.itemCount > visibleCards;
      // Reserve the same height before and after discovering the item count.
      final layoutWidth = math.min(
        availableWidth,
        capacity * ThreadCarouselLayout.maxCardWidth,
      );
      final tileWidth = layoutWidth / capacity;
      final baseHeight = widget.compact
          ? (tileWidth / 2).clamp(180.0, 224.0)
          : (tileWidth / 1.6).clamp(220.0, 280.0);
      final textScale = (MediaQuery.textScalerOf(context).scale(14) / 14).clamp(
        1.0,
        double.infinity,
      );
      final height = baseHeight * textScale;
      final transitionDuration = AppMotion.duration(context, 220);
      _allowAutoPlay =
          !widget.isLoading &&
          hasMore &&
          widget.autoPlay &&
          !MediaQuery.disableAnimationsOf(context) &&
          TickerMode.valuesOf(context).enabled;
      _syncTimer();
      Widget content;
      if (widget.isLoading) {
        content = tiled
            ? Row(
                children: [
                  for (var index = 0; index < visibleCards; index++)
                    Expanded(child: widget.itemBuilder(context, index)),
                ],
              )
            : FractionallySizedBox(
                widthFactor: 0.86,
                child: widget.itemBuilder(context, 0),
              );
      } else {
        _configureController(
          tiled ? 1 / visibleCards : (hasMore ? 0.86 : 1),
          hasMore,
        );
        content = NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.depth != 0) return false;
            if (notification is ScrollStartNotification &&
                notification.dragDetails != null) {
              _dragging = true;
              _syncTimer();
            } else if (notification is ScrollEndNotification) {
              _dragging = false;
              _syncTimer();
            }
            return false;
          },
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              scrollbars: false,
              overscroll: false,
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.stylus,
              },
            ),
            child: PageView.builder(
              controller: _controller,
              itemCount: hasMore ? null : widget.itemCount,
              padEnds: !tiled,
              onPageChanged: (page) {
                _currentPage = page;
                _selectedIndex = hasMore
                    ? (page - _loopStart) % widget.itemCount
                    : page;
              },
              itemBuilder: (context, page) => widget.itemBuilder(
                context,
                hasMore ? (page - _loopStart) % widget.itemCount : page,
              ),
            ),
          ),
        );
      }
      return Align(
        child: SizedBox(
          width: layoutWidth,
          height: height,
          child: AnimatedSwitcher(
            duration: transitionDuration,
            // Only keep the placeholder during the fade. A previous PageView
            // could still be attached to the same controller during a reload.
            reverseDuration: widget.isLoading
                ? transitionDuration
                : Duration.zero,
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            layoutBuilder: (current, previous) => Stack(
              fit: StackFit.expand,
              children: [
                for (final child in previous)
                  IgnorePointer(
                    key: child.key,
                    child: ExcludeSemantics(child: child),
                  ),
                ?current,
              ],
            ),
            child: Align(
              key: ValueKey(widget.isLoading),
              child: SizedBox(width: width, height: height, child: content),
            ),
          ),
        ),
      );
    },
  );
}
