import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:almanacinc_record_mp3/almanacinc_record_mp3.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../generated/l10n.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import '../utility/forum_error.dart';
import '../utility/forum_voice.dart';
import 'ErrorCard.dart';
import 'forum_voice_message.dart';

class ForumVoiceButton extends StatelessWidget {
  const ForumVoiceButton({required this.onPressed, super.key});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => PlatformIconButton(
    liquidGlassSymbol: 'waveform',
    liquidGlassButtonSize: 44,
    liquidGlassIconSize: 18,
    icon: Icon(
      PlatformIcons(context)
          .pick(Icons.graphic_eq_rounded, CupertinoIcons.waveform),
      size: 21,
      semanticLabel: S.of(context).voiceRecord,
    ),
    onPressed: onPressed,
  );
}

/// Device capture is separate from the editor lifecycle so delayed microphone
/// permission/start callbacks can be exercised without a physical microphone.
abstract interface class ForumVoiceCapture {
  Future<bool> hasPermission();
  Future<void> start(String path, VoidCallback onError);
  Future<String?> stop();
  Future<void> dispose();
}

class _NativeVoiceCapture implements ForumVoiceCapture {
  _NativeVoiceCapture(this.format);
  final ForumVoiceFormat format;
  final _mp3 = AlmanacRecordMp3.instance;
  AudioRecorder? _native;
  AudioRecorder get native => _native ??= AudioRecorder();
  bool get mp3 => format == ForumVoiceFormat.mp3;

  @override
  Future<bool> hasPermission() =>
      mp3 ? _mp3.hasPermission() : native.hasPermission();
  @override
  Future<void> start(String path, VoidCallback onError) async {
    if (mp3) {
      if (!await _mp3.start(
        path,
        sampleRate: forumVoiceSampleRate,
        bitRate: forumVoiceBitRate,
        onError: (_) => onError(),
      )) {
        throw StateError('Recording did not start');
      }
    } else {
      await native.start(
        RecordConfig(
          encoder: format == ForumVoiceFormat.wav
              ? AudioEncoder.wav
              : AudioEncoder.aacLc,
          sampleRate: forumVoiceSampleRate,
          bitRate: forumVoiceBitRate * 1000,
          numChannels: 1,
        ),
        path: path,
      );
    }
  }

  @override
  Future<String?> stop() => mp3 ? _mp3.stop() : native.stop();
  @override
  Future<void> dispose() async => _native?.dispose();
}

/// Starts when opened from the waveform action. Stop keeps a playable draft;
/// replies can also send directly while recording. Topics retain confirmation.
class ForumVoiceRecorder extends StatefulWidget {
  const ForumVoiceRecorder({
    required this.options,
    required this.onRecorded,
    required this.onClosed,
    this.onSend,
    this.capture,
    super.key,
  });
  final ForumVoiceOptions options;
  // Return true to keep the temporary file for the lifetime of the editor.
  final Future<bool> Function(RecordedForumVoice) onRecorded;
  final VoidCallback onClosed;
  final VoidCallback? onSend;
  final ForumVoiceCapture? capture;

  @override
  State<ForumVoiceRecorder> createState() => _ForumVoiceRecorderState();
}

