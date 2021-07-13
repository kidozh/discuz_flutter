import 'dart:developer';

import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/JsonResult/DiscuzIndexResult.dart';
import 'package:discuz_flutter/JsonResult/DisplayForumResult.dart';
import 'package:discuz_flutter/JsonResult/PrivateMessageDetailResult.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/HotThread.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/DisplayForumPage.dart';
import 'package:discuz_flutter/page/UserProfilePage.dart';
import 'package:discuz_flutter/page/ViewThreadPage.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/provider/ThemeNotifierProvider.dart';
import 'package:discuz_flutter/screen/NullUserScreen.dart';
import 'package:discuz_flutter/utility/CustomizeColor.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/widget/UserAvatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:provider/provider.dart';

import 'DiscuzHtmlWidget.dart';

// ignore: must_be_immutable
class PrivateMessageDetailWidget extends StatelessWidget {
  PrivateMessageDetail _privateMessageDetail;
  Discuz _discuz;
  User? _user;

  PrivateMessageDetailWidget(
      this._discuz, this._user, this._privateMessageDetail);

  @override
  Widget build(BuildContext context) {



    Brightness textBrightness =
        Provider.of<ThemeNotifierProvider>(context).iconBrightness;

    if(_privateMessageDetail.toUid != _user!.uid){
      // should not own
      return Container(
        margin: EdgeInsets.all(
          10.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  _privateMessageDetail.readableString,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13.0,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    top: 5.0,
                  ),
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.lightGreen,
                    borderRadius: BorderRadius.all(Radius.circular(
                      4.0,
                    )),
                  ),
                  constraints: BoxConstraints(
                    maxWidth: 200.0,
                  ),
                  child: DiscuzHtmlWidget(
                    _discuz,
                    _privateMessageDetail.message,
                  ),
                  // child: Text(
                  //   _privateMessageDetail.message,
                  //   overflow: TextOverflow.clip,
                  //   style: TextStyle(
                  //     fontSize: 16.0,
                  //   ),
                  // ),
                )
                // Text(
                //   S.of(context).me+" / "+_privateMessageDetail.dateTimeString,
                //   style: TextStyle(
                //     color: Colors.grey,
                //     fontSize: 13.0,
                //   ),
                // ),
              ],
            ),
            Card(
              margin: EdgeInsets.only(
                left: 10.0,
              ),
              clipBehavior: Clip.hardEdge,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
              elevation: 0.0,
              child: Container(
                height: 40.0,
                width: 40.0,
                child:  ClipRRect(
                  borderRadius: BorderRadius.circular(10000.0),
                  child: CachedNetworkImage(
                    imageUrl: URLUtils.getAvatarURL(
                        _discuz, _privateMessageDetail.msgFromId.toString()),
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) =>
                        CircularProgressIndicator(
                            value: downloadProgress.progress),
                    errorWidget: (context, url, error) => CircleAvatar(
                      backgroundColor: CustomizeColor.getColorBackgroundById(
                          _privateMessageDetail.msgFromId),
                      child: Text(
                          _privateMessageDetail.msgFromName.length != 0
                              ? _privateMessageDetail.msgFromName[0]
                              .toUpperCase()
                              : S.of(context).anonymous,
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    else{
      return Container(
        margin: EdgeInsets.all(
          10.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Card(
              margin: EdgeInsets.only(
                right: 10.0,
              ),
              clipBehavior: Clip.hardEdge,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
              elevation: 0.0,
              child: Container(
                height: 40.0,
                width: 40.0,
                child:  ClipRRect(
                  borderRadius: BorderRadius.circular(10000.0),
                  child: CachedNetworkImage(
                    imageUrl: URLUtils.getAvatarURL(
                        _discuz, _privateMessageDetail.msgFromId.toString()),
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) =>
                        CircularProgressIndicator(
                            value: downloadProgress.progress),
                    errorWidget: (context, url, error) => CircleAvatar(
                      backgroundColor: CustomizeColor.getColorBackgroundById(
                          _privateMessageDetail.msgFromId),
                      child: Text(
                          _privateMessageDetail.msgFromName.length != 0
                              ? _privateMessageDetail.msgFromName[0]
                              .toUpperCase()
                              : S.of(context).anonymous,
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _privateMessageDetail.msgFromName+" / "+_privateMessageDetail.readableString,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13.0,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    top: 5.0,
                  ),
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.light?Colors.white70:Colors.black38,
                    borderRadius: BorderRadius.all(Radius.circular(
                      4.0,
                    )),
                  ),
                  constraints: BoxConstraints(
                    maxWidth: 200.0,
                  ),
                  // child: Text(
                  //   _privateMessageDetail.message,
                  //   overflow: TextOverflow.clip,
                  //   style: TextStyle(
                  //     fontSize: 16.0,
                  //     color: Theme.of(context).brightness == Brightness.light?Colors.black:Colors.white,
                  //   ),
                  // ),
                  child: DiscuzHtmlWidget(
                    _discuz,
                    _privateMessageDetail.message,
                  ),
                )
              ],
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [

        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(width: 4.0,),
            if (_privateMessageDetail.toUid == _user!.uid)
              InkWell(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10000.0),
                  child: CachedNetworkImage(
                    imageUrl: URLUtils.getAvatarURL(
                        _discuz, _privateMessageDetail.msgFromId.toString()),
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) =>
                            CircularProgressIndicator(
                                value: downloadProgress.progress),
                    errorWidget: (context, url, error) => CircleAvatar(
                      backgroundColor: CustomizeColor.getColorBackgroundById(
                          _privateMessageDetail.msgFromId),
                      child: Text(
                          _privateMessageDetail.msgFromName.length != 0
                              ? _privateMessageDetail.msgFromName[0]
                                  .toUpperCase()
                              : S.of(context).anonymous,
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
                onTap: () async {
                  User? user =
                      Provider.of<DiscuzAndUserNotifier>(context, listen: false)
                          .user;
                  await Navigator.push(
                      context,
                      platformPageRoute(
                          context: context,
                          builder: (context) => UserProfilePage(
                              _discuz, user, _privateMessageDetail.msgFromId)));
                },
              ),
            SizedBox(width: 4.0,),
            Column(
              children: [
                Text(_privateMessageDetail.dateTimeString,style: Theme.of(context).textTheme.caption,),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Text(_privateMessageDetail.message, style: TextStyle(backgroundColor: Theme.of(context).primaryColor, color: textBrightness == Brightness.light? Colors.black: Colors.white),)
                )
              ],
            ),
            Expanded(
              child: Container(),
            )
          ],
        )
      ],
    );
  }
}
