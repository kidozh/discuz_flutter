import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../dao/ai_conversation_dao.dart';
import '../entity/ai_conversation.dart';
import '../generated/l10n.dart';
import '../provider/UserPreferenceNotifierProvider.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import 'ai_chat_page.dart';

class AiChatHistoryPage extends StatefulWidget {
  const AiChatHistoryPage({
    super.key,
    this.loadHistory = AiConversationDao.open,
  });

  final Future<AiConversationDao> Function() loadHistory;

  @override
  State<AiChatHistoryPage> createState() => _AiChatHistoryPageState();
}

class _AiChatHistoryPageState extends State<AiChatHistoryPage> {
  late Future<AiConversationDao> _dao = widget.loadHistory();

  void _openChat(AiConversationDao dao, [AiConversation? conversation]) {
    Navigator.push(
      context,
      platformPageRoute(
        context: context,
        builder: (_) => AiChatPage(dao: dao, conversation: conversation),
      ),
    );
  }

  Future<void> _delete(AiConversationDao dao, AiConversation conversation) =>
      showPlatformAlert(
        context: context,
        title: S.of(context).aiChatDelete,
        message: S.of(context).aiChatDeleteConfirmation,
        actions: [
          PlatformAlertAction(
            label: S.of(context).cancel,
            isCancelAction: true,
          ),
          PlatformAlertAction(
            label: S.of(context).aiChatDelete,
            isDestructiveAction: true,
            onPressed: () async {
              await dao.delete(conversation.id);
            },
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final preferences = context.watch<UserPreferenceNotifierProvider>();
    final canChat =
        preferences.appleIntelligenceEnabled &&
        preferences.appleIntelligenceAvailable;
    return FutureBuilder<AiConversationDao>(
      future: _dao,
      builder: (context, snapshot) => PlatformScaffold(
        iosContentPadding: true,
        iosContentBottomPadding: true,
        appBar: PlatformAppBar(
          title: Text(strings.appleIntelligenceUseHistory),
          trailingActions: [
            PlatformIconButton(
              icon: Icon(Icons.add, semanticLabel: strings.aiChatNew),
              onPressed: canChat && snapshot.hasData
                  ? () => _openChat(snapshot.data!)
                  : null,
            ),
          ],
        ),
        body: DefaultTextStyle(
          style: Theme.of(context).textTheme.bodyMedium!,
          child: snapshot.hasError
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(strings.aiChatHistoryLoadFailed),
                      PlatformTextButton(
                        onPressed: () =>
                            setState(() => _dao = widget.loadHistory()),
                        child: Text(strings.onDeviceAiRetry),
                      ),
                    ],
                  ),
                )
              : !snapshot.hasData
              ? const Center(child: PlatformCircularProgressIndicator())
              : ValueListenableBuilder(
                  valueListenable: snapshot.data!.box.listenable(),
                  builder: (context, _, child) {
                    final conversations = snapshot.data!.getAll();
                    if (conversations.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            strings.aiChatHistoryEmpty,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: conversations.length,
                      itemBuilder: (context, index) {
                        final conversation = conversations[index];
                        return PlatformListTile(
                          title: Text(
                            conversation.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            DateFormat.yMd().add_Hm().format(
                              conversation.updatedAt.toLocal(),
                            ),
                          ),
                          onTap: () => _openChat(snapshot.data!, conversation),
                          trailing: PlatformIconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              semanticLabel: strings.aiChatDelete,
                            ),
                            onPressed: () =>
                                _delete(snapshot.data!, conversation),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }
}
