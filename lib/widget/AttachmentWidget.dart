

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/Post.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/FullImagePage.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class AttachmentWidget extends StatelessWidget{
  Discuz _discuz;
  Attachment _attachment;

  AttachmentWidget(this._discuz,this._attachment);

  double downloadPercent = 0.0;

  Future<void> _downloadFile(BuildContext context) async{
    // judge permission
    if(Platform.isAndroid || Platform.isIOS){
      var status = await Permission.storage.status;
      print(status);
      if(status.isGranted){

      }
      if(status.isDenied){
        EasyLoading.showError(S.of(context).writeStorageDenied);
        return;
      }


    }
    // get saved directory
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    String savePath = "${appDocPath}/${_attachment.filename}";

    Discuz discuz = Provider.of<DiscuzAndUserNotifier>(context, listen: false).discuz!;
    User? user = Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
    Dio dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    String urlPath = URLUtils.getAttachmentURLWithAidEncode(discuz, _attachment.aidEncode);
    EasyLoading.showInfo(S.of(context).downloadingFiles(_attachment.filename));
    dio.download(urlPath, savePath, onReceiveProgress: (int loaded, int total) {
      if(loaded >= total){

        showDialog(context: context, builder: (context){
          return AlertDialog(
            title: Text(S.of(context).successfullyDownloadFiles(_attachment.filename)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(S.of(context).openFileInExternalAppContent)
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  VibrationUtils.vibrateWithClickIfPossible();
                  Navigator.pop(context);
                },
                child: Text(S.of(context).cancel),

              ),
              TextButton(
                onPressed: () async{
                  VibrationUtils.vibrateWithClickIfPossible();
                  final result = await OpenFilex.open(savePath);
                  if(result.type != ResultType.done){
                    EasyLoading.showError("${result.message}(${result.type})");
                  }
                  else{
                    Navigator.pop(context);
                  }
                },
                child: Text(S.of(context).openFileInExternalAppActionText),

              ),
            ],
          );
        });
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    Discuz discuz = Provider.of<DiscuzAndUserNotifier>(context, listen: false).discuz!;
    
    if(["jpg","png","svg","bmp","gif","jpeg"].contains(_attachment.ext.toLowerCase())){
      return InkWell(
        child: Card(
          elevation: 8.0,
          child: CachedNetworkImage(
            imageUrl: _attachment.getAttachmentRealUrl(_discuz),
            fit: BoxFit.fill,
            errorWidget: (context, url, error) => Icon(Icons.error),
            progressIndicatorBuilder: (context, url, progress) => Container(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: PlatformCircularProgressIndicator(
                  material: (_, __) => MaterialProgressIndicatorData(
                      value: progress.progress
                  ),
                ),
              ),
            ),
          ),
        ),
        onTap: (){
          VibrationUtils.vibrateWithClickIfPossible();

          Navigator.push(
              context,
              platformPageRoute(context:context,
                  iosTitle: S.of(context).viewPicture,
                  builder: (context) => FullImagePage(
                  URLUtils.getAttachmentURLWithAidEncode(discuz, _attachment.aidEncode),
                  [URLUtils.getAttachmentURLWithAidEncode(discuz, _attachment.aidEncode)]
              ))
          );
        },
      );
    }


    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.attachment),
            title: Text(_attachment.filename),
            subtitle: Text(_attachment.attachmentSizeString),
            trailing: Badge(
              label: Text(_attachment.downloads.toString(),style: TextStyle(color: Colors.white),),
              child: Icon(Icons.file_download),
            ),
          ),
          CachedNetworkImage(
            imageUrl: _attachment.getAttachmentRealUrl(_discuz),
            errorWidget: (context, url, error) => Icon(Icons.error),
            progressIndicatorBuilder: (context, url, progress) => PlatformCircularProgressIndicator(
              material: (_, __) => MaterialProgressIndicatorData(
                  value: progress.progress
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextButton.icon(
                  icon: Icon(Icons.file_download),
                  onPressed: () {
                    _downloadFile(context);

              }, label: Text(S.of(context).downloadAttachment)),
              if(["jpg","png","svg","bmp","gif"].contains(_attachment.ext.toLowerCase()))
              TextButton.icon(
                  icon: Icon(Icons.fullscreen),
                  onPressed: (){
                    VibrationUtils.vibrateWithClickIfPossible();
                    Navigator.push(
                        context,
                        platformPageRoute(context:context,
                            iosTitle: S.of(context).viewPicture,
                            builder: (context) => FullImagePage(

                            URLUtils.getAttachmentURLWithAidEncode(discuz, _attachment.aidEncode),
                            [URLUtils.getAttachmentURLWithAidEncode(discuz, _attachment.aidEncode)]
                        ))
                    );
              }, label: Text(S.of(context).watchPictureInFullScreen))
            ],
          )
        ],
      ),
    );
  }

}