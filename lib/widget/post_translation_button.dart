import 'package:flutter/material.dart';
import '../utility/PlatformAdaptiveWidgets.dart';

/// One compact action in the post's existing toolbar.
class PostTranslationButton extends StatelessWidget {
  const PostTranslationButton({
    super.key,
    required this.label,
    required this.hint,
    required this.busy,
    required this.translated,
    required this.onPressed,
    required this.onChooseLanguage,
  });
  final String label;
  final String hint;
  final bool busy;
  final bool translated;
  final VoidCallback onPressed;
  final VoidCallback onChooseLanguage;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: '$label · $hint',
    child: GestureDetector(
      onSecondaryTap: onChooseLanguage,
      child: Semantics(
        label: label,
        hint: hint,
        button: true,
        toggled: translated,
        child: SizedBox.square(
          dimension: 44,
          child: PlatformIconButton(
            padding: EdgeInsets.zero,
            onPressed: busy ? null : onPressed,
            onLongPress: onChooseLanguage,
            icon: busy
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    translated ? Icons.undo : PlatformIcons(context).translate,
                    size: 18,
                    color: translated
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
          ),
        ),
      ),
    ),
  );
}
