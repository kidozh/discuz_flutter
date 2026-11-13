import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/forum_display_preferences.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:saver_gallery/saver_gallery.dart';

import '../utility/AppPlatformIcons.dart';
import '../utility/forum_image_session.dart';
import '../utility/forum_image_url.dart';

class FullImagePage extends StatefulWidget {
  final String imageUrl;
  final List<String> imageUrlList;
  final Discuz? forum;
  final int? threadId;
  final Map<String, String> fallbackUrls;
  final Map<String, String> filenames;

  const FullImagePage(
    this.imageUrl,
    this.imageUrlList, {
    this.forum,
    this.threadId,
    this.fallbackUrls = const {},
    this.filenames = const {},
    super.key,
  });

  @override
  State<FullImagePage> createState() => FullImagePageState();
}

class FullImagePageState extends State<FullImagePage> {
  late final PageController pageController;
  late int currentPage;
  List<String> get imageUrlList => widget.imageUrlList;

  @override
  void initState() {
    super.initState();
    final index = imageUrlList.indexOf(widget.imageUrl);
    currentPage = index < 0 ? 0 : index;
    pageController = PageController(initialPage: currentPage);
  }

  @override
  Widget build(BuildContext context) {
    final imageSession = ForumImageSession.of(
      context,
      widget.forum,
      threadId: widget.threadId,
    );
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text("${currentPage + 1} / ${imageUrlList.length}", maxLines: 1),
        trailingActions: [
          PlatformIconButton(
            liquidGlassSymbol: 'square.and.arrow.down',
            icon: Icon(
              AppPlatformIcons(context).saveOutline,
              semanticLabel: S.of(context).savePictureToDevice,
            ),
            onPressed: () {
              VibrationUtils.vibrateWithClickIfPossible();
              _save(imageSession);
            },
          ),
        ],
      ),
      body: _photoViewGallery(imageSession),
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  ImageProvider _imageProvider(String url, ForumImageSession? session) =>
      session?.providerFor(url) ?? CachedNetworkImageProvider(url);

  Widget _photoViewGallery(ForumImageSession? imageSession) =>
      PhotoViewGallery.builder(
        key: ValueKey(imageSession?.cacheKey),
        itemCount: imageUrlList.length,
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (BuildContext context, int index) {
          final url = imageUrlList[index];
          final fallback = widget.fallbackUrls[url];
          return PhotoViewGalleryPageOptions(
            imageProvider: _imageProvider(url, imageSession),
            initialScale: PhotoViewComputedScale.contained * 0.8,
            heroAttributes: PhotoViewHeroAttributes(tag: index),
            errorBuilder: (context, _, _) => fallback == null || fallback == url
                ? const Icon(Icons.broken_image_outlined)
                : PhotoView(
                    imageProvider: _imageProvider(fallback, imageSession),
                    initialScale: PhotoViewComputedScale.contained * 0.8,
                    errorBuilder: (_, _, _) =>
                        const Icon(Icons.broken_image_outlined),
                  ),
          );
        },
        pageController: pageController,
        onPageChanged: (value) {
          setState(() {
            currentPage = value;
          });
        },
        loadingBuilder: (context, event) => Center(
          child: SizedBox(
            width: 48,
            height: 48,
            child: PlatformCircularProgressIndicator(
              material: (context, platform) => MaterialProgressIndicatorData(
                value: (event == null || event.expectedTotalBytes == null)
                    ? 0
                    : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
              ),
            ),
          ),
        ),
      );

  Future<Uint8List> _imageBytes(String url, ForumImageSession? session) async {
    final download = session?.download(url);
    if (download != null) return download;
    final forum = widget.forum;
    final base = forum == null ? null : forumBaseUri(forum);
    final uri = resolveForumImageUri(base, url);
    if (uri == null) throw const HttpException('Invalid image URL');
    return loadForumImage(
      uri,
      forum: base ?? Uri.parse(uri.origin),
      policy: ForumImageCookiePolicy.never,
    );
  }

  Future<void> _save(ForumImageSession? imageSession) async {
    if ((!Platform.isIOS && !Platform.isAndroid) ||
        currentPage >= imageUrlList.length) {
      return;
    }
    final strings = S.of(context);
    final url = imageUrlList[currentPage];
    try {
      final needsStoragePermission =
          Platform.isAndroid &&
          (await DeviceInfoPlugin().androidInfo).version.sdkInt < 29;
      if (needsStoragePermission &&
          !(await Permission.storage.request()).isGranted) {
        if (mounted) EasyLoading.showError(strings.writeStorageDenied);
        return;
      }
      if (!mounted) return;
      final fallback = widget.fallbackUrls[url];
      Uint8List bytes;
      var source = url;
      try {
        bytes = await _imageBytes(source, imageSession);
      } on ForumResourceSessionChanged {
        rethrow;
      } catch (_) {
        if (fallback == null || fallback == url) rethrow;
        source = fallback;
        bytes = await _imageBytes(source, imageSession);
      }
      final uri = Uri.parse(source);
      final filename = widget.filenames[url]?.trim();
      final result = await SaverGallery.saveImage(
        bytes,
        fileName: filename != null && filename.isNotEmpty
            ? filename
            : isForumAttachmentUrl(uri)
            ? 'image'
            : uri.pathSegments.lastOrNull ?? 'image',
        skipIfExists: false,
      );
      if (!result.isSuccess) throw StateError('Could not save image');
      if (mounted) EasyLoading.showSuccess(strings.saveImageSuccessfully);
    } catch (_) {
      if (mounted) EasyLoading.showError(strings.loadFailed);
    }
  }
}
