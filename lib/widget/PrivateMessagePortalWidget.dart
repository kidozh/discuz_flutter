import 'package:discuz_flutter/JsonResult/PrivateMessagePortalResult.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/page/PrivateMessageDetailPage.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:discuz_flutter/widget/UserAvatar.dart';
import 'package:flutter/material.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';

class PrivateMessagePortalWidget extends StatelessWidget {
  final PrivateMessagePortal _privateMessagePortal;
  final Discuz _discuz;

  final VoidCallback? onConversationClosed;

  const PrivateMessagePortalWidget(
    this._discuz,
    this._privateMessagePortal, {
    this.onConversationClosed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PlatformCard(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: _privateMessagePortal.isNew
          ? Theme.of(context).colorScheme.primaryContainer
          : null,
      child: PlatformListTile(
        leading: Semantics(
          label: _privateMessagePortal.isNew ? '新消息' : null,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              UserAvatar(
                _discuz,
                _privateMessagePortal.toUid,
                _privateMessagePortal.toUserName,
                size: 48,
              ),
              if (_privateMessagePortal.isNew)
                Positioned(
                  left: -3,
                  top: 18,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.surface,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        trailing: Icon(
          PlatformIcons(context).forward,
          size: 17,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),

        title: Row(
          children: [
            Expanded(
              child: Text(
                _privateMessagePortal.toUserName.isNotEmpty
                    ? _privateMessagePortal.toUserName
                    : _privateMessagePortal.subject,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _privateMessagePortal.readableString,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w400,
                  ),
            ),
          ],
        ),
        subtitle: Text(
          _privateMessagePortal.message,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w400,
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
        onTap: () async {
          VibrationUtils.vibrateWithClickIfPossible();
          await Navigator.push(
              context,
              platformPageRoute(
                  context: context,
                  iosTitle: _privateMessagePortal.toUserName,
                  builder: (context) => PrivateMessageDetailScreen(
                      _privateMessagePortal.toUid,
                      _privateMessagePortal.toUserName)));
          onConversationClosed?.call();
        },
      ),
    );
  }
}
