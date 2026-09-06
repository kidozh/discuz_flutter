import 'dart:math' as math;

import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/reply_submission_controller.dart';
import 'package:discuz_flutter/widget/PostTextField.dart';
import 'package:flutter/cupertino.dart';

export 'package:discuz_flutter/utility/reply_submission_controller.dart'
    show SendReplyStatus;

/// Captures the actual body height after the scaffold consumes keyboard insets.
class CupertinoComposerViewport extends StatelessWidget {
  final Widget child;
  const CupertinoComposerViewport({required this.child, super.key});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => _ComposerViewportHeight(
          height: constraints.maxHeight,
          keyboardInset:
              MediaQueryData.fromView(View.of(context)).viewInsets.bottom,
          child: child,
        ),
      );
}

class _ComposerViewportHeight extends InheritedWidget {
  final double height;
  final double keyboardInset;
  const _ComposerViewportHeight(
      {required this.height,
      required this.keyboardInset,
      required super.child});

  @override
  bool updateShouldNotify(_ComposerViewportHeight oldWidget) =>
      height != oldWidget.height || keyboardInset != oldWidget.keyboardInset;
}

/// Do not stack an accessory panel on top of a keyboard that is still closing.
/// Removing the outgoing animation also avoids overlap when reopening it.
class CupertinoKeyboardAccessory extends StatelessWidget {
  final bool enabled;
  final Widget child;
  const CupertinoKeyboardAccessory(
      {required this.enabled, required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final viewport =
        context.dependOnInheritedWidgetOfExactType<_ComposerViewportHeight>();
    final inset =
        viewport?.keyboardInset ?? MediaQuery.viewInsetsOf(context).bottom;
    return enabled && inset > 0 ? const SizedBox.shrink() : child;
  }
}

/// Classic Cupertino message composer. The page owns drafts, panels and sending.
class CupertinoThreadReplyComposer extends StatelessWidget {
  final Discuz discuz;
  final TextEditingController controller;
  final FocusNode focusNode;
  final Widget replyTarget;
  final bool panelVisible;
  final SendReplyStatus sendStatus;
  final VoidCallback onTogglePanel;
  final VoidCallback onSend;

  const CupertinoThreadReplyComposer({
    required this.discuz,
    required this.controller,
    required this.focusNode,
    required this.replyTarget,
    required this.panelVisible,
    required this.sendStatus,
    required this.onTogglePanel,
    required this.onSend,
    super.key,
  });

  @override
  Widget build(BuildContext context) => CupertinoMessageComposer(
        controller: controller,
        editor: PostTextField(discuz, controller,
            focusNode: focusNode, embeddedInComposer: true),
        replyTarget: replyTarget,
        panelVisible: panelVisible,
        sendStatus: sendStatus,
        onTogglePanel: onTogglePanel,
        onSend: onSend,
      );
}

class CupertinoPrivateMessageComposer extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool panelVisible;
  final bool sending;
  final bool canSend;
  final VoidCallback onTogglePanel;
  final VoidCallback onSend;

  const CupertinoPrivateMessageComposer({
    required this.controller,
    required this.focusNode,
    required this.panelVisible,
    required this.sending,
    required this.canSend,
    required this.onTogglePanel,
    required this.onSend,
    super.key,
  });

  @override
  Widget build(BuildContext context) => CupertinoMessageComposer(
        controller: controller,
        editor: CupertinoTextField(
          key: const ValueKey('cupertino-private-message-input'),
          controller: controller,
          focusNode: focusNode,
          decoration: null,
          padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 0, 10),
          placeholder: S.of(context).sendReplyHint,
          minLines: 1,
          maxLines: 5,
          textInputAction: TextInputAction.newline,
          onSubmitted: (_) {
            if (canSend) onSend();
          },
          keyboardAppearance: CupertinoTheme.brightnessOf(context),
          cursorColor: CupertinoColors.systemBlue.resolveFrom(context),
        ),
        panelVisible: panelVisible,
        sendStatus: sending ? SendReplyStatus.loading : SendReplyStatus.idle,
        enabled: canSend,
        onTogglePanel: onTogglePanel,
        onSend: onSend,
      );
}

/// Shared iMessage-shaped chrome; each page keeps its own editor and protocol.
class CupertinoMessageComposer extends StatelessWidget {
  final TextEditingController controller;
  final Widget editor;
  final Widget replyTarget;
  final bool panelVisible;
  final SendReplyStatus sendStatus;
  final bool enabled;
  final VoidCallback onTogglePanel;
  final VoidCallback onSend;

