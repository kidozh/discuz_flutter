import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/DiscuzNotification.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/CustomizeColor.dart';
import 'package:discuz_flutter/utility/TimeDisplayUtils.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/widget/DiscuzHtmlWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

// ignore: must_be_immutable
class DiscuzNotificationWidget extends StatelessWidget {
  DiscuzNotification _notification;
  Discuz _discuz;
  final ValueChanged<int>? onSelectTid;

  DiscuzNotificationWidget(this._discuz, this._notification, {this.onSelectTid});

  @override
  Widget build(BuildContext context) {
    Brightness brightness = MediaQuery.of(context).platformBrightness;
    return PlatformWidgetBuilder(
      cupertino: (context, child, platform){
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if(child!=null)
            child!,
            Divider(),
          ],
        );
      },
      material: (context, child, platform){
        return Card(
          elevation: 6.0,
          // color: brightness == Brightness.light? Colors.white: Colors.black45,
          // surfaceTintColor: brightness == Brightness.light? Colors.white: Colors.black45,
          child: Padding(
            padding: EdgeInsets.all(4.0),
            child: child,
          ),
        );
      },
      child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  if(_notification.author.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: CachedNetworkImage(
                      imageUrl: URLUtils.getAvatarURL(_discuz, _notification.authorId.toString()),
                      progressIndicatorBuilder: (context, url, downloadProgress) => CircularProgressIndicator(value: downloadProgress.progress),
                      errorWidget: (context, url, error) => Container(
                        width: 16.0,
                        height: 16.0,
                        child: CircleAvatar(
                          backgroundColor: CustomizeColor.getColorBackgroundById(_notification.uid),
                          child: Text(
                            _notification.author.length != 0
                                ? _notification.author[0].toUpperCase()
                                : S.of(context).notification[0].toUpperCase(),
                            style: TextStyle(color: Colors.white,fontSize: 12),
                          ),
                        ),
                      ),
                      imageBuilder: (context, imageProvider) => Container(
                        width: 24.0,
                        height: 24.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                      child: Row(
                        children: [
                          //SizedBox(width: 8.0,),
                          RichText(
                            text: TextSpan(
                              text: "",
                              style: Theme.of(context).textTheme.labelLarge,
                              children: <TextSpan>[
                                if(_notification.author.isNotEmpty)
                                  TextSpan(text: _notification.author, style: TextStyle(fontWeight: FontWeight.bold)),
                                if(_notification.author.isEmpty)
                                  TextSpan(text: _notification.type.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),

                              ],
                            ),
                          ),
                          Spacer(),
                          Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Text(TimeDisplayUtils.getLocaledTimeDisplay(context,_notification.dateline),
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                            ),
                        ],
                      )
                  )
                ],
              ),
              SizedBox(height: 8.0,),
              // rich text rendering
              DiscuzHtmlWidget(_discuz,_notification.note, onSelectTid: this.onSelectTid,)
            ],
          )
      ),
    );
  }
}
