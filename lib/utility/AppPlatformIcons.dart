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
}