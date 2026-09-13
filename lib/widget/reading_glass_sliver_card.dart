import 'package:flutter/cupertino.dart';

BoxDecoration _postDecoration(BuildContext context) => BoxDecoration(
      color: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context),
      borderRadius: const BorderRadius.all(Radius.circular(18)),
    );

/// Opaque post background. Embedded controls retain their own glass styling.
class ReadingPostCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const ReadingPostCard({
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
    super.key,
  });

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        padding: padding,
        decoration: _postDecoration(context),
        child: child,
      );
}

/// Keeps the HTML body in the outer viewport, with an opaque post background.
/// No glass scope: embedded cards and folding controls manage their own effects.
class ReadingGlassSliverCard extends StatelessWidget {
  final Widget sliver;
  const ReadingGlassSliverCard({required this.sliver, super.key});

  @override
  Widget build(BuildContext context) => SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        sliver: DecoratedSliver(
          decoration: _postDecoration(context),
          sliver: SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            sliver: sliver,
          ),
        ),
      );
}