  const CupertinoMessageComposer({
    required this.controller,
    required this.editor,
    this.replyTarget = const SizedBox.shrink(),
    required this.panelVisible,
    required this.sendStatus,
    this.enabled = true,
    required this.onTogglePanel,
    required this.onSend,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final viewport = context
        .dependOnInheritedWidgetOfExactType<_ComposerViewportHeight>()
        ?.height;
    final availableHeight = viewport != null && viewport.isFinite
        ? viewport
        : media.size.height -
            MediaQueryData.fromView(View.of(context)).viewInsets.bottom -
            media.padding.top;
    final bottomPadding = panelVisible ? 0.0 : media.padding.bottom;
    final line = TextPainter(
      text: TextSpan(
          text: 'M', style: CupertinoTheme.of(context).textTheme.textStyle),
      textDirection: Directionality.of(context),
      textScaler: media.textScaler,
    )..layout();
    // Include the editor's 20pt padding plus a rounding allowance for the caret.
    // An exactly one-line viewport can defeat the editor's reveal calculation.
    final minimumEditorHeight =
        math.max(44.0, line.preferredLineHeight.ceilToDouble() + 22);
    line.dispose();
    // Keep at least one complete line at accessibility sizes; the quote gets
    // the remaining space and can scroll independently on very small screens.
    final maxContentHeight = math.max(
        44.0,
        math.min(
          availableHeight - bottomPadding - 10,
          math.max(math.min(280.0, availableHeight * .55) - bottomPadding - 10,
              minimumEditorHeight + 54),
        ));
    return ColoredBox(
      color: CupertinoColors.systemBackground.resolveFrom(context),
      child: SafeArea(
        top: false,
        bottom: !panelVisible,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 5, 12, 5),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxContentHeight),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                      maxHeight:
                          math.max(0, maxContentHeight - minimumEditorHeight)),
                  child:
                      SingleChildScrollView(primary: false, child: replyTarget),
                ),
                Flexible(
                    child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CupertinoButton(
                      key: const ValueKey('cupertino-composer-add'),
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(44, 44),
                      onPressed: onTogglePanel,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: CupertinoColors.tertiarySystemFill
                              .resolveFrom(context),
                        ),
                        child: Icon(
                          panelVisible
                              ? CupertinoIcons.keyboard
                              : CupertinoIcons.add,
                          size: panelVisible ? 20 : 24,
                          color: CupertinoColors.secondaryLabel
                              .resolveFrom(context),
                          semanticLabel: panelVisible
                              ? S.of(context).showKeyboardTooltip
                              : S.of(context).extraFuncButtonTooltip,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: DecoratedBox(
                        key: const ValueKey('cupertino-composer-bubble'),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemBackground
                              .resolveFrom(context),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: CupertinoColors.systemGrey4
                                .resolveFrom(context),
                            width: 1 / MediaQuery.devicePixelRatioOf(context),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(child: editor),
                            // Only the send affordance listens to each keystroke.
                            ValueListenableBuilder<TextEditingValue>(
                              valueListenable: controller,
                              builder: (context, value, _) => _sendButton(
                                  context,
                                  hasText: value.text.isNotEmpty),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sendButton(BuildContext context, {required bool hasText}) {
    final busy = sendStatus == SendReplyStatus.loading;
    final succeeded = sendStatus == SendReplyStatus.success;
    final failed = sendStatus == SendReplyStatus.fail;
    final enabled = this.enabled && hasText && !busy && !succeeded;
    final label = busy
        ? S.of(context).progressButtonReplySending
        : failed
            ? S.of(context).retry
            : succeeded
                ? S.of(context).progressButtonReplySuccess
                : S.of(context).send;
    final color = failed
        ? CupertinoColors.systemRed.resolveFrom(context)
        : enabled || succeeded
            ? CupertinoColors.systemBlue.resolveFrom(context)
            : CupertinoColors.systemGrey4.resolveFrom(context);
    return Semantics(
      label: label,
      value: failed ? S.of(context).progressButtonReplyFailed : null,
      liveRegion: busy || failed || succeeded,
      child: CupertinoButton(
        key: const ValueKey('cupertino-composer-send'),
        padding: EdgeInsets.zero,
        minimumSize: const Size(44, 44),
        onPressed: enabled ? onSend : null,
        child: Container(
          key: const ValueKey('cupertino-composer-send-circle'),
          width: 30,
          height: 30,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: busy
              ? const CupertinoActivityIndicator(radius: 8)
              : Icon(
                  succeeded
                      ? CupertinoIcons.check_mark
                      : failed
                          ? CupertinoIcons.arrow_clockwise
                          : CupertinoIcons.arrow_up,
                  size: 21,
                  color: enabled || succeeded
                      ? CupertinoColors.white
                      : CupertinoColors.secondaryLabel.resolveFrom(context),
                ),
        ),
      ),
    );
  }
}
