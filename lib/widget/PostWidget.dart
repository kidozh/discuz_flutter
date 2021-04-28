import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/JsonResult/DiscuzIndexResult.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/Post.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/DisplayForumPage.dart';
import 'package:discuz_flutter/utility/CustomizeColor.dart';
import 'package:discuz_flutter/utility/GlobalTheme.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/widget/AttachmentWidget.dart';
import 'package:discuz_flutter/widget/DiscuzHtmlWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:webview_flutter/webview_flutter.dart';

// ignore: must_be_immutable
class PostWidget extends StatelessWidget {
  Post _post;
  Discuz _discuz;
  int _authorId;

  PostWidget(this._discuz, this._post, this._authorId);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    Locale locale = Localizations.localeOf(context);
    final orientation = MediaQuery.of(context).orientation;
    return Container(
        child: Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.all(4.0),
                child: Container(
                  width: 16.0,
                  height: 16.0,
                  child: CachedNetworkImage(
                    imageUrl: URLUtils.getAvatarURL(
                        _discuz, _post.authorId.toString()),
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) =>
                            CircularProgressIndicator(
                                value: downloadProgress.progress),
                    errorWidget: (context, url, error) => Container(
                      width: 16.0,
                      height: 16.0,
                      child: CircleAvatar(
                        backgroundColor: CustomizeColor.getColorBackgroundById(
                            _post.authorId),
                        child: Text(
                          _post.author.length != 0
                              ? _post.author[0].toUpperCase()
                              : S.of(context).anonymous,
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                    imageBuilder: (context, imageProvider) => Container(
                      width: 16.0,
                      height: 16.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: imageProvider, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                  child: Row(
                children: [
                  RichText(
                    text: TextSpan(
                      text: "",
                      style: DefaultTextStyle.of(context).style,
                      children: <TextSpan>[
                        if (_authorId == _post.authorId)
                          TextSpan(
                              text: _post.author,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepOrange.shade400,
                                  fontSize: 12)),
                        if (_authorId != _post.authorId)
                          TextSpan(
                              text: _post.author,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo.shade400,
                                  fontSize: 12)),
                        TextSpan(text: ' · '),
                        TextSpan(
                            text: timeago.format(_post.publishAt,
                                locale: locale.scriptCode),
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 12)),
                      ],
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Text(
                      S.of(context).postPosition(_post.position),
                      style:
                          TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
                    ),
                  ),
                ],
              ))
            ],
          ),
          // rich text rendering
          DiscuzHtmlWidget(_discuz, _post.message),
          if (_post.attachmentMapper.isNotEmpty)
            ListView.builder(
              itemBuilder: (context, index) {
                Attachment attachment = _post.getAttachmentList()[index];
                return AttachmentWidget(_discuz,attachment);
              },
              itemCount: _post.getAttachmentList().length,
              physics: new NeverScrollableScrollPhysics(),
              shrinkWrap: true,
            )
        ],
      ),
    ));
  }
}
