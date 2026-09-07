import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:flutter/material.dart';

/// Shared appearance only; each page still owns its composer layout and state.
class MessageComposerSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final BorderRadius borderRadius;

  const MessageComposerSurface({
    required this.child,
    this.margin,
    this.padding,
    required this.borderRadius,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (isCupertino(context)) {
      return PlatformLiquidGlassCard(
        margin: margin,
        padding: padding,
        borderRadius: borderRadius,
        child: child,
      );
    }
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Material(
        color: colors.surfaceContainer,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: theme.copyWith(
            iconTheme: theme.iconTheme.copyWith(color: colors.onSurfaceVariant),
            inputDecorationTheme: theme.inputDecorationTheme.copyWith(
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
        ),
      ),
    );
  }
}

class MaterialMessageSendButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const MaterialMessageSendButton({required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return IconButton.filled(
      tooltip: S.of(context).send,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        disabledBackgroundColor: colors.surfaceContainerHighest,
        disabledForegroundColor: colors.onSurface.withValues(alpha: 0.38),
        shape: const CircleBorder(),
        minimumSize: const Size.square(48),
      ),
      icon: const Icon(Icons.send_rounded, size: 20),
    );
  }
}
