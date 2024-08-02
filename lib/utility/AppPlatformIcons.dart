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

  IconData get discuzNotificationSolid => isMaterial(context)? Icons.notifications : CupertinoIcons.bell_circle_fill;

  IconData get discuzNotificationOutlined => isMaterial(context)? Icons.notifications_outlined : CupertinoIcons.bell_circle;

  IconData get discuzMessageSolid => isMaterial(context)? Icons.message : CupertinoIcons.chat_bubble_fill;

  IconData get discuzMessageOutlined => isMaterial(context)? Icons.message_outlined : CupertinoIcons.chat_bubble;

  IconData get discuzSiteSolid => isMaterial(context)? Icons.home : CupertinoIcons.today_fill;

  IconData get discuzSiteOutlined => isMaterial(context)? Icons.home_outlined : CupertinoIcons.today;

  IconData get contactUserSolid => isMaterial(context)? Icons.message : CupertinoIcons.chat_bubble_fill;

  IconData get shortcutSolid => isMaterial(context)? Icons.location_pin : CupertinoIcons.compass_fill;

  IconData get filterSolid => isMaterial(context)? Icons.filter_alt : CupertinoIcons.square_stack_3d_up_fill;

  IconData get filterOutlined => isMaterial(context)? Icons.filter_alt_outlined : CupertinoIcons.square_stack_3d_up;

  IconData get publishPostOutlined => isMaterial(context)? Icons.add_circle_outline : CupertinoIcons.add_circled;

  IconData get goToSolid => isMaterial(context)? Icons.arrow_forward : CupertinoIcons.arrow_right;

  IconData get postThreadSolid => isMaterial(context)? Icons.send : CupertinoIcons.arrowshape_turn_up_right_fill;

  IconData get checkCircleSolid => isMaterial(context)? Icons.check_circle : CupertinoIcons.check_mark_circled_solid;

  IconData get checkCircleOutlined => isMaterial(context)? Icons.check_circle_outline : CupertinoIcons.check_mark_circled;

  IconData get check => isMaterial(context)? Icons.check : CupertinoIcons.check_mark;

  IconData get optionWinnerOutlined => isMaterial(context)? Icons.stars : CupertinoIcons.star_circle_fill;

  IconData get pinContentSolid => isMaterial(context)? Icons.vertical_align_top : CupertinoIcons.map_pin;

  IconData get imageSolid => isMaterial(context)? Icons.image : CupertinoIcons.film_fill;

  IconData get forumSolid => isMaterial(context)? Icons.forum : CupertinoIcons.chat_bubble_2_fill;

  IconData get forumOutlined => isMaterial(context)? Icons.forum_outlined : CupertinoIcons.chat_bubble_2;

  IconData get formatSizeSolid => isMaterial(context)? Icons.format_size : CupertinoIcons.textformat_size;

  IconData get manageDiscuzSolid => isMaterial(context)? Icons.account_tree : CupertinoIcons.rectangle_fill_on_rectangle_angled_fill;

  IconData get menuSolid => isMaterial(context)? Icons.menu : CupertinoIcons.line_horizontal_3;

  IconData get selectedThreadSolid => isMaterial(context)? Icons.play_circle : CupertinoIcons.arrowtriangle_right_circle_fill;

  IconData get hapticFeedbackOutlined => isMaterial(context)? Icons.vibration_outlined : CupertinoIcons.dial;

  IconData get pictureBedOutlined => isMaterial(context)? Icons.photo_album_outlined : CupertinoIcons.square_stack;

  IconData get chevronSolid => isMaterial(context)? Icons.arrow_forward : CupertinoIcons.chevron_forward;

  IconData get subscribeChannelSolid => isMaterial(context)? Icons.subscriptions : CupertinoIcons.news_solid;

  IconData get notificationSolid => isMaterial(context)? Icons.notifications : CupertinoIcons.bell_fill;

  IconData get authenticationSecureSolid => isMaterial(context)? Icons.lock : CupertinoIcons.lock_shield_fill;

  IconData get authenticationSecureOutline => isMaterial(context)? Icons.lock_outline : CupertinoIcons.lock_shield;

  IconData get authenticationUnableSolid => isMaterial(context)? Icons.error_outline : CupertinoIcons.lock_slash_fill;

  IconData get deviceNotSupportSolid => isMaterial(context)? Icons.perm_device_info : CupertinoIcons.hand_raised_slash_fill;

  IconData get authenticationFailedSolid => isMaterial(context)? Icons.lock : CupertinoIcons.lock_fill;

  IconData get saveSolid => isMaterial(context)? Icons.save : CupertinoIcons.arrow_down_doc_fill;

  IconData get saveOutline => isMaterial(context)? Icons.save_outlined : CupertinoIcons.download_circle;

  IconData get typographyOutline => isMaterial(context)? Icons.translate : CupertinoIcons.textbox;

  IconData get iframeOutline => isMaterial(context)? Icons.link_outlined : CupertinoIcons.arrow_down_left_circle;

  IconData get fontWeightOutline => isMaterial(context)? Icons.font_download_outlined : CupertinoIcons.f_cursive_circle;

  IconData get linkSolid => isMaterial(context)? Icons.link_rounded : CupertinoIcons.link;

  IconData get compactParagraphOutline => isMaterial(context)? Icons.text_fields : CupertinoIcons.text_insert;

  IconData get dynamicSchemeVariantOutlined => isMaterial(context)? Icons.colorize : CupertinoIcons.paintbrush;

  IconData get dynamicSchemeDescriptionOutlined => isMaterial(context)? Icons.invert_colors_on : CupertinoIcons.brightness;

  IconData get reportInformationToUsSolid => isMaterial(context)? Icons.settings_applications : CupertinoIcons.hammer_fill;

  IconData get recommendDiscuzToUsSolid => isMaterial(context)? Icons.query_stats_sharp : CupertinoIcons.question_square;

  IconData get addDiscuzSolid => isMaterial(context)? Icons.view_in_ar_rounded : CupertinoIcons.bubble_left_bubble_right_fill;

  IconData get adminPostSolid => isMaterial(context)? Icons.settings : CupertinoIcons.hammer_fill;
}