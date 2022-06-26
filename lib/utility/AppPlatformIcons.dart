import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';


extension PlatformIconsExt on BuildContext {
  /// Render either a Material or Cupertino icon based on the platform
  PlatformIcons get platformIcons => PlatformIcons(this);

  IconData platformIcon({
    required IconData material,
    required IconData cupertino,
  }) =>
      isMaterial(this) ? material : cupertino;
}

class AppPlatformIcons{
  AppPlatformIcons(this.context);

  final BuildContext context;

  IconData get privacyPolicyOutlined => isMaterial(context)? Icons.policy_outlined : CupertinoIcons.doc_text;

  IconData get termsOfServiceOutlined => isMaterial(context)? Icons.verified_user_outlined : CupertinoIcons.checkmark_shield;

  IconData get appThemeOutlined => isMaterial(context)? Icons.color_lens_outlined : CupertinoIcons.color_filter;

  IconData get appAppearanceOutlined => isMaterial(context)? Icons.highlight_outlined : CupertinoIcons.wand_rays;

  IconData get material3Outlined => isMaterial(context)? Icons.format_paint_outlined : CupertinoIcons.skew;

  IconData get signatureOutlined => isMaterial(context)? Icons.edit_outlined : CupertinoIcons.signature;

  IconData get typeSettingOutlined => isMaterial(context)? Icons.format_size_outlined : CupertinoIcons.textformat_alt;

  IconData get historyOutlined => isMaterial(context)? Icons.archive_outlined : CupertinoIcons.tray;

  IconData get pushServiceOutlined => isMaterial(context)? Icons.quickreply_outlined : CupertinoIcons.captions_bubble;

  IconData get pushServiceSolid => isMaterial(context)? Icons.quickreply : CupertinoIcons.captions_bubble_fill;

  IconData get thisDeviceSolid => isMaterial(context)? Icons.my_location : CupertinoIcons.location_fill;

  IconData get discuzPortalSolid => isMaterial(context)? Icons.forum : CupertinoIcons.bubble_left_bubble_right_fill;

  IconData get discuzPortalOutlined => isMaterial(context)? Icons.forum_outlined : CupertinoIcons.bubble_left_bubble_right;

  IconData get discuzExploreSolid => isMaterial(context)? Icons.explore : CupertinoIcons.compass_fill;

  IconData get discuzExploreOutlined => isMaterial(context)? Icons.explore_outlined : CupertinoIcons.compass;

  IconData get discuzNotificationSolid => isMaterial(context)? Icons.notifications : CupertinoIcons.square_stack_3d_down_right_fill;

  IconData get discuzNotificationOutlined => isMaterial(context)? Icons.notifications_outlined : CupertinoIcons.square_stack_3d_down_right;

  IconData get discuzMessageSolid => isMaterial(context)? Icons.message : CupertinoIcons.chat_bubble_fill;

  IconData get discuzMessageOutlined => isMaterial(context)? Icons.message_outlined : CupertinoIcons.chat_bubble;

  IconData get discuzSiteSolid => isMaterial(context)? Icons.home : CupertinoIcons.today_fill;

  IconData get discuzSiteOutlined => isMaterial(context)? Icons.home_outlined : CupertinoIcons.today;

  IconData get contactUserSolid => isMaterial(context)? Icons.message : CupertinoIcons.chat_bubble_fill;
}