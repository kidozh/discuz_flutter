import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

/// Talks only to this test process's existing loopback VM service. Does not
/// enable a new server, expose its authentication URI or require USB forwarding.
class LocalVmTimeline {
  WebSocket? _socket;
  StreamSubscription<dynamic>? _subscription;
  final _pending = <int, Completer<Map<String, dynamic>>>{};
  var _nextId = 0;
  List<dynamic>? _oldStreams;
  String? unavailable;

  Future<Map<String, dynamic>> _call(String method,
      [Map<String, Object?> params = const {}]) async {
    final id = _nextId++;
    final result = Completer<Map<String, dynamic>>();
    _pending[id] = result;
    _socket!.add(jsonEncode(
        {'jsonrpc': '2.0', 'id': id, 'method': method, 'params': params}));
    try {
      return await result.future.timeout(const Duration(seconds: 5));
    } finally {
      _pending.remove(id);
    }
  }

  Future<void> start() async {
    try {
      final info = await Service.getInfo().timeout(const Duration(seconds: 3));
      final uri = info.serverWebSocketUri;
      if (uri == null ||
          !['127.0.0.1', 'localhost', '::1'].contains(uri.host)) {
        unavailable = 'No existing loopback VM service';
        return;
      }
      _socket = await WebSocket.connect(uri.toString())
          .timeout(const Duration(seconds: 5));
      _subscription = _socket!.listen((raw) {
        final message = jsonDecode(raw as String) as Map<String, dynamic>;
        final completion = _pending[message['id']];
        if (completion == null || completion.isCompleted) return;
        if (message['error'] != null) {
          completion.completeError(StateError('VM timeline RPC failed'));
        } else {
          completion
              .complete(Map<String, dynamic>.from(message['result'] as Map));
        }
      }, onError: (Object _) {});
      final flags = await _call('getVMTimelineFlags');
      _oldStreams = flags['recordedStreams'] as List<dynamic>?;
      await _call('setVMTimelineFlags', {
        'recordedStreams': ['Dart', 'Embedder', 'GC']
      });
      await _call('clearVMTimeline');
    } catch (_) {
      unavailable = 'VM timeline connection or setup failed';
    }
  }

  Future<Map<String, dynamic>> take() async {
    if (unavailable != null) return {'unavailable': unavailable};
    try {
      final result = await _call('getVMTimeline');
      final raw = result['traceEvents'] as List<dynamic>? ?? [];
      // Drop arguments: diagnostic reports must not collect URLs or credentials.
      final events = raw
          .map((dynamic event) => {
                for (final key in [
                  'name',
                  'cat',
                  'ph',
                  'pid',
                  'tid',
                  'ts',
                  'dur'
                ])
                  if ((event as Map).containsKey(key)) key: event[key],
              })
          .toList();
      await _call('clearVMTimeline');
      return {
        'events': events,
        'timeOriginMicros': result['timeOriginMicros'],
        'timeExtentMicros': result['timeExtentMicros']
      };
    } catch (_) {
      unavailable = 'VM timeline retrieval failed';
      return {'unavailable': unavailable};
    }
  }

  Future<void> close() async {
    try {
      if (_oldStreams != null) {
        await _call('setVMTimelineFlags', {'recordedStreams': _oldStreams});
      }
    } catch (_) {
      // The isolated test process may already be shutting down.
    } finally {
      await _subscription?.cancel();
      await _socket?.close();
    }
  }
}
