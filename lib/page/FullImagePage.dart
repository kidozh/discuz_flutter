import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
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

class FullImagePage extends StatefulWidget {
  String imageUrl;
  List<String> imageUrlList = [];
  final Discuz? forum;
  final int? threadId;

  FullImagePage(this.imageUrl, this.imageUrlList, {this.forum, this.threadId});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return FullImagePageState(imageUrl, imageUrlList);
  }
}

class FullImagePageState extends State<FullImagePage> {
  String imageUrl;
  List<String> imageUrlList = [];

  late PageController pageController;

  int currentPage = 0;
  FullImagePageState(this.imageUrl, this.imageUrlList) {
    currentPage = initialPage;
    pageController = PageController(initialPage: initialPage);
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
              _save(context, imageSession);
            },
          ),
        ],
      ),
      body: Container(
        child: Column(
          children: [Expanded(child: _photoViewGallery(imageSession))],
        ),
      ),
    );
  }

  int get initialPage => imageUrlList.indexOf(imageUrl);

  Widget _photoViewGallery(ForumImageSession? imageSession) =>
      PhotoViewGallery.builder(
        itemCount: imageUrlList.length,
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (BuildContext context, int index) {
          final url = imageUrlList[index];
          return PhotoViewGalleryPageOptions(
            imageProvider:
                imageSession?.providerFor(url) ??
                CachedNetworkImageProvider(url),
            initialScale: PhotoViewComputedScale.contained * 0.8,
            heroAttributes: PhotoViewHeroAttributes(tag: index),
          );
        },
        pageController: pageController,
        onPageChanged: (value) {
          setState(() {
            currentPage = value;
          });
        },
        loadingBuilder: (context, event) => Center(
          child: Container(
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

  Future<void> _saveFigureInDevice(ForumImageSession? imageSession) async {
    if (currentPage < imageUrlList.length) {
      final url = imageUrlList[currentPage];
      final bytes =
          await (imageSession?.download(url) ??
              Dio()
                  .get<Uint8List>(
                    url,
                    options: Options(responseType: ResponseType.bytes),
                  )
                  .then((response) => response.data!));
      SaverGallery.saveImage(
        bytes,
        quality: 100,
        fileName: url.split("/").last,
        skipIfExists: false,
      );
      EasyLoading.showSuccess(S.of(context).saveImageSuccessfully);
    }
  }

  _save(BuildContext context, ForumImageSession? imageSession) async {
    if (Platform.isIOS || Platform.isAndroid) {
      var status = await Permission.storage.status;
      print(status);
      if (status.isGranted) {
        await _saveFigureInDevice(imageSession);
      } else if (status.isPermanentlyDenied) {
        EasyLoading.showError(S.of(context).writeStorageDenied);
      } else if (status.isDenied) {
        PermissionStatus statusResult = await Permission.storage.request();
        if (statusResult.isGranted) {
          // save it
          await _saveFigureInDevice(imageSession);
        } else {
          EasyLoading.showError(S.of(context).writeStorageDenied);
        }
      }
    }
  }
}
