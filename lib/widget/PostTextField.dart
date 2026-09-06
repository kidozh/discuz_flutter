import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/Smiley.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PostTextField extends StatefulWidget {
  final Discuz _discuz;
  final TextEditingController _controller;
  final FocusNode focusNode;
  final bool? expanded;
  final bool embeddedInComposer;

  PostTextField(this._discuz, this._controller,
      {required this.focusNode,
      this.expanded,
      this.embeddedInComposer = false});

  @override
  PostTextFieldState createState() {
    return PostTextFieldState(this._discuz, this._controller,
        focusNode: focusNode,
        expanded: this.expanded,
        embeddedInComposer: embeddedInComposer);
  }
}

class PostTextFieldState extends State<PostTextField> {
  final TextEditingController _controller;

  final Discuz _discuz;
  final FocusNode focusNode;
  final bool? expanded;
  final bool embeddedInComposer;

  PostTextFieldState(this._discuz, this._controller,
      {required this.focusNode,
      this.expanded,
      this.embeddedInComposer = false});

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
      specialTextSpanBuilder: PostSpecialTextSpanBuilder(_discuz),
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
      maxLines: expanded == null
          ? (classicCupertino && embeddedInComposer ? 5 : 3)
          : null,
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
                constraints:
                    BoxConstraints(minHeight: embeddedInComposer ? 44 : 36),
                // The message composer owns the single bubble around both the
                // editable text and send button; never draw a second input box.
                decoration: embeddedInComposer
                    ? null
                    : BoxDecoration(
                        color: CupertinoColors.systemBackground
                            .resolveFrom(context),
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
          _discuz.baseURL + "/static/image/smiley/" + smiley.relativePath),
      imageWidth: 20,
      imageHeight: 20,
      start: this.start,
      actualText: toString(),
    );
  }
}

class AttachImageText extends SpecialText {
  Discuz _discuz;
  static String attachStartFlag = "[attachimg]";
  static String attachEndFlag = "[/attachimg]";
  int start;

  AttachImageText(this._discuz, TextStyle textStyle, {required this.start})
      : super(AttachImageText.attachStartFlag, AttachImageText.attachEndFlag,
            textStyle);

  get aid => getContent();

  @override
  InlineSpan finishText() {
    return BackgroundTextSpan(
      text: " 📃 ${aid} ",
      background: Paint()..color = Colors.blue.withOpacity(0.15),
      actualText: toString(),
      start: start,
      style: TextStyle(color: Colors.blue),
    );
  }
}

class PostSpecialTextSpanBuilder extends SpecialTextSpanBuilder {
  Discuz _discuz;

  PostSpecialTextSpanBuilder(this._discuz);

  @override
  SpecialText? createSpecialText(String flag,
      {TextStyle? textStyle,
      SpecialTextGestureTapCallback? onTap,
      required int index}) {
    if (flag == "") {
      return null;
    } else {
      if (isStart(flag, AttachImageText.attachStartFlag)) {
        return AttachImageText(_discuz, textStyle!,
            start: index - (AttachImageText.attachStartFlag.length - 1));
      } else if (isStart(flag, SmileyText.smileyStartFlag)) {
        return SmileyText(_discuz, textStyle!,
            start: index - (SmileyText.smileyStartFlag.length - 1));
      } else {
        return null;
      }
    }
  }

  @override
  TextSpan build(String data,
      {TextStyle? textStyle, SpecialTextGestureTapCallback? onTap}) {
    if (kIsWeb) {
      return TextSpan(text: data, style: textStyle);
    }
    return super.build(data, textStyle: textStyle, onTap: onTap);
  }
}
