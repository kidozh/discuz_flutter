import 'ForumInteractionWidgets.dart';
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
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class AttachmentWidget extends StatelessWidget {
  Discuz _discuz;
  Attachment _attachment;

  final VoidCallback? onContentChanged;
  AttachmentWidget(this._discuz, this._attachment, {this.onContentChanged});

  double downloadPercent = 0.0;

  Future<void> _downloadFile(BuildContext context) async {
    // judge permission
    if (Platform.isAndroid || Platform.isIOS) {
      var status = await Permission.storage.status;
      print(status);
      if (status.isGranted) {}
      if (status.isDenied) {
        EasyLoading.showError(S.of(context).writeStorageDenied);
        return;
      }
    }
    // get saved directory
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    String savePath = "${appDocPath}/${_attachment.filename}";

    Discuz discuz = Provider.of<DiscuzAndUserNotifier>(
      context,
      listen: false,
    ).discuz!;
    User? user = Provider.of<DiscuzAndUserNotifier>(
      context,
      listen: false,
    ).user;
    Dio dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    String urlPath = URLUtils.getAttachmentURLWithAidEncode(
      discuz,
      _attachment.aidEncode,
    );
    EasyLoading.showInfo(S.of(context).downloadingFiles(_attachment.filename));
    dio.download(
      urlPath,
      savePath,
      onReceiveProgress: (int loaded, int total) {
        if (loaded >= total) {
          showPlatformAlert(
            context: context,
            title: S
                .of(context)
                .successfullyDownloadFiles(_attachment.filename),
            message: S.of(context).openFileInExternalAppContent,
            actions: [
              PlatformAlertAction(
                label: S.of(context).cancel,
                isCancelAction: true,
                onPressed: VibrationUtils.vibrateWithClickIfPossible,
              ),
              PlatformAlertAction(
                label: S.of(context).openFileInExternalAppActionText,
                isDefaultAction: true,
                onPressed: () async {
                  VibrationUtils.vibrateWithClickIfPossible();
                  final result = await OpenFilex.open(savePath);
                  if (result.type != ResultType.done) {
                    EasyLoading.showError("${result.message}(${result.type})");
                  }
                },
              ),
            ],
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_attachment.price > 0 && !_attachment.payed) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_attachment.filename),
          ForumActionButton(
            discuz: _discuz,
            tid: _attachment.tid,
            aid: _attachment.aid,
            purchase: true,
            label: S.of(context).forumBuyAttachment,
            onChanged: onContentChanged ?? () {},
          ),
        ],
      );
    }
    Discuz discuz = Provider.of<DiscuzAndUserNotifier>(
      context,
      listen: false,
    ).discuz!;

    if ([
      "jpg",
      "png",
      "svg",
      "bmp",
      "gif",
      "jpeg",
    ].contains(_attachment.ext.toLowerCase())) {
      return InkWell(
        child: PlatformCard(
          elevation: 8.0,
          child: CachedNetworkImage(
            imageUrl: _attachment.getAttachmentRealUrl(_discuz),
            fit: BoxFit.fill,
            errorWidget: (context, url, error) =>
                Icon(PlatformIcons(context).error),
            progressIndicatorBuilder: (context, url, progress) => Container(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: PlatformCircularProgressIndicator(
                  material: (_, __) =>
                      MaterialProgressIndicatorData(value: progress.progress),
                ),
              ),
            ),
          ),
        ),
        onTap: () {
          VibrationUtils.vibrateWithClickIfPossible();

          Navigator.push(
            context,
            platformPageRoute(
              context: context,
              iosTitle: S.of(context).viewPicture,
              builder: (context) => FullImagePage(
                URLUtils.getAttachmentURLWithAidEncode(
                  discuz,
                  _attachment.aidEncode,
                ),
                [
                  URLUtils.getAttachmentURLWithAidEncode(
                    discuz,
                    _attachment.aidEncode,
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return PlatformCard(
      child: Column(
        children: [
          PlatformListTile(
            leading: Icon(PlatformIcons(context).attachment),
            title: Text(_attachment.filename),
            subtitle: Text(_attachment.attachmentSizeString),
            trailing: Badge(
              label: Text(
                _attachment.downloads.toString(),
                style: TextStyle(color: Colors.white),
              ),
              child: Icon(PlatformIcons(context).download),
            ),
          ),
          CachedNetworkImage(
            imageUrl: _attachment.getAttachmentRealUrl(_discuz),
            errorWidget: (context, url, error) =>
                Icon(PlatformIcons(context).error),
            progressIndicatorBuilder: (context, url, progress) =>
                PlatformCircularProgressIndicator(
                  material: (_, __) =>
                      MaterialProgressIndicatorData(value: progress.progress),
                ),
          ),
          Wrap(
            alignment: WrapAlignment.start,
            spacing: 8,
            runSpacing: 8,
            children: [
              PlatformTextButton(
                onPressed: () {
                  _downloadFile(context);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(PlatformIcons(context).download, size: 20),
                    const SizedBox(width: 6),
                    Text(S.of(context).downloadAttachment),
                  ],
                ),
              ),
              if ([
                "jpg",
                "png",
                "svg",
                "bmp",
                "gif",
              ].contains(_attachment.ext.toLowerCase()))
                PlatformTextButton(
                  onPressed: () {
                    VibrationUtils.vibrateWithClickIfPossible();
                    Navigator.push(
                      context,
                      platformPageRoute(
                        context: context,
                        iosTitle: S.of(context).viewPicture,
                        builder: (context) => FullImagePage(
                          URLUtils.getAttachmentURLWithAidEncode(
                            discuz,
                            _attachment.aidEncode,
                          ),
                          [
                            URLUtils.getAttachmentURLWithAidEncode(
                              discuz,
                              _attachment.aidEncode,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(PlatformIcons(context).fullscreen, size: 20),
                      const SizedBox(width: 6),
                      Text(S.of(context).watchPictureInFullScreen),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
