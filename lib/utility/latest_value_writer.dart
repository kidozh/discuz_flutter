import 'dart:async';

/// Coalesces frequent updates, with an explicit flush at interaction/lifecycle
/// boundaries. Writes are serialized; a slow write never races a newer value.
class LatestValueWriter<T extends Object> {
  final Future<void> Function(T) write;
  final void Function(Object, StackTrace) onError;
  final Duration interval;
  Timer? _timer;
  T? _pending;
  Future<void>? _inFlight;
  bool _flushAgain = false;
  bool _closed = false;

  LatestValueWriter(
      {required this.write,
      required this.onError,
      this.interval = const Duration(milliseconds: 500)});

  void schedule(T value) {
    if (_closed) return;
    _pending = value;
    // A throttle, not a debounce: continuous scrolling still gets checkpoints.
    _timer ??= Timer(interval, () => unawaited(flush()));
  }

  Future<void> flush() {
    _timer?.cancel();
    _timer = null;
    if (_inFlight != null) {
      _flushAgain = true;
      return _inFlight!;
    }
    if (_pending == null) return Future<void>.value();
    final completion = Completer<void>();
    _inFlight = completion.future;
    unawaited(_drain(completion));
    return completion.future;
  }

  Future<void> _drain(Completer<void> completion) async {
    try {
      do {
        _flushAgain = false;
        final value = _pending;
        _pending = null;
        if (value != null) {
          try {
            await write(value);
          } catch (error, stack) {
            onError(error, stack);
          }
        }
      } while (_flushAgain && _pending != null);
      completion.complete();
    } catch (error, stack) {
      completion.completeError(error, stack);
    } finally {
      _inFlight = null;
    }
  }

  Future<void> close() {
    _closed = true;
    return flush();
  }
}
