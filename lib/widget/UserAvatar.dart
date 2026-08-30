import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/CustomizeColor.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:flutter/material.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:provider/provider.dart';

import '../page/UserProfilePage.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../utility/VibrationUtils.dart';

class UserAvatar extends StatelessWidget {
  int uid = 0;
  String username = "";
  Discuz discuz;
  double? size = 16;
  bool? disableTap = false;

  double getSize() {
    return this.size == null ? 16 : this.size!;
  }

  UserAvatar(this.discuz, this.uid, this.username,
      {this.size, this.disableTap});

  @override
  Widget build(BuildContext context) {
    final avatarSize = getSize();
    final avatar = CachedNetworkImage(
      width: avatarSize,
      height: avatarSize,
      fit: BoxFit.cover,
      imageUrl: URLUtils.getAvatarURL(discuz, uid.toString()),
      progressIndicatorBuilder: (context, url, downloadProgress) => SizedBox(
        height: avatarSize,
        width: avatarSize,
        child: PlatformCircularProgressIndicator(
          material: (_, __) => MaterialProgressIndicatorData(
            value: downloadProgress.progress,
          ),
        ),
      ),
      errorWidget: (context, url, error) => SizedBox(
        width: avatarSize,
        height: avatarSize,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: CustomizeColor.getColorBackgroundById(uid),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                username.isNotEmpty
                    ? String.fromCharCode(username.runes.first).toUpperCase()
                    : S.of(context).anonymous,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: (avatarSize * 0.4).clamp(9.0, 16.0),
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      ),
      imageBuilder: (context, imageProvider) => DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
        ),
      ),
    );
    // touchable
    return InkWell(
      child: PlatformLiquidGlassAvatar(
        size: avatarSize,
        child: avatar,
      ),
      onTap: this.disableTap == true
          ? null
          : () async {
              User? user =
                  Provider.of<DiscuzAndUserNotifier>(context, listen: false)
                      .user;
              Discuz? discuz =
                  Provider.of<DiscuzAndUserNotifier>(context, listen: false)
                      .discuz;
              if (discuz != null) {
                VibrationUtils.vibrateWithClickIfPossible();
                await Navigator.push(
                    context,
                    platformPageRoute(
                        context: context,
                        iosTitle: S.of(context).userProfile,
                        builder: (context) => UserProfilePage(
                              discuz,
                              user,
                              uid,
                              username: username,
                            )));
              }
            },
    );
  }
}
