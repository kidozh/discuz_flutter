import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:flutter/cupertino.dart';

/// Separates embedded media from the page in the classic Cupertino appearance.
class CupertinoMediaOutline extends StatelessWidget {
  const CupertinoMediaOutline({
    required this.child,
    required this.borderRadius,
    super.key,
  });

  final Widget child;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    if (visualStyle(context) != AppVisualStyle.cupertino) return child;

    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(
          color: CupertinoColors.separator.resolveFrom(context),
          width: 0.8,
        ),
      ),
      child: ClipRRect(borderRadius: borderRadius, child: child),
    );
  }
}
