

import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';

import '../utility/AppPlatformIcons.dart';

class FullImagePage extends StatelessWidget{
  String imageUrl;
  FullImagePage(this.imageUrl);
  late BuildContext _context;
  @override
  Widget build(BuildContext context) {
    _context = context;
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(imageUrl.split("/").last,
          maxLines: 1,
        ),
        trailingActions: [
          IconButton(
            icon: Icon(AppPlatformIcons(context).saveOutline),
            onPressed: (){
              VibrationUtils.vibrateWithClickIfPossible();
              _save();
            },
          )
        ],
      ),
      body: Container(
          child: Column(
            children: [
              Expanded(
                  child: PhotoView(
                    imageProvider: CachedNetworkImageProvider(
                      imageUrl,

                    ),
                  )

              ),

                // ElevatedButton.icon(
                //     icon: Icon(Icons.save),
                //     onPressed: (){
                //       _save();
                //     },
                //     label: Text(S.of(context).savePictureToDevice)
                // )
            ],
          )
      )
    );

  }

  Future<void> _saveFigureInDevice() async{
    var response = await Dio().get(imageUrl,
        options: Options(responseType: ResponseType.bytes)
    );
    ImageGallerySaver.saveImage(Uint8List.fromList(response.data), quality: 100);


  }

  _save() async {
    if(Platform.isIOS || Platform.isAndroid){
      print(imageUrl);
      var status = await Permission.storage.status;
      print(status);
      if(status.isGranted){
        await _saveFigureInDevice();
      }
      else if(status.isPermanentlyDenied){
        EasyLoading.showError(S.of(_context).writeStorageDenied);
      }
      else if(status.isDenied){
        PermissionStatus statusResult = await Permission.storage.request();
        if(statusResult.isGranted){
          // save it
          await _saveFigureInDevice();
        }
        else{
          EasyLoading.showError(S.of(_context).writeStorageDenied);
        }

      }


    }

  }
}