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
    final fallback = resolveForumImageUri(
      baseUrl,
      fallbackUrl ?? '',
    )?.toString();
    Widget onError(BuildContext context) =>
        fallback == null || fallback == source
        ? error(context)
        : _imageForUrl(fallback, session, error);
    return _imageForUrl(source, session, onError);
  }

  Widget _imageForUrl(
    String source,
    ForumImageSession? session,
    WidgetBuilder onError,
  ) {
    final provider = session?.providerFor(source);
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

  String? networkSource(String name) {
    final value = read(name);
    final reference = value == null ? null : Uri.tryParse(value);
    if (reference == null ||
        reference.userInfo.isNotEmpty ||
        (reference.hasScheme &&
            reference.scheme != 'https' &&
            reference.scheme != 'http')) {
      return null;
    }
    return value;
  }

  final preview = read('src');
  final zoom = networkSource('zoomfile');
  final lazy = networkSource('file') ?? networkSource('data-src');
  if (original) return zoom ?? lazy ?? preview;
  final path = preview == null ? null : Uri.tryParse(preview)?.path;
  if (preview == null ||
      preview.startsWith('data:image/') ||
      path?.split('/').last.toLowerCase() == 'none.gif') {
    return lazy ?? zoom ?? preview;
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
    final uri = resolveForumImageUri(_baseUrl, src.url);
    if (uri == null) return super.buildImageWidget(meta, src);
    ImageProvider? providerFor(Uri uri) =>
        imageSession?.providerFor(uri.toString()) ??
        imageProviderFromNetwork(uri.toString());
    final provider = providerFor(uri);
    if (provider == null) return super.buildImageWidget(meta, src);
    final label = src.image?.alt ?? src.image?.title;
    final fallbackUri = resolveForumImageUri(
      _baseUrl,
      forumHtmlImageSource(meta.element, original: true) ?? '',
    );
    final fallback = fallbackUri == null || fallbackUri == uri
        ? null
        : providerFor(fallbackUri);
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
