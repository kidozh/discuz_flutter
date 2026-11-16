import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:almanacinc_record_mp3/almanacinc_record_mp3.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

/// Mounted in place of the composer controls while the microphone is active.
/// A completed recording moves straight into the editor as a playable draft.
class ForumVoiceRecorder extends StatefulWidget {
  const ForumVoiceRecorder({
    required this.options,
    required this.onRecorded,
    required this.onClosed,
    this.onSend,
    super.key,
  });

  final ForumVoiceOptions options;
  // Return true to keep the temporary file for the lifetime of the editor.
  final Future<bool> Function(RecordedForumVoice) onRecorded;
  final VoidCallback onClosed;
  final VoidCallback? onSend;

  @override
  State<ForumVoiceRecorder> createState() => _ForumVoiceRecorderState();
}

class _ForumVoiceRecorderState extends State<ForumVoiceRecorder>
    with WidgetsBindingObserver {
  final _mp3 = AlmanacRecordMp3.instance;
  final _clock = Stopwatch();
  AudioRecorder? _systemRecorder;
  Directory? _directory;
  Timer? _ticker;
  Future<void>? _operation;
  bool _recording = false;
  bool _interrupted = false;
  bool _finishing = false;

  Duration get _limit => Duration(seconds: widget.options.maxSeconds);
  ForumVoiceFormat get _format => widget.options.format;

  Future<String?> _stopRecorder() =>
      _format == ForumVoiceFormat.mp3 ? _mp3.stop() : _systemRecorder!.stop();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _operation = _start();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.hidden &&
        state != AppLifecycleState.paused) {
      return;
    }
    _interrupted = true;
    if (_recording) _finish(discard: _clock.elapsed.inSeconds < 1);
  }

  Future<void> _start() async {
    final s = S.of(context);
    try {
      await ForumVoiceMessage.pausePlayback();
      if (!mounted || _interrupted) return;
      final native = _format == ForumVoiceFormat.mp3
          ? null
          : _systemRecorder = AudioRecorder();
      if (!await (native?.hasPermission() ?? _mp3.hasPermission())) {
        if (mounted)
          unawaited(EasyLoading.showError(s.voiceMicrophonePermission));
        return;
      }
      if (!mounted || _interrupted) return;
      final folder = _directory = await (await getTemporaryDirectory())
          .createTemp('voice-');
      if (!mounted || _interrupted) return;
      final path = '${folder.path}/recording.${_format.name}';
      if (native == null) {
        final started = await _mp3.start(
          path,
          sampleRate: forumVoiceSampleRate,
          bitRate: forumVoiceBitRate,
          onError: (_) {
            if (mounted && _recording) _finish(failed: true);
          },
        );
        if (!started) throw StateError('Recording did not start');
      } else {
        await native.start(
          RecordConfig(
            encoder: _format == ForumVoiceFormat.wav
                ? AudioEncoder.wav
                : AudioEncoder.aacLc,
            sampleRate: forumVoiceSampleRate,
            bitRate: forumVoiceBitRate * 1000,
            numChannels: 1,
          ),
          path: path,
        );
      }
      if (!mounted || _interrupted) {
        await _stopRecorder();
        return;
      }
      _clock.start();
      setState(() => _recording = true);
      _ticker = Timer.periodic(const Duration(milliseconds: 90), (_) {
        if (_clock.elapsed >= _limit) {
          _finish();
        } else {
          setState(() {});
        }
      });
    } catch (_) {
      if (mounted) unawaited(EasyLoading.showError(s.voiceRecordingFailed));
    } finally {
      if (!_recording && mounted) widget.onClosed();
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
    bool saved = false;
    try {
      final path = await _stopRecorder();
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
          _format,
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
      if (mounted) {
        widget.onClosed();
        if (saved && send) widget.onSend?.call();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    final operation = _operation;
    unawaited(() async {
      try {
        await operation;
        if (_recording) await _stopRecorder();
      } finally {
        await _systemRecorder?.dispose();
        try {
          await _directory?.delete(recursive: true);
        } on FileSystemException {
          // Temporary files may already have been removed by the system.
        }
      }
    }());
    super.dispose();
  }

  Widget _button(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    Color? fill,
    VoidCallback? onPressed,
  }) {
    final image = Icon(
      icon,
      size: 16,
      color: onPressed == null ? Theme.of(context).disabledColor : color,
      semanticLabel: label,
    );
    final contents = Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
      child: image,
    );
    return isCupertino(context)
        ? CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: const Size(44, 44),
            onPressed: onPressed,
            child: contents,
          )
        : IconButton(
            onPressed: onPressed,
            padding: EdgeInsets.zero,
            icon: contents,
          );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final icons = PlatformIcons(context);
    final ios = isCupertino(context);
    final red = ios
        ? CupertinoColors.systemRed.resolveFrom(context)
        : theme.colorScheme.error;
    final blue = ios
        ? CupertinoColors.systemBlue.resolveFrom(context)
        : theme.colorScheme.primary;
    final neutral = ios
        ? CupertinoColors.secondaryLabel.resolveFrom(context)
        : theme.colorScheme.onSurfaceVariant;
    final fill = ios
        ? CupertinoColors.tertiarySystemFill.resolveFrom(context)
        : theme.colorScheme.surfaceContainerHighest;
    final elapsed = _clock.elapsed > _limit ? _limit : _clock.elapsed;
    return Row(
      children: [
        _button(
          context,
          label: s.cancel,
          icon: icons.pick(Icons.close_rounded, CupertinoIcons.xmark),
          color: neutral,
          fill: fill,
          onPressed: _recording ? () => _finish(discard: true) : null,
        ),
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                if (_recording)
                  Expanded(
                    child: SizedBox(
                      height: 24,
                      child: CustomPaint(
                        painter: _RecordingWave(
                          red,
                          elapsed.inMilliseconds / _limit.inMilliseconds,
                        ),
                      ),
                    ),
                  )
                else
                  const Expanded(
                    child: Center(child: PlatformCircularProgressIndicator()),
                  ),
                const SizedBox(width: 8),
                Semantics(
                  label: '${voiceTime(elapsed)} / ${voiceTime(_limit)}',
                  excludeSemantics: true,
                  child: Text(
                    voiceTime(elapsed),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _recording ? red : neutral,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                _button(
                  context,
                  label: s.voiceStop,
                  icon: icons.pick(
                    Icons.stop_rounded,
                    CupertinoIcons.stop_fill,
                  ),
                  color: red,
                  onPressed: _recording ? _finish : null,
                ),
              ],
            ),
          ),
        ),
        if (widget.onSend != null)
          _button(
            context,
            label: s.send,
            icon: icons.pick(
              Icons.arrow_upward_rounded,
              CupertinoIcons.arrow_up,
            ),
            color: Colors.white,
            fill: _recording && elapsed.inSeconds >= 1 ? blue : fill,
            onPressed: _recording && elapsed.inSeconds >= 1
                ? () => _finish(send: true)
                : null,
          ),
      ],
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