class _ForumVoiceRecorderState extends State<ForumVoiceRecorder>
    with WidgetsBindingObserver {
  late final _capture =
      widget.capture ?? _NativeVoiceCapture(widget.options.format);
  final _clock = Stopwatch();
  Directory? _directory;
  Timer? _ticker;
  Future<void>? _operation;
  bool _starting = false, _recording = false, _finishing = false;
  bool _interrupted = false, _closed = false;
  Duration get _limit => Duration(seconds: widget.options.maxSeconds);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _begin();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.hidden &&
        state != AppLifecycleState.paused) {
      return;
    }
    if (!_starting && !_recording && !_finishing) return;
    _interrupted = true;
    if (_recording) {
      _finish(discard: _clock.elapsed.inSeconds < 1);
    }
  }

  void _begin() {
    if (_starting || _recording || _finishing || _interrupted) return;
    _clock.reset();
    setState(() {
      _starting = true;
    });
    unawaited(HapticFeedback.lightImpact());
    _operation = _start();
  }

  Future<void> _start() async {
    final s = S.of(context);
    var started = false;
    var captureFailed = false;
    try {
      await ForumVoiceMessage.pausePlayback();
      if (!mounted || _interrupted) return;
      if (!await _capture.hasPermission()) {
        if (mounted) {
          unawaited(EasyLoading.showError(s.voiceMicrophonePermission));
        }
        return;
      }
      if (!mounted || _interrupted) return;
      final folder = _directory = await (await getTemporaryDirectory())
          .createTemp('voice-');
      if (!mounted || _interrupted) return;
      await _capture.start(
        '${folder.path}/recording.${widget.options.format.name}',
        () {
          captureFailed = true;
          if (mounted && _recording) _finish(failed: true);
        },
      );
      started = true;
      if (captureFailed) {
        await _capture.stop();
        throw StateError('Recording failed during startup');
      }
      // Closing or backgrounding during permission/startup must never leave
      // an unattended recording running after the asynchronous callback.
      if (!mounted || _interrupted) {
        await _capture.stop();
        return;
      }
      _clock.start();
      setState(() {
        _starting = false;
        _recording = true;
      });
      _ticker = Timer.periodic(const Duration(milliseconds: 90), (_) {
        if (_clock.elapsed >= _limit) {
          // Reaching the forum limit preserves a draft, never sends it.
          _finish();
        } else if (mounted) {
          setState(() {});
        }
      });
    } catch (_) {
      if (!started) {
        try {
          await _capture.stop();
        } catch (_) {}
      }
      if (mounted) unawaited(EasyLoading.showError(s.voiceRecordingFailed));
    } finally {
      if (!_recording) {
        await _deleteTemporary();
        if (mounted) _notifyClosed();
      }
    }
  }

  void _finish({bool discard = false, bool send = false, bool failed = false}) {
    if (!_recording || _finishing) return;
    _ticker?.cancel();
    _clock.stop();
    setState(() {
      _recording = false;
      _finishing = true;
    });
    _operation = _save(discard: discard, send: send, failed: failed);
  }

  Future<void> _save({
    required bool discard,
    required bool send,
    required bool failed,
  }) async {
    final s = S.of(context);
    var saved = false;
    try {
      final path = await _capture.stop();
      if (!mounted || discard) return;
      if (failed || path == null || await File(path).length() <= 0) {
        if (mounted) unawaited(EasyLoading.showError(s.voiceRecordingFailed));
        return;
      }
      if (_clock.elapsed.inSeconds < 1) {
        if (mounted) unawaited(EasyLoading.showError(s.voiceTooShort));
        return;
      }
      if (!mounted) return;
      final retain = await widget.onRecorded(
        RecordedForumVoice(
          File(path),
          Duration(
            seconds: _clock.elapsed.inSeconds.clamp(
              1,
              widget.options.maxSeconds,
            ),
          ),
          widget.options.format,
        ),
      );
      if (retain) _directory = null;
      saved = true;
    } catch (error) {
      if (mounted) {
        await showForumActionError(
          context,
          forumRequestError(s, error, fallback: s.attachmentUploadFailed),
        );
      }
    } finally {
      await _deleteTemporary();
      if (mounted) {
        _notifyClosed();
        if (saved && send && !_interrupted) widget.onSend?.call();
      }
    }
  }

  void _notifyClosed() {
    if (_closed) return;
    _closed = true;
    widget.onClosed();
  }

  Future<void> _deleteTemporary() async {
    final folder = _directory;
    _directory = null;
    try {
      await folder?.delete(recursive: true);
    } on FileSystemException {
      // Temporary storage can also be reclaimed by the OS.
    }
  }

  void _close() {
    _interrupted = true;
    _notifyClosed();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    _interrupted = true;
    final operation = _operation;
    unawaited(() async {
      try {
        await operation;
        if (_recording) await _capture.stop();
      } finally {
        await _capture.dispose();
        await _deleteTemporary();
      }
    }());
    super.dispose();
  }

  Widget _control({
    required String key,
    required String label,
    required IconData icon,
    required Color color,
    Color? fill,
    VoidCallback? onPressed,
  }) {
    final contents = Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
      child: Icon(
        icon,
        size: 18,
        color: onPressed == null ? color.withValues(alpha: .35) : color,
      ),
    );
    return Semantics(
      label: label,
      button: true,
      enabled: onPressed != null,
      onTap: onPressed,
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: 44,
        child: isCupertino(context)
            ? CupertinoButton(
                key: ValueKey(key),
                padding: EdgeInsets.zero,
                onPressed: onPressed,
                child: contents,
              )
            : IconButton(
                key: ValueKey(key),
                padding: EdgeInsets.zero,
                onPressed: onPressed,
                icon: contents,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final ios = isCupertino(context);
    final colors = theme.colorScheme;
    final red = ios
        ? CupertinoColors.systemRed.resolveFrom(context)
        : colors.error;
    final blue = ios
        ? CupertinoColors.systemBlue.resolveFrom(context)
        : colors.primary;
    final neutral = ios
        ? CupertinoColors.secondaryLabel.resolveFrom(context)
        : colors.onSurfaceVariant;
    final fill = ios
        ? CupertinoColors.tertiarySystemFill.resolveFrom(context)
        : colors.surfaceContainerHighest;
    final elapsed = _clock.elapsed > _limit ? _limit : _clock.elapsed;
    final canSend = _recording && elapsed.inSeconds >= 1;
    final timer = Text(
      '${voiceTime(elapsed)} / ${voiceTime(_limit)}',
      maxLines: 1,
      style: theme.textTheme.bodySmall?.copyWith(
        color: _recording ? red : neutral,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: ColoredBox(
          color: fill,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            child: Row(
              key: const ValueKey('voice-recording-bar'),
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _control(
                  key: 'voice-cancel',
                  label: s.cancel,
                  icon: ios ? CupertinoIcons.xmark : Icons.close_rounded,
                  color: neutral,
                  onPressed: _finishing ? null : _close,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final compact =
                            constraints.maxWidth <
                            128 *
                                MediaQuery.textScalerOf(context).scale(12) /
                                12;
                        return Row(
                          children: [
                            if (!compact) ...[
                              Expanded(
                                child: SizedBox(
                                  height: 24,
                                  child: _recording
                                      ? CustomPaint(
                                          painter: _RecordingWave(
                                            red,
                                            elapsed.inMilliseconds /
                                                _limit.inMilliseconds,
                                          ),
                                        )
                                      : const Center(
                                          child: SizedBox.square(
                                            dimension: 18,
                                            child:
                                                PlatformCircularProgressIndicator(),
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              timer,
                            ] else
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: _starting || _finishing
                                      ? const SizedBox.square(
                                          dimension: 18,
                                          child:
                                              PlatformCircularProgressIndicator(),
                                        )
                                      : timer,
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                _control(
                  key: 'voice-stop',
                  label: s.voiceStop,
                  icon: ios ? CupertinoIcons.stop_fill : Icons.stop_rounded,
                  color: red,
                  onPressed: _recording ? () => _finish() : null,
                ),
                if (widget.onSend != null)
                  _control(
                    key: 'voice-send',
                    label: s.send,
                    icon: ios ? CupertinoIcons.arrow_up : Icons.send_rounded,
                    color: ios ? CupertinoColors.white : colors.onPrimary,
                    fill: canSend ? blue : neutral.withValues(alpha: .18),
                    onPressed: canSend ? () => _finish(send: true) : null,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecordingWave extends CustomPainter {
  const _RecordingWave(this.color, this.progress);

  final Color color;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const pitch = 4.0;
    final count = (size.width / pitch).floor();
    final pen = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < count; i++) {
      final fraction = i / count;
      final wave = math.sin(i * 0.71);
      final height = 2 + 8 * wave * wave;
      pen.color = color.withValues(alpha: fraction <= progress ? 1 : 0.25);
      final x = pitch / 2 + i * pitch;
      canvas.drawLine(
        Offset(x, size.height / 2 - height),
        Offset(x, size.height / 2 + height),
        pen,
      );
    }
  }

  @override
  bool shouldRepaint(_RecordingWave oldDelegate) =>
      color != oldDelegate.color || progress != oldDelegate.progress;
}
