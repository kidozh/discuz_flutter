import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../generated/l10n.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import '../utility/forum_voice.dart';

/// One playback control shared by forum attachments, audio embeds and previews.
class ForumVoiceMessage extends StatefulWidget {
  const ForumVoiceMessage({
    required this.load,
    this.durationHint,
    this.localFile,
    this.foreground,
    this.save,
    super.key,
  });

  final Future<File> Function()? load;
  final File? localFile;
  final Duration? durationHint;
  final Color? foreground;
  final VoidCallback? save;

  static Future<void> pausePlayback() async {
    final previous = _ForumVoiceMessageState.active;
    _ForumVoiceMessageState.active = null;
    await previous?.player?.pause();
  }

  @override
  State<ForumVoiceMessage> createState() => _ForumVoiceMessageState();
}

class _ForumVoiceMessageState extends State<ForumVoiceMessage> {
  static _ForumVoiceMessageState? active;

  AudioPlayer? player;
  File? downloaded;
  Duration? duration;
  bool loading = false;
  bool failed = false;
  bool loaded = false;

  Future<void> _toggle() async {
    if (loading) return;
    if (player?.playing == true &&
        player?.processingState != ProcessingState.completed) {
      if (active == this) active = null;
      await player?.pause();
      return;
    }
    final previous = active;
    active = this;
    setState(() {
      loading = !loaded;
      failed = false;
    });
    try {
      if (previous != this) await previous?.player?.pause();
      if (!mounted || active != this) return;
      final current = player ??= AudioPlayer();
      if (!loaded) {
        final file = widget.localFile ?? await widget.load!();
        if (widget.localFile == null) {
          if (!mounted) {
            await _delete(file);
            return;
          }
          downloaded = file;
        }
        duration = await current.setFilePath(file.path);
        loaded = true;
      }
      if (!mounted || active != this) return;
      if (current.processingState == ProcessingState.completed) {
        await current.seek(Duration.zero);
      }
      if (!mounted || active != this) return;
      setState(() => loading = false);
      await current.play();
    } catch (_) {
      if (active == this) active = null;
      final file = downloaded;
      downloaded = null;
      if (file != null) await _delete(file);
      loaded = false;
      if (mounted) setState(() => failed = true);
    } finally {
      if (mounted && loading) setState(() => loading = false);
    }
  }

  static Future<void> _delete(File file) async {
    try {
      await file.parent.delete(recursive: true);
    } on FileSystemException {
      // Playback downloads are disposable cache files.
    }
  }

  @override
  void dispose() {
    if (active == this) active = null;
    final current = player;
    final file = downloaded;
    unawaited(() async {
      await current?.dispose();
      if (file != null) await _delete(file);
    }());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final ios = isCupertino(context);
    final background = widget.foreground != null
        ? widget.foreground!.withValues(alpha: 0.12)
        : ios
        ? CupertinoColors.tertiarySystemFill.resolveFrom(context)
        : colors.secondaryContainer;
    final foreground =
        widget.foreground ??
        (ios ? colors.onSurface : colors.onSecondaryContainer);
    final seconds = (duration ?? widget.durationHint)?.inSeconds ?? 0;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: SizedBox(
        width:
            144.0 + seconds.clamp(0, 60) * 1.5 + (widget.save == null ? 0 : 44),
        child: Row(
          children: [
            Flexible(
              child: StreamBuilder<PlayerState>(
                stream: player?.playerStateStream,
                builder: (context, state) {
                  final finished =
                      state.data?.processingState == ProcessingState.completed;
                  final playing = state.data?.playing == true && !finished;
                  return StreamBuilder<Duration>(
                    stream: player?.positionStream,
                    builder: (context, position) {
                      final strings = S.of(context);
                      final length = duration ?? widget.durationHint;
                      final count = length == null ? '–:–' : voiceTime(length);
                      final action = playing
                          ? strings.voicePause
                          : strings.voicePlay;
                      final progress =
                          length == null ||
                              length.inMilliseconds == 0 ||
                              finished
                          ? 0.0
                          : ((position.data?.inMilliseconds ?? 0) /
                                    length.inMilliseconds)
                                .clamp(0.0, 1.0);
                      final radius = BorderRadius.circular(ios ? 22 : 16);
                      final content = ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 48),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Row(
                            children: [
                              if (loading)
                                const SizedBox.square(
                                  dimension: 20,
                                  child: PlatformCircularProgressIndicator(),
                                )
                              else
                                Icon(
                                  failed
                                      ? PlatformIcons(context).error
                                      : playing
                                      ? ios
                                            ? CupertinoIcons.pause_fill
                                            : Icons.pause_rounded
                                      : ios
                                      ? CupertinoIcons.play_fill
                                      : Icons.play_arrow_rounded,
                                  size: 21,
                                  color: foreground,
                                ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: failed
                                    ? Text(
                                        strings.voicePlaybackFailed,
                                        style: TextStyle(
                                          color: foreground,
                                          fontSize: 12,
                                        ),
                                      )
                                    : SizedBox(
                                        height: 20,
                                        child: CustomPaint(
                                          painter: _VoiceProgress(
                                            foreground,
                                            progress,
                                            Directionality.of(context),
                                          ),
                                        ),
                                      ),
                              ),
                              if (!failed) ...[
                                const SizedBox(width: 8),
                                Text(
                                  count,
                                  style: TextStyle(
                                    color: foreground,
                                    fontSize: 13,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                      return Semantics(
                        label:
                            '${strings.voiceMessage}, $count, ${failed ? strings.retry : action}',
                        button: true,
                        onTap: loading ? null : _toggle,
                        excludeSemantics: true,
                        child: ios
                            ? DecoratedBox(
                                decoration: BoxDecoration(
                                  color: background,
                                  borderRadius: radius,
                                ),
                                child: CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: _toggle,
                                  child: content,
                                ),
                              )
                            : Material(
                                color: background,
                                borderRadius: radius,
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(onTap: _toggle, child: content),
                              ),
                      );
                    },
                  );
                },
              ),
            ),
            if (widget.save != null)
              PlatformIconButton(
                onPressed: widget.save,
                liquidGlassSymbol: 'arrow.down.to.line',
                icon: Icon(
                  PlatformIcons(context).download,
                  size: 17,
                  semanticLabel: S.of(context).downloadAttachment,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _VoiceProgress extends CustomPainter {
  const _VoiceProgress(this.color, this.progress, this.direction);

  final Color color;
  final double progress;
  final TextDirection direction;

  @override
  void paint(Canvas canvas, Size size) {
    const heights = [
      4.0,
      8.0,
      13.0,
      17.0,
      9.0,
      14.0,
      19.0,
      11.0,
      16.0,
      10.0,
      6.0,
      12.0,
      8.0,
      4.0,
    ];
    final count = (size.width / 4).floor().clamp(0, 26);
    if (count == 0) return;
    final step = size.width / count;
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2;
    for (var index = 0; index < count; index++) {
      final offset = (index + 0.5) * step;
      final x = direction == TextDirection.ltr ? offset : size.width - offset;
      final halfHeight = heights[index % heights.length] / 2;
      paint.color = color.withValues(
        alpha: offset / size.width <= progress ? 1 : 0.48,
      );
      canvas.drawLine(
        Offset(x, size.height / 2 - halfHeight),
        Offset(x, size.height / 2 + halfHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_VoiceProgress oldDelegate) =>
      color != oldDelegate.color ||
      progress != oldDelegate.progress ||
      direction != oldDelegate.direction;
}
