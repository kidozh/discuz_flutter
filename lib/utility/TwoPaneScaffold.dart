import 'package:dual_screen/dual_screen.dart';
import 'package:flutter/material.dart';
import 'package:foldable/foldable.dart';

import 'PlatformAdaptiveWidgets.dart' show isCupertino;

import 'TwoPaneUtils.dart';
import 'pane_navigation.dart';

/// Keeps both page trees mounted through folding and window resizing.
class TwoPaneScaffold extends StatefulWidget {
  final TwoPane child;
  final TwoPaneType type;
  final VoidCallback? onCloseDetail;

  /// Changing the selected thread/account clears its old detail subpages.
  final Object? detailIdentity;

  const TwoPaneScaffold({
    super.key,
    required this.type,
    required this.child,
    this.onCloseDetail,
    this.detailIdentity,
  });

  @override
  State<TwoPaneScaffold> createState() => _TwoPaneScaffoldState();
}

class _TwoPaneScaffoldState extends State<TwoPaneScaffold> {
  double _backDrag = 0;
  final _detailNavigator = GlobalKey<NavigatorState>();
  final _heroes = HeroController();
  late final _DetailNavigationObserver _observer;
  bool _detailCanPop = false;
  bool _navigationUpdateScheduled = false;

  @override
  void initState() {
    super.initState();
    _observer = _DetailNavigationObserver(_scheduleNavigationUpdate);
  }

  void _scheduleNavigationUpdate() {
    if (_navigationUpdateScheduled) return;
    _navigationUpdateScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigationUpdateScheduled = false;
      if (!mounted) return;
      final canPop = _detailNavigator.currentState?.canPop() ?? false;
      if (canPop != _detailCanPop) setState(() => _detailCanPop = canPop);
    });
  }

  void _back() {
    if (_detailNavigator.currentState?.canPop() ?? false) {
      _detailNavigator.currentState!.maybePop();
    } else {
      widget.onCloseDetail?.call();
    }
  }

  @override
  void didUpdateWidget(TwoPaneScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.child.panePriority != oldWidget.child.panePriority) {
      _backDrag = 0;
    }
    if (widget.detailIdentity != oldWidget.detailIdentity) {
      // Route mutations must wait until the current build is complete.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _detailNavigator.currentState?.popUntil((route) => route.isFirst);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.child;
    final onCloseDetail = widget.onCloseDetail;
    final media = MediaQuery.of(context);
    // Individual page scaffolds own their bars and keyboard resizing. Only
    // protect the shared horizontal edges here; never resize a second time.
    return PaneNavigationScope(
      navigatorKey: _detailNavigator,
      child: ColoredBox(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          top: false,
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final viewport = Rect.fromLTWH(
                media.padding.left,
                0,
                constraints.maxWidth,
                constraints.maxHeight,
              );
              final localMedia = mediaQueryForPane(media, viewport);
              final sizeClass = DuoMediaQuery.horizontalSizeClassOf(context);
              final layout = PaneLayout.resolve(
                viewport.size,
                localMedia.displayFeatures,
                compactSizeClass: sizeClass == SizeClass.compact,
                regularSizeClass: sizeClass == SizeClass.regular,
                proportion: child.paneProportion,
                textDirection:
                    child.textDirection ?? Directionality.of(context),
              );
              final detailSelected =
                  child.panePriority == TwoPanePriority.end || _detailCanPop;
              Widget pane(Widget page, Rect rect, bool visible, String key) =>
                  Positioned.fromRect(
                    rect: rect,
                    child: Offstage(
                      key: ValueKey(key),
                      offstage: !visible,
                      child: TickerMode(
                        enabled: visible,
                        child: ExcludeFocus(
                          excluding: !visible,
                          child: MediaQuery(
                            data: mediaQueryForPane(localMedia, rect),
                            child: Transform.translate(
                              offset: Offset(
                                key == 'detail' && !layout.showsBoth
                                    ? _backDrag *
                                          (Directionality.of(context) ==
                                                  TextDirection.rtl
                                              ? -1
                                              : 1)
                                    : 0,
                                0,
                              ),
                              // A nested route's modal barrier must only hide
                              // previous routes in this pane from semantics.
                              child: Semantics(
                                container: true,
                                explicitChildNodes: true,
                                child: page,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
              final canSwipeBack =
                  isCupertino(context) &&
                  !layout.showsBoth &&
                  detailSelected &&
                  onCloseDetail != null &&
                  !_detailCanPop;
              final rtl = Directionality.of(context) == TextDirection.rtl;
              return PopScope<Object?>(
                canPop:
                    !_detailCanPop &&
                    (layout.showsBoth ||
                        !detailSelected ||
                        onCloseDetail == null),
                onPopInvokedWithResult: (didPop, result) {
                  if (!didPop && detailSelected) _back();
                },
                child: Stack(
                  children: [
                    pane(
                      child.startPane,
                      layout.start,
                      layout.showsBoth || !detailSelected,
                      'master',
                    ),
                    pane(
                      PaneNavigationScope(
                        navigatorKey: _detailNavigator,
                        isDetail: true,
                        child: HeroControllerScope(
                          controller: _heroes,
                          child: Navigator(
                            key: _detailNavigator,
                            observers: [_observer],
                            pages: [
                              MaterialPage<void>(
                                key: const ValueKey('detail-root'),
                                child: child.endPane,
                              ),
                            ],
                            onDidRemovePage: (_) {},
                          ),
                        ),
                      ),
                      layout.end,
                      layout.showsBoth || detailSelected,
                      'detail',
                    ),
                    if (canSwipeBack)
                      Positioned(
                        left: rtl ? null : layout.end.left,
                        right: rtl ? viewport.width - layout.end.right : null,
                        top: layout.end.top,
                        height: layout.end.height,
                        width: 28,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          excludeFromSemantics: true,
                          onHorizontalDragUpdate: (details) => setState(() {
                            _backDrag =
                                (_backDrag + details.delta.dx * (rtl ? -1 : 1))
                                    .clamp(0.0, layout.end.width)
                                    .toDouble();
                          }),
                          onHorizontalDragEnd: (details) {
                            final velocity =
                                details.primaryVelocity! * (rtl ? -1 : 1);
                            if (_backDrag >= layout.end.width * 0.25 ||
                                (_backDrag > 20 && velocity > 300)) {
                              onCloseDetail();
                            }
                            setState(() => _backDrag = 0);
                          },
                          onHorizontalDragCancel: () =>
                              setState(() => _backDrag = 0),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DetailNavigationObserver extends NavigatorObserver {
  final VoidCallback onChanged;
  _DetailNavigationObserver(this.onChanged);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      onChanged();
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      onChanged();
  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      onChanged();
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      onChanged();
}
