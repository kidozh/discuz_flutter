import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A clear thumbnail keeps the composition readable without decoding a
/// full-size upload for every inline image.
class PostImagePreview extends StatefulWidget {
  final String? localPath;
  final String? url;
  final int number;
  final bool compact;
  final VoidCallback? onRemove;

  const PostImagePreview({
    super.key,
    this.localPath,
    this.url,
    required this.number,
    this.compact = false,
    this.onRemove,
  });

  @override
  State<PostImagePreview> createState() => _PostImagePreviewState();
}

class _PostImagePreviewState extends State<PostImagePreview> {
  ImageProvider? _image;

  @override
  void initState() {
    super.initState();
    _resolveImage();
  }

  @override
  void didUpdateWidget(PostImagePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.localPath != widget.localPath ||
        oldWidget.url != widget.url) {
      _resolveImage();
    }
  }

  void _resolveImage() {
    _image = null;
    final path = widget.localPath;
    if (!kIsWeb && path != null && path.isNotEmpty) {
      final file = File(path);
      if (file.existsSync()) _image = FileImage(file);
    }
    final uri = Uri.tryParse(widget.url ?? '');
    if (_image == null &&
        uri != null &&
        ['http', 'https'].contains(uri.scheme) &&
        uri.host.isNotEmpty) {
      _image = CachedNetworkImageProvider(uri.toString());
    }
    if (_image != null) _image = ResizeImage.resizeIfNeeded(384, null, _image!);
  }

  @override
  Widget build(BuildContext context) {
    final apple = isCupertino(context);
    final colors = Theme.of(context).colorScheme;
    final fill = apple
        ? CupertinoColors.tertiarySystemFill.resolveFrom(context)
        : colors.surfaceContainerHighest;
    final foreground = apple
        ? CupertinoColors.secondaryLabel.resolveFrom(context)
        : colors.onSurfaceVariant;
    final outline = apple
        ? CupertinoColors.separator.resolveFrom(context)
        : colors.outlineVariant;
    final imageBackground = apple
        ? CupertinoColors.secondarySystemBackground.resolveFrom(context)
        : colors.surfaceContainerHighest;
    final label = S.of(context).composerImageLabel(widget.number);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 2,
        vertical: widget.compact ? 2 : 4,
      ),
      child: Semantics(
        container: true,
        label: label,
        child: Container(
          width: widget.compact ? 96 : 108,
          height: widget.compact ? 44 : 72,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: fill,
            border: Border.all(color: outline),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: Icon(
                  apple ? CupertinoIcons.photo : Icons.image_outlined,
                  size: 28,
                  color: foreground,
                ),
              ),
              if (_image != null)
                Image(
                  image: _image!,
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                  frameBuilder: (_, child, frame, wasSynchronouslyLoaded) =>
                      frame != null || wasSynchronouslyLoaded
                      ? ColoredBox(color: imageBackground, child: child)
                      : const SizedBox.shrink(),
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              PositionedDirectional(
                start: 6,
                bottom: 6,
                child: ExcludeSemantics(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: .55),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      label,
                      maxLines: 1,
                      textScaler: TextScaler.noScaling,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
              if (widget.onRemove != null)
                PositionedDirectional(
                  top: 0,
                  end: 0,
                  child: Tooltip(
                    message: S.of(context).removeComposerImage(widget.number),
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: apple
                          ? CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: widget.onRemove,
                              child: _removeIcon(),
                            )
                          : IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: widget.onRemove,
                              icon: _removeIcon(),
                            ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _removeIcon() => Container(
    width: 24,
    height: 24,
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: .55),
      shape: BoxShape.circle,
    ),
    child: const Icon(Icons.close, size: 16, color: Colors.white),
  );
}
