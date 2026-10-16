import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:foldable/foldable.dart';

/// Wait for native capability detection to settle before rejecting the stream.
/// foldable 1.0.4's provider drops an initial `unknown` snapshot, even though
/// UIKit delivers the first hinge update asynchronously after attaching a view.
class AppFoldableProvider extends StatefulWidget {
  final Widget child;
  final FoldablePlatform? platform;

  const AppFoldableProvider({super.key, required this.child, this.platform});

  @override
  State<AppFoldableProvider> createState() => _AppFoldableProviderState();
}

class _AppFoldableProviderState extends State<AppFoldableProvider> {
  final _updates = StreamController<FoldableData>.broadcast();
  StreamSubscription<FoldableData>? _subscription;
  late final AppLifecycleListener _lifecycle;
  Size? _lastSize;
  int _revision = 0;

  FoldablePlatform get _platform =>
      widget.platform ?? FoldablePlatform.instance;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _refresh);
    _refresh();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final size = MediaQuery.sizeOf(context);
    if (_lastSize != null && size != _lastSize) _refresh();
    _lastSize = size;
  }

  @override
  void didUpdateWidget(AppFoldableProvider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.platform != oldWidget.platform) {
      unawaited(_subscription?.cancel());
      _subscription = null;
      _refresh();
    }
  }

  void _refresh() async {
    final revision = ++_revision;
    final platform = _platform;
    final snapshot = await platform.getSnapshot();
    if (!mounted || revision != _revision) return;
    _updates.add(snapshot);
    final capabilities = snapshot.capabilities;
    final awaitingDetection =
        capabilities.hingeApiPresent &&
        capabilities.supportLevel == FoldableSupportLevel.unknown;
    if (_subscription != null || (!snapshot.isFoldable && !awaitingDetection)) {
      return;
    }
    _subscription = platform.events.listen((data) {
      if (!mounted || platform != _platform) return;
      ++_revision; // An event is newer than any outstanding one-shot query.
      _updates.add(data);
    }, onDone: () => _subscription = null);
  }

  @override
  void dispose() {
    ++_revision;
    _lifecycle.dispose();
    unawaited(_subscription?.cancel());
    unawaited(_updates.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FoldableProvider(
    bridgeMode: DisplayFeatureBridgeMode.full,
    debugData: _updates.stream,
    child: widget.child,
  );
}
