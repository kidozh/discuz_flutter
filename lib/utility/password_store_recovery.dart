import 'package:discuz_flutter/dao/DiscuzAuthenticationDao.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/utility/SecureStorageUtils.dart';
import 'package:flutter/material.dart';

import 'encrypted_box_key.dart';

/// Must be called after the caller's normal authentication/consent flow.
Future<DiscuzAuthenticationDao?> openPasswordStoreWithRecovery(
  BuildContext context, {
  Future<DiscuzAuthenticationDao> Function()? openStore,
  Future<DiscuzAuthenticationDao> Function()? createStore,
}) async {
  try {
    return await (openStore ?? SecureStorageUtils.getDiscuzAuthenticationDao)();
  } on UnreadableEncryptedStore {
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
    try {
      return await (createStore ?? SecureStorageUtils.createNewPasswordStore)();
    } catch (_) {
      // The old store stays active if creating its replacement fails.
    }
  } catch (_) {
    // Temporary read failures can succeed after the user unlocks the device.
  }
  if (!context.mounted) return null;
  final strings = S.of(context);
  await showPlatformAlert(
    context: context,
    title: strings.passwordRecoveryTitle,
    message: strings.passwordStorageUnavailable,
    actions: [PlatformAlertAction(label: strings.ok, isDefaultAction: true)],
  );
  return null;
}
