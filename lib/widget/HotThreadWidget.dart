
import 'dart:developer';

import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/JsonResult/DiscuzIndexResult.dart';
import 'package:discuz_flutter/JsonResult/DisplayForumResult.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/HotThread.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/DisplayForumPage.dart';
import 'package:discuz_flutter/page/UserProfilePage.dart';
import 'package:discuz_flutter/page/ViewThreadPage.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/utility/CustomizeColor.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class HotThreadWidget extends StatelessWidget{

  HotThread _hotThread;
  Discuz _discuz;
  User? _user;

  HotThreadWidget(this._discuz,this._user,this._hotThread);

  Widget getTailingWidget(){
    if(_hotThread.displayOrder > 0){
      return Icon(Icons.vertical_align_top, color: Colors.redAccent,);
    }
    else{
      return Badge(
        badgeContent: Text(_hotThread.replies,style: TextStyle(color: Colors.white),),
        child: Icon(Icons.message_outlined),
      );

    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    Locale locale = Localizations.localeOf(context);
    log("languages ${locale} ${locale.toLanguageTag()} ${locale.scriptCode} ${locale.languageCode}");
    // retrieve threadtype


    return Card(
      elevation: 2.0,
      child: ListTile(
        leading: InkWell(
          child: ClipRRect(

            borderRadius: BorderRadius.circular(10000.0),
            child: CachedNetworkImage(
              imageUrl: URLUtils.getAvatarURL(_discuz, _hotThread.authorId.toString()),
              progressIndicatorBuilder: (context, url, downloadProgress) => CircularProgressIndicator(value: downloadProgress.progress),
              errorWidget: (context, url, error) =>
                  CircleAvatar(

                    backgroundColor: CustomizeColor.getColorBackgroundById(_hotThread.authorId),
                    child: Text(_hotThread.author.length !=0 ? _hotThread.author[0].toUpperCase()
                        : S.of(context).anonymous,
                        style: TextStyle(color: Colors.white)),
                  )
              ,
            ),
          ),
          onTap: () async{
            User? user = Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
            await Navigator.push(
                context,
                platformPageRoute(context:context,builder: (context) => UserProfilePage(_discuz,user, _hotThread.authorId)));
          },
        ),
        title: Text(_hotThread.subject,style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: RichText(
          text: TextSpan(
            text: _hotThread.author,
            style: DefaultTextStyle.of(context).style,
            children: <TextSpan>[
              //TextSpan(text: S.of(context).publishAt, style: TextStyle(fontWeight: FontWeight.w300)),
              TextSpan(text: " · ",style: TextStyle(fontWeight: FontWeight.w300)),
              TextSpan(text: GetTimeAgo.parse(_hotThread.publishAt,locale: locale.scriptCode)),
            ],
          ),
        ),
        trailing: getTailingWidget(),
        onTap: () async {
          await Navigator.push(
              context,
              platformPageRoute(context:context,builder: (context) => ViewThreadPage( _discuz,  _user, _hotThread.tid,))
          );
        },


      ),
    );
  }


}