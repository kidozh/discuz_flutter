import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/JsonResult/ViewThreadResult.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/TypeSettingNotifierProvider.dart';
import 'package:discuz_flutter/utility/CustomizeColor.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PostCommentWidget extends StatelessWidget {
  Comment _comment;

  PostCommentWidget(this._comment);

  @override
  Widget build(BuildContext context) {
    return Consumer<TypeSettingNotifierProvider>(
        builder: (context, typesetting, _) {
      return InkWell(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(width: 16,),
            CachedNetworkImage(
                imageUrl: _comment.avatar,
                height: 16,
                width: 16,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    CircularProgressIndicator(value: downloadProgress.progress),
                errorWidget: (context, url, error) => Container(
                  child: CircleAvatar(
                    backgroundColor: CustomizeColor.getColorBackgroundById(
                        _comment.authorId),
                    child: Text(
                      _comment.author.length != 0
                          ? _comment.author[0].toUpperCase()
                          : S.of(context).anonymous,
                      style: TextStyle(color: Colors.white, fontSize: 8),
                    ),
                  ),
                )),
            SizedBox(width: 8.0,),
            Expanded(
              child: RichText(
                textAlign: TextAlign.start,
                //overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  text: "",
                  style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
                  children: [
                    TextSpan(
                        text: _comment.author,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            // color: Theme.of(context).colorScheme.tertiary,
                            fontSize: 12 )),
                    TextSpan(text: ' · '),
                    TextSpan(
                        text: _comment.dateline.replaceAll("&nbsp;", ""),
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12 )),
                    TextSpan(text: '    '),
                    TextSpan(text: _comment.comment, style: TextStyle(fontSize: 12))
                  ],
                ),
              ),
            )
          ],
        ),
        onTap: (){
          VibrationUtils.vibrateWithClickIfPossible();
        },
      );
    });
  }
}
