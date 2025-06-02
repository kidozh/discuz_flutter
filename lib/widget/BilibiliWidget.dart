import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/JsonResult/BilibiliVideoResult.dart';
import 'package:discuz_flutter/client/BilibiliApiClient.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum BilibiliWidgetType { video, live }

enum BilibiliVideoRequestType { aid, bvid }

class BilibiliWidget extends StatefulWidget {
  String url = "";
  BilibiliWidget(this.url);

  @override
  State<StatefulWidget> createState() {
    // check the url
    Uri? bilibiliUri = Uri.tryParse(url);
    if (bilibiliUri != null) {
      if (bilibiliUri.path.startsWith("/video")) {
        return BilibiliVideoState(url);
      }
      else if (bilibiliUri.path.startsWith("opus")){

      }
    }

    return BilibiliVideoState(url);

  }
}

class BilibiliVideoState extends State<BilibiliWidget> {
  BilibiliApiClient client = BilibiliApiClient(NetworkUtils.getDio(),
      baseUrl: "https://api.bilibili.com");

  String url = "";
  BilibiliVideoState(this.url);

  BilibiliWidgetType type = BilibiliWidgetType.video;
  BilibiliVideoRequestType videoRequestType = BilibiliVideoRequestType.bvid;
  String videoRequestParameter = "";
  BilibiliVideoResult videoResult = BilibiliVideoResult();

  bool isLoadingApi = false;

  Uri? uri = null;

  @override
  void initState() {
    super.initState();
    parseUrl();
  }

  void parseUrl() {
    Uri? bilibiliUri = Uri.tryParse(url);
    if (bilibiliUri != null) {
      setState(() {
        uri = bilibiliUri;
      });
      log("Get Bilibili URL ${url}, host: ${bilibiliUri.host}, path: ${bilibiliUri.path}, split: ${bilibiliUri.path.split("/")}");

      // not the live
      if (bilibiliUri.host == "live.bilibili.com") {
        type = BilibiliWidgetType.live;
      } else if (bilibiliUri.path.startsWith("/video")) {
        type = BilibiliWidgetType.video;
        // judge whether it's bvid or avid
        List<String> urlPathList = bilibiliUri.path.split("/");
        // remove unneccessary slash
        List<String> urlPathFilteredList = urlPathList
            .where((i) => i != "/" && i.isNotEmpty && i != "video")
            .toList();
        String videoParameterAtLast = urlPathFilteredList.last;

        if (int.tryParse(videoParameterAtLast) != null) {
          videoRequestType = BilibiliVideoRequestType.aid;
        }
        videoRequestParameter = videoParameterAtLast;
        // start fetch it?
        log("load bilibili information ${url} with ${videoRequestParameter} from list : ${urlPathFilteredList}");
        loadBilibiliVideoApi();
      }
    }
  }

  Future<void> loadBilibiliVideoApi() async {
    setState(() {
      isLoadingApi = true;
    });
    switch (videoRequestType) {
      case BilibiliVideoRequestType.aid:
        {
          client
              .getVideoResultByAid(videoRequestParameter)
              .then((result) => renderVideoResult(result))
              .catchError((onError) => callbackResultError(onError))
          ;
          break;
        }
      case BilibiliVideoRequestType.bvid:
        {
          client
              .getVideoResultByBvid(videoRequestParameter)
              .then((result) => renderVideoResult(result))
              .catchError((onError) => callbackResultError(onError))
          ;
          break;
        }
    }
  }

  Future<void> renderVideoResult(BilibiliVideoResult result) async {
    setState(() {
      isLoadingApi = false;
      videoResult = result;
    });
  }

  Future<void> callbackResultError(error) async {
    setState(() {
      isLoadingApi = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (uri == null) {
      return Text("Not a valid Bilibili link ${url}");
    } else {
      if (videoResult.data.viewData.pic.isNotEmpty) {
        return bilibiliVideoPreviewWidget;
      }
    }
    return bilibiliDefaultWidget;
  }

  static const int bilibiliColorPink = 0xFFFB7299;
  static const int bilibiliColorGray = 0xFFF4F4F4;

  Widget get bilibiliDefaultWidget => InkWell(
        onTap: () {
          VibrationUtils.vibrateWithClickIfPossible();
          URLUtils.openURL(context, null, url, null, null);
        },
        child: Card(
          color: Color(bilibiliColorPink),
          child: Container(
            padding: EdgeInsets.all(4.0),
            child: PlatformListTile(
                leading: isLoadingApi? PlatformCircularProgressIndicator(): Icon(
                  FontAwesomeIcons.bilibili,
                  color: Color(bilibiliColorGray),
                ),
                title: Text(
                  url,
                  maxLines: 1,
                  style: TextStyle(color: Color(bilibiliColorGray)),
                )),
          ),
        ),
      );

  Widget get bilibiliVideoPreviewWidget => InkWell(
        onTap: () {
          VibrationUtils.vibrateWithClickIfPossible();
          URLUtils.openURL(context, null, url, null, null);
        },
        child: Card(
          elevation: isCupertino(context) ? 1 : 4,
          child: Container(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            decoration: BoxDecoration(
              color: Color(bilibiliColorPink),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 8,
                  child: CachedNetworkImage(
                      imageUrl: videoResult.data.viewData.pic),
                ),
                Expanded(
                    flex: 8,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(children: [
                              WidgetSpan(
                                child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: Color(bilibiliColorGray)),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 2.0),
                                    margin: EdgeInsets.only(right: 8.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(PlatformIcons(context).playCircleSolid,
                                            size: 10,
                                            color: Color(bilibiliColorPink)),
                                        SizedBox(
                                          width: 4,
                                        ),
                                        Text(
                                          videoResult.data.viewData.tname,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Color(bilibiliColorPink)),
                                        ),
                                      ],
                                    )),
                              ),
                              TextSpan(
                                  text: videoResult.data.viewData.title,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(bilibiliColorGray),
                                      fontSize: 16)),
                            ]),
                          ),
                          SizedBox(
                            width: 16,
                          ),
                          RichText(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(children: [
                              WidgetSpan(
                                child: Container(
                                  padding: EdgeInsets.zero,
                                  margin: EdgeInsets.only(top: 8,right: 8),
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircleAvatar(
                                        backgroundImage:
                                            CachedNetworkImageProvider(
                                      videoResult.data.viewData.owner.face,
                                      maxWidth: 36,
                                      maxHeight: 36,
                                    )),
                                  ),
                                ),
                              ),
                              TextSpan(
                                  text: videoResult.data.viewData.owner.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(bilibiliColorGray),
                                  )),
                            ]),
                          ),
                        ],
                      ),
                    ))
              ],
            ),
          ),
        ),
      );
}


class BilibiliArticlePreviewState extends State<BilibiliWidget>{
  @override
  Widget build(BuildContext context) {
    return Container();
  }

}