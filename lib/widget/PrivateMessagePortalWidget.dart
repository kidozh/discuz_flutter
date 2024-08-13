
import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/JsonResult/PrivateMessagePortalResult.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/PrivateMessageDetailPage.dart';
import 'package:discuz_flutter/page/UserProfilePage.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/utility/CustomizeColor.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:discuz_flutter/widget/UserAvatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class PrivateMessagePortalWidget extends StatelessWidget{

  PrivateMessagePortal _privateMessagePortal;
  Discuz _discuz;
  User? _user;

  PrivateMessagePortalWidget(this._discuz,this._user,this._privateMessagePortal);


  @override
  Widget build(BuildContext context) {
    User? user = Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
    int uid = 0;
    if(user != null){
      uid = user.uid;
    }

    return PlatformWidgetBuilder(
      material: (context, child, platform) => Card(
        elevation: 4.0,
        color: Theme.of(context).brightness == Brightness.light? Colors.white: Colors.white10,
        surfaceTintColor: Theme.of(context).brightness == Brightness.light? Colors.white: Colors.white10,
        child: Padding(padding: EdgeInsets.zero,
          child: child,
        ),
      ),
      cupertino: (context, child, platform) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if(child!=null)
            child,
          Divider()

        ],
      ),
      child: PlatformListTile(
        leading: UserAvatar(_discuz,  _privateMessagePortal.toUid, _privateMessagePortal.toUserName, size: 48,),

        title: Text(_privateMessagePortal.subject,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),
          maxLines: 1,
        ),
        subtitle: Text(
            "${_privateMessagePortal.msgFromName}: ${_privateMessagePortal.message}",
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w300
            ),
            maxLines: 1,
        ),

        // subtitle: RichText(
        //   text: TextSpan(
        //     text: "${_privateMessagePortal.msgFromName}:${_privateMessagePortal.message}",
        //     style: DefaultTextStyle.of(context).style,
        //     children: <TextSpan>[
        //       TextSpan(text: "\n"),
        //       TextSpan(text: _privateMessagePortal.toUserName),
        //       //TextSpan(text: S.of(context).publishAt, style: TextStyle(fontWeight: FontWeight.w300)),
        //       TextSpan(text: " · ",style: TextStyle(fontWeight: FontWeight.w300)),
        //       TextSpan(text: _privateMessagePortal.readableString),
        //     ],
        //   ),
        // ),
        trailing: _privateMessagePortal.isNew ? Icon(Icons.new_releases_outlined, color: Theme.of(context).colorScheme.primary,) :null,
        onTap: () async {
          VibrationUtils.vibrateWithClickIfPossible();
          await Navigator.push(
              context,
              platformPageRoute(context:context,builder: (context) => PrivateMessageDetailScreen(_privateMessagePortal.toUid, _privateMessagePortal.toUserName))
          );
        },


      ),
    );
  }


}