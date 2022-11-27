

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';

class FullImagePage extends StatelessWidget{
  String imageUrl;
  FullImagePage(this.imageUrl);
  late BuildContext _context;
  @override
  Widget build(BuildContext context) {
    _context = context;
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(imageUrl.split("/").last),
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
              if(Platform.isIOS || Platform.isAndroid)
                ElevatedButton.icon(
                    icon: Icon(Icons.save),
                    onPressed: (){
                      _save();
                    },
                    label: Text(S.of(context).savePictureToDevice)
                )
            ],
          )
      )
    );

  }

  Future<void> _saveFigureInDevice() async{
    var response = await Dio().get(imageUrl,
        options: Options(responseType: ResponseType.bytes)
    );
    GallerySaver.saveImage(imageUrl).then((bool? success){
      if(success==true){
        EasyLoading.showSuccess(S.of(_context).saveImageSuccessfully);
      }
    });
    // final _ = await ImageGallerySaver.saveImage(
    //     Uint8List.fromList(response.data),
    //     quality: 100,
    //     name: imageUrl.split("/").last);

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