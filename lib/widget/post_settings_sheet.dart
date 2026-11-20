import 'package:flutter/material.dart';

import '../generated/l10n.dart';
import '../utility/PlatformAdaptiveWidgets.dart';

Future<T?> showPostSettingsSheet<T>(
  BuildContext context,
  WidgetBuilder builder,
) => showPlatformModalSheet<T>(
  context: context,
  material: const MaterialModalSheetData(isScrollControlled: true),
  builder: builder,
);

class PostSettingsSheet extends StatelessWidget {
  const PostSettingsSheet({
    super.key,
    required this.title,
    required this.children,
    this.onSave,
    this.hasSave = false,
  });

  final String title;
  final List<Widget> children;
  final VoidCallback? onSave;
  final bool hasSave;

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);
    return Material(
      type: MaterialType.transparency,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(title, style: theme.textTheme.titleLarge),
                  ),
                ),
                PlatformIconButton(
                  liquidGlassSymbol: 'xmark',
                  icon: Icon(
                    PlatformIcons(context).closeCircled,
                    semanticLabel: strings.cancel,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(4, 6, 4, 12),
                children: children,
              ),
            ),
            if (hasSave)
              if (isCupertino(context))
                PlatformElevatedButton(
                  onPressed: onSave,
                  child: Text(strings.forumConfirm),
                )
              else
                FilledButton(
                  onPressed: onSave,
                  child: Text(strings.forumConfirm),
                ),
          ],
        ),
      ),
    );
  }
}
