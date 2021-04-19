
import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/JsonResult/DiscuzIndexResult.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/Post.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/DisplayForumPage.dart';
import 'package:discuz_flutter/utility/CustomizeColor.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:webview_flutter/webview_flutter.dart';

// ignore: must_be_immutable
class PostWidget extends StatelessWidget{

  Post _post;
  Discuz _discuz;
  User? _user;

  PostWidget(this._discuz,this._user,this._post);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    Locale locale = Localizations.localeOf(context);
    return Container(

      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // header
            ListTile(
              leading: CachedNetworkImage(
                height: 32,
                width: 32,
                imageUrl: URLUtils.getAvatarURL(_discuz, _post.authorId.toString()),
                progressIndicatorBuilder: (context, url, downloadProgress) => CircularProgressIndicator(value: downloadProgress.progress),
                errorWidget: (context, url, error) =>
                    CircleAvatar(
                      backgroundColor: CustomizeColor.getColorBackgroundById(_post.authorId),
                      child: Text(_post.author.length !=0 ? _post.author[0].toUpperCase()
                          : S.of(context).anonymous,),
                    )
                ,
              ),
              dense: true,
              title: Text(_post.author),
              subtitle: RichText(
                text: TextSpan(
                  text: "",
                  style: DefaultTextStyle.of(context).style,
                  children: <TextSpan>[
                    TextSpan(text: S.of(context).publishAt, style: TextStyle(fontWeight: FontWeight.w300)),
                    TextSpan(text: timeago.format(_post.publishAt,locale: locale.scriptCode)),
                  ],
                ),
              ),
            ),
            // rich text rendering
            Html(
              data: _post.message,
              navigationDelegateForIframe: (NavigationRequest request) {
                return NavigationDecision.navigate;
                // if (request.url.contains("google.com/images")) {
                //   return NavigationDecision.prevent;
                // } else {
                //   return NavigationDecision.navigate;
                // }
              },
            )
          ],
        ),
      )
    );

  }


}