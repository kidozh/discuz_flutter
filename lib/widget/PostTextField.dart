import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/Smiley.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/utility/post_editor_controller.dart';
import 'package:discuz_flutter/widget/post_image_preview.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PostTextField extends StatefulWidget {
  final Discuz _discuz;
  final TextEditingController _controller;
  final FocusNode focusNode;
  final bool? expanded;
  final bool embeddedInComposer;

  PostTextField(
    this._discuz,
    this._controller, {
    required this.focusNode,
    this.expanded,
    this.embeddedInComposer = false,
    super.key,
  });

  @override
  PostTextFieldState createState() {
    return PostTextFieldState();
  }
}

class PostTextFieldState extends State<PostTextField> {
  TextEditingController get _controller => widget._controller;
  Discuz get _discuz => widget._discuz;
  FocusNode get focusNode => widget.focusNode;
  bool? get expanded => widget.expanded;
  bool get embeddedInComposer => widget.embeddedInComposer;

  TextSelection? _previousSelection;
  bool _correctingSelection = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_keepSelectionOutsideTokens);
    _previousSelection = _controller.selection;
  }

  @override
  void didUpdateWidget(PostTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget._controller != _controller) {
      oldWidget._controller.removeListener(_keepSelectionOutsideTokens);
      _controller.addListener(_keepSelectionOutsideTokens);
      _previousSelection = _controller.selection;
    }
  }

  void _keepSelectionOutsideTokens() {
    if (_correctingSelection) return;
    final value = _controller.value;
    final selection = postEditorSelection(
      value.text,
      value.selection,
      previous: _previousSelection,
    );
    final composing =
        PostEditorToken.inText(value.text).any(
          (token) =>
              value.composing.start < token.end &&
              value.composing.end > token.start,
        )
        ? TextRange.empty
        : value.composing;
    _previousSelection = selection;
    if (selection == value.selection && composing == value.composing) return;
    _correctingSelection = true;
    _controller.value = value.copyWith(
      selection: selection,
      composing: composing,
    );
    _correctingSelection = false;
  }

  @override
  void dispose() {
    _controller.removeListener(_keepSelectionOutsideTokens);
    super.dispose();
  }

  String? _imagePathFor(PostEditorToken token) {
    final controller = _controller;
    if (controller is PostEditorController) {
      final path = controller.imagePathFor(token.text);
      if (path != null) return path;
    }
    final box = AppDatabase.imageAttachmentBox;
    if (token.isAttachment && box != null && box.isOpen) {
      for (final attachment in box.values) {
        if (attachment.discuz == _discuz && attachment.aid == token.content) {
          return attachment.path;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final classicCupertino = visualStyle(context) == AppVisualStyle.cupertino;
    final glassSurface = usesAppleTranslucentSurface(context);
    final seamless = glassSurface || embeddedInComposer;
    final cupertinoTheme = CupertinoTheme.of(context);
    final cupertinoStyle = cupertinoTheme.textTheme.textStyle.copyWith(
      color: CupertinoColors.label.resolveFrom(context),
      fontSize: cupertinoTheme.textTheme.textStyle.fontSize ?? 17,
      textBaseline: TextBaseline.alphabetic,
    );
    final textField = ExtendedTextField(
      controller: _controller,
      specialTextSpanBuilder: PostSpecialTextSpanBuilder(
        _discuz,
        manageEdits: true,
        imagePathFor: _imagePathFor,
        onRemoveImage: (token) => removePostEditorImage(_controller, token),
        editingValue: () => _controller.value,
        compactImages: expanded == null,
      ),
      inputFormatters: const [PostEditorInputFormatter()],
      strutStyle: const StrutStyle(forceStrutHeight: false),
      selectionControls: classicCupertino
          ? cupertinoTextSelectionHandleControls
          : isCupertino(context)
          ? CupertinoTextSelectionControls()
          : MaterialTextSelectionControls(),
      style: classicCupertino ? cupertinoStyle : null,
      cursorColor: classicCupertino
          ? embeddedInComposer
                ? CupertinoColors.systemBlue.resolveFrom(context)
                : cupertinoTheme.primaryColor
          : null,
      cursorRadius: classicCupertino ? const Radius.circular(2) : null,
      cursorOpacityAnimates: classicCupertino ? true : null,
      keyboardAppearance: classicCupertino
          ? cupertinoTheme.brightness ?? Theme.of(context).brightness
          : null,
      extendedContextMenuBuilder: (context, editable) => classicCupertino
          ? CupertinoAdaptiveTextSelectionToolbar.buttonItems(
              anchors: editable.contextMenuAnchors,
              buttonItems: editable.contextMenuButtonItems,
            )
          : AdaptiveTextSelectionToolbar.buttonItems(
              anchors: editable.contextMenuAnchors,
              buttonItems: editable.contextMenuButtonItems,
            ),
      focusNode: focusNode,
      minLines: expanded == null ? 1 : null,
      maxLines: expanded == null ? 5 : null,
      expands: expanded == null ? false : true,
      decoration: classicCupertino
          ? null
          : InputDecoration(
              hintText: S.of(context).sendReplyHint,
              border: seamless ? InputBorder.none : null,
              enabledBorder: seamless ? InputBorder.none : null,
              focusedBorder: seamless ? InputBorder.none : null,
              contentPadding: seamless
                  ? const EdgeInsets.symmetric(horizontal: 14, vertical: 10)
                  : null,
            ),
    );

    if (classicCupertino) {
      // Keep ExtendedTextField's smiley / attachment spans and editing model.
      // Only replace the Material decorator with a Cupertino field surface.
      return Theme(
        data: Theme.of(context).copyWith(platform: TargetPlatform.iOS),
        child: Material(
          type: MaterialType.transparency,
          child: Semantics(
            label: S.of(context).sendReplyHint,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: focusNode.requestFocus,
              child: Container(
                key: const ValueKey('cupertino-post-input'),
                constraints: BoxConstraints(
                  minHeight: embeddedInComposer ? 44 : 36,
                ),
                // The message composer owns the single bubble around both the
                // editable text and send button; never draw a second input box.
                decoration: embeddedInComposer
                    ? null
                    : BoxDecoration(
                        color: CupertinoColors.systemBackground.resolveFrom(
                          context,
                        ),
                        border: Border.all(
                          color: CupertinoColors.separator.resolveFrom(context),
                          width: 1 / MediaQuery.devicePixelRatioOf(context),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                padding: embeddedInComposer
                    ? const EdgeInsetsDirectional.fromSTEB(12, 10, 0, 10)
                    : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Stack(
                  fit: expanded == null ? StackFit.loose : StackFit.expand,
                  children: [
                    PositionedDirectional(
                      start: 0,
                      end: 0,
                      top: 0,
                      child: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _controller,
                        builder: (context, value, _) => value.text.isNotEmpty
                            ? const SizedBox.shrink()
                            : ExcludeSemantics(
                                child: IgnorePointer(
                                  child: Text(
                                    S.of(context).sendReplyHint,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: cupertinoStyle.copyWith(
                                      color: CupertinoColors.placeholderText
                                          .resolveFrom(context),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                    textField,
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (!glassSurface || embeddedInComposer) return textField;
    final radius = BorderRadius.circular(expanded == null ? 18 : 22);
    return usesLiquidGlass(context)
        ? PlatformLiquidGlassSurface(borderRadius: radius, child: textField)
        : PlatformLiquidGlassCard(borderRadius: radius, child: textField);
  }
}

class SmileyText extends SpecialText {
  Discuz _discuz;
  static String smileyStartFlag = "[smiley]";
  static String smileyEndFlag = "[/smiley]";
  int start;

  SmileyText(this._discuz, TextStyle textStyle, {required this.start})
    : super(SmileyText.smileyStartFlag, SmileyText.smileyEndFlag, textStyle);

  get smiley => Smiley.fromJson(jsonDecode(getContent()));

  get smileyCode {
    Smiley smileyObj = smiley;
    return smileyObj.code
        .replaceAll(r"\:", ":")
        .replaceAll(r"\{", "{")
        .replaceAll(r"\}", "}");
  }

  @override
  InlineSpan finishText() {
    return ImageSpan(
      CachedNetworkImageProvider(
        _discuz.baseURL + "/static/image/smiley/" + smiley.relativePath,
      ),
      imageWidth: 20,
      imageHeight: 20,
      start: this.start,
      actualText: toString(),
    );
  }
}

class PostSpecialTextSpanBuilder extends SpecialTextSpanBuilder {
  final Discuz _discuz;
  final bool manageEdits;
  final String? Function(PostEditorToken token)? imagePathFor;
  final void Function(PostEditorToken token)? onRemoveImage;
  final TextEditingValue Function()? editingValue;
  final bool compactImages;
  bool _builtComposingPrefix = false;

  PostSpecialTextSpanBuilder(
    this._discuz, {
    this.manageEdits = false,
    this.imagePathFor,
    this.onRemoveImage,
    this.editingValue,
    this.compactImages = false,
  });

  @override
  SpecialText? createSpecialText(
    String flag, {
    TextStyle? textStyle,
    SpecialTextGestureTapCallback? onTap,
    required int index,
  }) => null;

  @override
  TextSpan build(
    String data, {
    TextStyle? textStyle,
    SpecialTextGestureTapCallback? onTap,
  }) {
    final spans = <InlineSpan>[];
    final value = editingValue?.call();
    int sourceOffset = 0;
    // ExtendedTextField builds the prefix and suffix separately while an IME
    // is composing. Keep image ordinals and remove actions in document offsets.
    if (value != null && value.text == data) {
      _builtComposingPrefix = false;
    } else if (value != null && value.isComposingRangeValid) {
      final before = value.composing.textBefore(value.text);
      final after = value.composing.textAfter(value.text);
      if (data == after && (data != before || _builtComposingPrefix)) {
        sourceOffset = value.composing.end;
        _builtComposingPrefix = false;
      } else if (data == before) {
        _builtComposingPrefix = true;
      }
    }
    int offset = 0;
    int imageNumber = sourceOffset == 0
        ? 0
        : PostEditorToken.inText(value!.text.substring(0, sourceOffset))
              .where((token) => !token.isSmiley)
              .length;
    for (final localToken in PostEditorToken.inText(data)) {
      final token = PostEditorToken(
        localToken.start + sourceOffset,
        localToken.text,
      );
      if (localToken.start > offset) {
        spans.add(TextSpan(text: data.substring(offset, localToken.start)));
      }
      if (token.isSmiley) {
        try {
          final smiley = Smiley.fromJson(jsonDecode(token.content));
          final span = ImageSpan(
            CachedNetworkImageProvider(
              '${_discuz.baseURL}/static/image/smiley/${smiley.relativePath}',
            ),
            imageWidth: 20,
            imageHeight: 20,
            start: token.start,
            actualText: token.text,
          );
          spans.add(
            manageEdits
                ? ExtendedWidgetSpan(
                    child: span.child,
                    start: token.start,
                    actualText: token.text,
                    alignment: PlaceholderAlignment.middle,
                    deleteAll: false,
                  )
                : span,
          );
        } on FormatException {
          spans.add(TextSpan(text: token.text));
        } on TypeError {
          spans.add(TextSpan(text: token.text));
        }
      } else {
        imageNumber++;
        spans.add(
          ExtendedWidgetSpan(
            start: token.start,
            actualText: token.text,
            alignment: PlaceholderAlignment.bottom,
            style: const TextStyle(height: 1),
            // The formatter handles backward/forward deletion and replacements.
            deleteAll: !manageEdits,
            child: PostImagePreview(
              compact: compactImages,
              localPath: imagePathFor?.call(token),
              url: token.isAttachment ? null : token.content.trim(),
              number: imageNumber,
              onRemove: onRemoveImage == null
                  ? null
                  : () => onRemoveImage!(token),
            ),
          ),
        );
      }
      offset = localToken.end;
    }
    if (offset < data.length) {
      spans.add(TextSpan(text: data.substring(offset)));
    }
    return TextSpan(children: spans, style: textStyle);
  }
}
