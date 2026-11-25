import 'dart:developer';

import 'package:flutter/widgets.dart';

import '../database/AppDatabase.dart';
import '../generated/l10n.dart';
import '../utility/PlatformAdaptiveWidgets.dart';

class PrivateMessageStorageNotice extends StatefulWidget {
  const PrivateMessageStorageNotice({required this.child, super.key});

  final Widget child;

  @override
  State<PrivateMessageStorageNotice> createState() =>
      _PrivateMessageStorageNoticeState();
}

class _PrivateMessageStorageNoticeState
    extends State<PrivateMessageStorageNotice> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _recover());
  }

  Future<void> _recover() async {
    try {
      await AppDatabase.getPrivateMessageCacheDao();
      final recoveredStore =
          await AppDatabase.pendingPrivateMessageRecoveryNotice();
      if (!mounted || recoveredStore == null) return;
      final strings = S.of(context);
      await showPlatformAlert(
        context: context,
        title: strings.privateMessageRecoveryTitle,
        message: strings.privateMessageRecoveryMessage,
        actions: [
          PlatformAlertAction(label: strings.ok, isDefaultAction: true),
        ],
      );
      await AppDatabase.acknowledgePrivateMessageRecovery(recoveredStore);
    } catch (error) {
      log('Local private-message storage unavailable (${error.runtimeType})');
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
