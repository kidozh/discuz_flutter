import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/JsonResult/DiscuzIndexResult.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/Post.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/DisplayForumPage.dart';
import 'package:discuz_flutter/page/UserProfilePage.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/provider/ReplyPostNotifierProvider.dart';
import 'package:discuz_flutter/provider/TypeSettingNotifierProvider.dart';
import 'package:discuz_flutter/utility/CustomizeColor.dart';
import 'package:discuz_flutter/utility/GlobalTheme.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/widget/AttachmentWidget.dart';
import 'package:discuz_flutter/widget/DiscuzHtmlWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

int POST_BLOCKED = 1;
int POST_WARNED = 2;
int POST_REVISED = 4;
int POST_MOBILE = 8;

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
    return
      Consumer<TypeSettingNotifierProvider>(builder: (context, typesetting, _) {
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
                          width: 16.0*typesetting.scalingParameter,
                          height: 16.0*typesetting.scalingParameter,
                          child: InkWell(
                            child: CachedNetworkImage(
                              imageUrl: URLUtils.getAvatarURL(
                                  _discuz, _post.authorId.toString()),
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) =>
                                  CircularProgressIndicator(
                                      value: downloadProgress.progress),
                              errorWidget: (context, url, error) => Container(
                                child: CircleAvatar(
                                  backgroundColor:
                                  CustomizeColor.getColorBackgroundById(
                                      _post.authorId),
                                  child: Text(
                                    _post.author.length != 0
                                        ? _post.author[0].toUpperCase()
                                        : S.of(context).anonymous,
                                    style: TextStyle(color: Colors.white, fontSize: 10*typesetting.scalingParameter),
                                  ),
                                ),
                              ),
                              imageBuilder: (context, imageProvider) => Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: imageProvider, fit: BoxFit.cover),
                                ),
                              ),
                            ),
                            onTap: () async {
                              User? user = Provider.of<DiscuzAndUserNotifier>(context,
                                  listen: false)
                                  .user;
                              await Navigator.push(
                                  context,
                                  platformPageRoute(
                                      context:context,
                                      builder: (context) => UserProfilePage(
                                          _discuz, user, _post.authorId)));
                            },
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
                                              fontSize: 10*typesetting.scalingParameter)),
                                    if (_authorId != _post.authorId)
                                      TextSpan(
                                          text: _post.author,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.indigo.shade400,
                                              fontSize: 10*typesetting.scalingParameter)),
                                    TextSpan(text: ' · '),
                                    TextSpan(
                                        text: TimeAgo.getTimeAgo(_post.publishAt,
                                            locale: locale.scriptCode),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400, fontSize: 10*typesetting.scalingParameter)),
                                  ],
                                ),
                              ),
                              Spacer(),
                              Padding(
                                padding: EdgeInsets.only(right: 8.0),
                                child: Text(
                                  S.of(context).postPosition(_post.position),
                                  style:
                                  TextStyle(fontWeight: FontWeight.w400, fontSize: 12*typesetting.scalingParameter),
                                ),
                              ),
                              PopupMenuButton(
                                itemBuilder: (context) => [
                                  PopupMenuItem<int>(
                                    child: Text(S.of(context).replyPost),
                                    value: 0,
                                  ),
                                  PopupMenuItem<int>(
                                    child: Text(S.of(context).viewUserInfo(_post.author)),
                                    value: 1,
                                  ),
                                ],
                                onSelected: (int pos) {
                                  switch (pos){
                                    case 0:{
                                      // set provider to
                                      Provider.of<ReplyPostNotifierProvider>(context,listen: false).setPost(_post);
                                      break;
                                    }
                                    case 1:{
                                      User? user = Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
                                      Navigator.push(context,
                                          platformPageRoute(
                                              context: context,
                                              builder: (context) => UserProfilePage(
                                                  _discuz, user, _post.authorId)));
                                      break;
                                    }
                                  }
                                },
                              )
                            ],
                          ))
                    ],
                  ),
                  // banned or warn
                  if (_post.status & POST_BLOCKED != 0) getPostBlockedBlock(context),
                  if (_post.status & POST_WARNED != 0) getPostWarnBlock(context),
                  if (_post.status & POST_REVISED != 0) getPostRevisedBlock(context),
                  // rich text rendering
                  DiscuzHtmlWidget(_discuz, _post.message),
                  if (_post.attachmentMapper.isNotEmpty)
                    ListView.builder(
                      itemBuilder: (context, index) {
                        Attachment attachment = _post.getAttachmentList()[index];
                        return AttachmentWidget(_discuz, attachment);
                      },
                      itemCount: _post.getAttachmentList().length,
                      physics: new NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                    )
                ],
              ),
            ));
      });

  }

  Widget getPostBlockedBlock(BuildContext context) {
    return Card(
      color: Theme.of(context).brightness == Brightness.light
          ? Colors.red.shade200
          : Colors.red.shade700,
      child: ListTile(
        leading: Icon(Icons.block),
        title: Text(S.of(context).blockedPost),
        dense: true,
      ),
    );
  }

  Widget getPostWarnBlock(BuildContext context) {
    return Card(
      color: Theme.of(context).brightness == Brightness.light
          ? Colors.amber.shade200
          : Colors.amber.shade700,
      child: ListTile(
        leading: Icon(Icons.warning_amber_outlined),
        title: Text(S.of(context).warnedPost),
        dense: true,
      ),
    );
  }

  Widget getPostRevisedBlock(BuildContext context) {
    return Card(
      color: Theme.of(context).brightness == Brightness.light
          ? Colors.blue.shade200
          : Colors.blue.shade700,
      child: ListTile(
        leading: Icon(Icons.edit_outlined),
        title: Text(S.of(context).revisedPost),
        dense: true,
      ),
    );
  }
}
