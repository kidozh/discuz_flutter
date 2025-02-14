import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../utility/AppPlatformIcons.dart';



class FullImagePage extends StatefulWidget {
  String imageUrl;
  List<String> imageUrlList = [];

  FullImagePage(this.imageUrl, this.imageUrlList);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return FullImagePageState(imageUrl, imageUrlList);
  }



}


class FullImagePageState extends State<FullImagePage>{
  String imageUrl;
  List<String> imageUrlList = [];

  late PageController pageController;

  int currentPage = 0;
  FullImagePageState(this.imageUrl, this.imageUrlList){
    currentPage = initialPage;
    pageController = PageController(initialPage: initialPage);

  }

  @override
  Widget build(BuildContext context) {


    return PlatformScaffold(
        appBar: PlatformAppBar(
          title: Text(
            "${currentPage + 1} / ${imageUrlList.length}",
            maxLines: 1,
          ),
          trailingActions: [
            IconButton(
              icon: Icon(AppPlatformIcons(context).saveOutline),
              onPressed: () {
                VibrationUtils.vibrateWithClickIfPossible();
                _save(context);
              },
            )
          ],
        ),
        body: Container(
            child: Column(
              children: [
                Expanded(
                  child: photoViewGalleryListBuilder,
                )
              ],
            )));
  }

  int get initialPage => imageUrlList.indexOf(imageUrl);

  Widget get photoViewGalleryListBuilder => PhotoViewGallery.builder(
    itemCount: imageUrlList.length,
    scrollPhysics: const BouncingScrollPhysics(),
    builder: (BuildContext context, int index) {
      return PhotoViewGalleryPageOptions(
        imageProvider: CachedNetworkImageProvider(imageUrlList[index]),
        initialScale: PhotoViewComputedScale.contained * 0.8,
        heroAttributes: PhotoViewHeroAttributes(tag: index),
      );
    },
    pageController: pageController,
    onPageChanged: (value){
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
            value: (event == null || event.expectedTotalBytes == null)? 0: event.cumulativeBytesLoaded / event.expectedTotalBytes!
          ),
        ),
      ),
    ),

  );

  Future<void> _saveFigureInDevice() async {
    if(currentPage < imageUrlList.length){
      var response = await Dio()
          .get(imageUrlList[currentPage], options: Options(responseType: ResponseType.bytes));
      ImageGallerySaverPlus.saveImage(Uint8List.fromList(response.data),
          quality: 100);
      EasyLoading.showSuccess(S.of(context).saveImageSuccessfully);
    }
  }

  _save(BuildContext context) async {
    if (Platform.isIOS || Platform.isAndroid) {
      print(imageUrl);
      var status = await Permission.storage.status;
      print(status);
      if (status.isGranted) {
        await _saveFigureInDevice();
      } else if (status.isPermanentlyDenied) {
        EasyLoading.showError(S.of(context).writeStorageDenied);
      } else if (status.isDenied) {
        PermissionStatus statusResult = await Permission.storage.request();
        if (statusResult.isGranted) {
          // save it
          await _saveFigureInDevice();
        } else {
          EasyLoading.showError(S.of(context).writeStorageDenied);
        }
      }
    }
  }
}
