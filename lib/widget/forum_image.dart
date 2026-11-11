import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:html/dom.dart' as dom;

import '../entity/Discuz.dart';
import '../utility/forum_image_session.dart';
import '../utility/forum_image_url.dart';

class ForumImage extends StatelessWidget {
  const ForumImage({
    super.key,
    required this.forum,
    required this.url,
    required this.loading,
    required this.error,
    this.fit,
    this.threadId,
    this.fallbackUrl,
  });

  final Discuz forum;
  final String url;
  final Widget Function(BuildContext, double?) loading;
  final WidgetBuilder error;
  final BoxFit? fit;
  final int? threadId;
  final String? fallbackUrl;

  @override
  Widget build(BuildContext context) {
    final baseUrl = forumBaseUri(forum);
    final source = resolveForumImageUri(baseUrl, url)?.toString() ?? url;
    final session = ForumImageSession.of(context, forum, threadId: threadId);
    final provider = session?.providerFor(source);
    final fallback = fallbackUrl;
    final fallbackProvider = fallback == null
        ? null
        : session?.providerFor(fallback);
    Widget onError(BuildContext context) =>
        fallbackProvider == null || fallbackProvider == provider
        ? error(context)
        : _image(fallbackProvider, error);

    if (provider == null) {
      return CachedNetworkImage(
        imageUrl: source,
        fit: fit,
        progressIndicatorBuilder: (context, _, progress) =>
            loading(context, progress.progress),
        errorWidget: (context, _, _) => onError(context),
      );
    }
    return _image(provider, onError);
  }

  Widget _image(ImageProvider provider, WidgetBuilder onError) => Image(
    image: provider,
    fit: fit,
    frameBuilder: (context, child, frame, _) =>
        frame == null ? loading(context, null) : child,
    errorBuilder: (context, _, _) => onError(context),
  );
}

String? forumHtmlImageSource(dom.Element element, {bool original = false}) {
  String? read(String name) {
    final value = element.attributes[name]?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  final preview = read('src');
  final fullImage = read('file') ?? read('data-src');
  final reference = fullImage == null ? null : Uri.tryParse(fullImage);
  if (reference == null ||
      (reference.hasScheme &&
          reference.scheme != 'https' &&
          reference.scheme != 'http')) {
    return preview;
  }
  final path = preview == null ? null : Uri.tryParse(preview)?.path;
  if (original ||
      preview == null ||
      preview.startsWith('data:image/') ||
      path?.split('/').last.toLowerCase() == 'none.gif') {
    return fullImage;
  }
  return preview;
}

class ForumHtmlImageFactory extends WidgetFactory {
  ForumHtmlImageFactory(this.imageSession, {Uri? baseUrl})
    : _baseUrl = baseUrl ?? imageSession?.baseUrl;

  final ForumImageSession? imageSession;
  final Uri? _baseUrl;

  @override
  void parse(BuildTree tree) {
    final element = tree.element;
    if (element.localName == 'img') {
      final source = forumHtmlImageSource(element);
      if (source != null) {
        element.attributes['src'] =
            resolveForumImageUri(_baseUrl, source)?.toString() ?? source;
      }
    }
    super.parse(tree);
  }

  @override
  Widget? buildImageWidget(BuildTree meta, ImageSource src) {
    final provider = imageSession?.providerFor(src.url);
    if (provider == null) return super.buildImageWidget(meta, src);

    final label = src.image?.alt ?? src.image?.title;
    final original = forumHtmlImageSource(meta.element, original: true);
    final fallback = original == null
        ? null
        : imageSession?.providerFor(original);
    Widget image(ImageProvider source, {ImageProvider? fallback}) => Image(
      image: source,
      fit: BoxFit.fill,
      semanticLabel: label,
      excludeFromSemantics: label == null,
      frameBuilder: (context, child, frame, _) => frame == null
          ? onLoadingBuilder(context, meta, null, src) ?? child
          : child,
      errorBuilder: (context, error, _) => fallback != null
          ? image(fallback)
          : onErrorBuilder(context, meta, error, src) ?? widget0,
    );
    return image(provider, fallback: fallback == provider ? null : fallback);
  }
}
