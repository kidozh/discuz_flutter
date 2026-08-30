import 'package:flutter/material.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';

/// 列表项
class UserProfileListItem extends StatelessWidget {
  // 点击事件
  final VoidCallback? onPressed;

  // 图标
  final Widget? icon;

  // 标题
  final String? title;
  final Color? titleColor;

  // 描述
  final String? describe;
  final Color? describeColor;

  // 右侧控件
  final Widget? rightWidget;

  // 构造函数
  const UserProfileListItem({
    super.key,
    this.onPressed,
    this.icon,
    this.title,
    this.titleColor,
    this.describe,
    this.describeColor,
    this.rightWidget,
  });

  @override
  Widget build(BuildContext context) {
    final useAdaptiveForeground =
        usesAppleTranslucentSurface(context) && titleColor == Colors.white;
    final colors = Theme.of(context).colorScheme;
    final effectiveTitleColor = titleColor == null || useAdaptiveForeground
        ? colors.onSurface
        : titleColor;
    final effectiveDescribeColor = describeColor == null ||
            (usesAppleTranslucentSurface(context) &&
                describeColor == Colors.white)
        ? colors.onSurfaceVariant
        : describeColor;
    final effectiveIcon = icon == null
        ? null
        : useAdaptiveForeground
            ? ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.onSurfaceVariant,
                  BlendMode.srcIn,
                ),
                child: icon!,
              )
            : icon;

    return SizedBox(
      width: double.infinity,
      child: PlatformListTile(
        contentPadding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        onTap: onPressed,
        leading: effectiveIcon == null
            ? null
            : SizedBox.square(
                dimension: 32,
                child: effectiveIcon,
              ),
        title: title == null
            ? const SizedBox.shrink()
            : Text(
                title!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: effectiveTitleColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
        subtitle: describe == null
            ? null
            : Text(
                describe!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: effectiveDescribeColor,
                  fontSize: 14,
                  height: 1.25,
                ),
              ),
        trailing: rightWidget,
      ),
    );
  }
}

/// 空图标
class EmptyIcon extends Icon {
  const EmptyIcon() : super(Icons.hourglass_empty);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
