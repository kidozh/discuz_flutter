import 'package:discuz_flutter/dao/DiscuzAuthenticationDao.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/utility/SecureStorageUtils.dart';
import 'package:flutter/material.dart';

/// Must be called after the caller's normal authentication/consent flow.
Future<DiscuzAuthenticationDao?> openPasswordStoreWithRecovery(
  BuildContext context, {
  Future<DiscuzAuthenticationDao> Function()? openStore,
  Future<DiscuzAuthenticationDao> Function()? createStore,
}) async {
  try {
    return await (openStore ?? SecureStorageUtils.getDiscuzAuthenticationDao)();
  } catch (_) {
    if (!context.mounted) return null;
    final confirmed = await showPlatformDialog<bool>(
      context: context,
      builder: (dialogContext) => PlatformAlertDialog(
        title: Text(S.of(dialogContext).passwordRecoveryTitle),
        content: Text(S.of(dialogContext).passwordRecoveryMessage),
        actions: [
          PlatformDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(S.of(dialogContext).cancel),
          ),
          PlatformDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(S.of(dialogContext).passwordRecoveryCreate),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return null;
    return (createStore ?? SecureStorageUtils.createNewPasswordStore)();
  }
}
