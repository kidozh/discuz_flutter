
import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/JsonResult/PrivateMessageDetailResult.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/CustomizeColor.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:flutter/material.dart';

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
  }
}
