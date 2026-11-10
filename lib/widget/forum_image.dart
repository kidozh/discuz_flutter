import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../entity/Discuz.dart';
import '../utility/forum_image_session.dart';

class ForumImage extends StatelessWidget {
  const ForumImage({
    super.key,
    required this.forum,
    required this.url,
    required this.loading,
    required this.error,
    this.fit,
  });

  final Discuz forum;
  final String url;
  final Widget Function(BuildContext, double?) loading;
  final WidgetBuilder error;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    final provider = ForumImageSession.of(context, forum)?.providerFor(url);
    if (provider == null) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: fit,
        progressIndicatorBuilder: (context, _, progress) =>
            loading(context, progress.progress),
        errorWidget: (context, _, _) => error(context),
      );
    }
    return Image(
      image: provider,
      fit: fit,
      frameBuilder: (context, child, frame, _) =>
          frame == null ? loading(context, null) : child,
      errorBuilder: (context, _, _) => error(context),
    );
  }
}

class ForumHtmlImageFactory extends WidgetFactory {
  ForumHtmlImageFactory(this.imageSession);

  final ForumImageSession? imageSession;

  @override
  Widget? buildImageWidget(BuildTree meta, ImageSource src) {
    final provider = imageSession?.providerFor(src.url);
    if (provider == null) return super.buildImageWidget(meta, src);

    final label = src.image?.alt ?? src.image?.title;
    return Image(
      image: provider,
      fit: BoxFit.fill,
      semanticLabel: label,
      excludeFromSemantics: label == null,
      frameBuilder: (context, child, frame, _) => frame == null
          ? onLoadingBuilder(context, meta, null, src) ?? child
          : child,
      errorBuilder: (context, error, _) =>
          onErrorBuilder(context, meta, error, src) ?? widget0,
    );
  }
}
