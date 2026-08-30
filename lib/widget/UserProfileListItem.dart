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
  final Color titleColor;

  // 描述
  final String? describe;
  final Color describeColor;

  // 右侧控件
  final Widget? rightWidget;

  // 构造函数
  const UserProfileListItem({
    super.key,
    this.onPressed,
    this.icon,
    this.title,
    this.titleColor = Colors.black,
    this.describe,
    this.describeColor = Colors.grey,
    this.rightWidget,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: PlatformListTile(
        contentPadding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        onTap: onPressed,
        leading: icon == null
            ? null
            : SizedBox.square(
                dimension: 32,
                child: icon,
              ),
        title: title == null
            ? const SizedBox.shrink()
            : Text(
                title!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: titleColor,
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
                  color: describeColor,
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
