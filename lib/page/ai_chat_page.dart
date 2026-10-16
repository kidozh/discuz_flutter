import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../dao/ai_conversation_dao.dart';
import '../entity/ai_conversation.dart';
import '../generated/l10n.dart';
import '../provider/UserPreferenceNotifierProvider.dart';
import '../utility/FoundationModelFrameworkUtils.dart';
import '../utility/OnDeviceAiService.dart';
import '../utility/PlatformAdaptiveWidgets.dart';

typedef AiChatReply = Future<String> Function(
  AiConversation conversation,
  String question,
);

class AiChatPage extends StatefulWidget {
  const AiChatPage({
    super.key,
    required this.dao,
    this.conversation,
    this.reply,
  });

  final AiConversationDao dao;
  final AiConversation? conversation;
  final AiChatReply? reply;

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  late AiConversation _conversation =
      widget.conversation ??
      AiConversation(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        updatedAt: DateTime.now(),
      );
  bool _busy = false;
  String? _pendingQuestion;
  String? _error;
  // A generated reply survives a storage failure so retrying does not generate twice.
  AiConversation? _unsaved;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final preferences = context.read<UserPreferenceNotifierProvider>();
    if (_busy ||
        !preferences.appleIntelligenceEnabled ||
        !preferences.appleIntelligenceAvailable) {
      return;
    }
    final question = _input.text.trim();
    if (question.isEmpty) return;
    setState(() {
      _busy = true;
      _error = null;
      _pendingQuestion = question;
    });
    _scrollToEnd();
    try {
      final unsaved = _unsaved;
      AiConversation next;
      if (unsaved != null && unsaved.turns.last.question == question) {
        next = unsaved;
      } else {
        final answer = widget.reply != null
            ? await widget.reply!(_conversation, question)
            : await OnDeviceAiService.chat(
                conversation: _conversation,
                question: question,
                guardrailLevel:
                    FoundationModelFrameworkUtils.guardrailLevelFromName(
                      preferences.appleIntelligenceGuardrail,
                    ),
              );
        if (answer.trim().isEmpty) throw StateError('Empty reply');
        next = _conversation.append(
          AiChatTurn(question: question, answer: answer),
        );
      }
      _unsaved = next;
      await widget.dao.save(next);
      _unsaved = null;
      if (!mounted) return;
      setState(() {
        _conversation = next;
        _input.clear();
      });
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = _unsaved == null
              ? S.of(context).aiChatRequestFailed
              : S.of(context).aiChatSaveFailed,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _pendingQuestion = null;
        });
        _scrollToEnd();
      }
    }
  }

  Widget _message(String text, {required bool user}) => Align(
    alignment: user ? Alignment.centerRight : Alignment.centerLeft,
    child: PlatformLiquidGlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(14),
      tintColor: user ? Theme.of(context).colorScheme.primary : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user ? S.of(context).aiChatYou : 'AI',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 6),
          SelectableText(text),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final preferences = context.watch<UserPreferenceNotifierProvider>();
    final canChat =
        preferences.appleIntelligenceEnabled &&
        preferences.appleIntelligenceAvailable;
    return PlatformScaffold(
      appBar: PlatformAppBar(title: Text(strings.aiChatTitle)),
      body: DefaultTextStyle(
        style: Theme.of(context).textTheme.bodyMedium!,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: _conversation.turns.isEmpty && !_busy
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            strings.aiChatStart,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView(
                        controller: _scroll,
                        children: [
                          for (final turn in _conversation.turns) ...[
                            _message(turn.question, user: true),
                            _message(turn.answer, user: false),
                          ],
                          if (_pendingQuestion != null)
                            _message(_pendingQuestion!, user: true),
                          if (_busy)
                            const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: PlatformCircularProgressIndicator(),
                              ),
                            ),
                        ],
                      ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              if (!canChat)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    strings.aiChatUnavailable,
                    textAlign: TextAlign.center,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: PlatformTextField(
                        controller: _input,
                        hintText: strings.aiChatInput,
                        minLines: 1,
                        maxLines: 5,
                        maxLength: 1200,
                        enabled: canChat && !_busy,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    PlatformIconButton(
                      icon: Icon(Icons.send, semanticLabel: strings.aiChatSend),
                      onPressed:
                          canChat && !_busy && _input.text.trim().isNotEmpty
                          ? _send
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
