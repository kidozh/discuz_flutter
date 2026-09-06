import 'dart:async';
import 'dart:developer';

import 'package:discuz_flutter/JsonResult/PrivateMessageDetailResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/DiscuzError.dart';
import 'package:discuz_flutter/entity/PrivateMessageCache.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/screen/NullDiscuzScreen.dart';
import 'package:discuz_flutter/screen/NullUserScreen.dart';
import 'package:discuz_flutter/screen/SmileyListScreen.dart';
import 'package:discuz_flutter/utility/AppPlatformIcons.dart';
import 'package:discuz_flutter/utility/EasyRefreshUtils.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:discuz_flutter/widget/ErrorCard.dart';
import 'package:discuz_flutter/widget/PrivateMessageDetailWidget.dart';
import 'package:discuz_flutter/widget/thread_reply_composer.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

import 'UserProfilePage.dart';

class PrivateMessageDetailScreen extends StatelessWidget {
  final int toUid;
  final String toUsername;

  const PrivateMessageDetailScreen(this.toUid, this.toUsername, {super.key});

  @override
  Widget build(BuildContext context) =>
      PrivateMessageDetailPage(toUid: toUid, toUsername: toUsername);
}

class PrivateMessageDetailPage extends StatefulWidget {
  final int toUid;
  final String toUsername;

  const PrivateMessageDetailPage({
    required this.toUid,
    required this.toUsername,
    super.key,
  });

  @override
  State<PrivateMessageDetailPage> createState() => _PrivateMessageDetailState();
}

class _PrivateMessageDetailState extends State<PrivateMessageDetailPage> {
  PrivateMessageDetailResult result = PrivateMessageDetailResult();
  DiscuzError? _error;
  int _nextPage = 1;
  List<PrivateMessageDetail> _messages = [];
  late final EasyRefreshController _refreshController;
  late final TextEditingController _textController;
  final FocusNode _composerFocus =
      FocusNode(debugLabel: 'private-message-input');
  bool _showSmiley = false;
  bool _requestInFlight = false;
  bool _sending = false;
  bool _hasLoaded = false;
  String? _accountIdentity;
  int _generation = 0;
  final Set<int> _pendingMessageIds = <int>{};
  final Map<int, String> _failedMessages = <int, String>{};

  bool get _canSend =>
      _hasLoaded && !_sending && _textController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _refreshController = EasyRefreshController(
      controlFinishLoad: true,
      controlFinishRefresh: true,
    );
    _textController = TextEditingController()..addListener(_onTextChanged);
    _composerFocus.addListener(_onComposerFocusChanged);
  }

  void _onComposerFocusChanged() {
    if (_composerFocus.hasFocus && _showSmiley && mounted) {
      setState(() => _showSmiley = false);
    }
  }

  void _toggleSmiley() {
    VibrationUtils.vibrateWithClickIfPossible();
    if (_showSmiley) {
      setState(() => _showSmiley = false);
      _composerFocus.requestFocus();
    } else {
      _composerFocus.unfocus();
      setState(() => _showSmiley = true);
    }
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _textController
      ..removeListener(_onTextChanged)
      ..dispose();
    _refreshController.dispose();
    _composerFocus.dispose();
    super.dispose();
  }

  void _ensureInitialized(Discuz discuz, User user) {
    final identity = '${discuz.baseURL}#${user.uid}#${widget.toUid}';
    if (_accountIdentity == identity) return;
    _accountIdentity = identity;
    final generation = ++_generation;
    _nextPage = 1;
    _messages = [];
    _error = null;
    _hasLoaded = false;
    _pendingMessageIds.clear();
    _failedMessages.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || generation != _generation) return;
      await _loadCachedMessages(discuz, user, generation);
      if (!mounted || generation != _generation) return;
      await _refreshMessages(discuz, generation: generation);
    });
  }

  Future<void> _loadCachedMessages(
    Discuz discuz,
    User user,
    int generation,
  ) async {
    try {
      final dao = await AppDatabase.getPrivateMessageCacheDao();
      final cached = dao
          .findConversation(
            siteKey: discuz.baseURL,
            ownerUid: user.uid,
            peerUid: widget.toUid,
          )
          .map((entry) => entry.toMessage())
          .toList()
        ..sort(_compareMessagesNewestFirst);
      if (!mounted || generation != _generation || cached.isEmpty) return;
      setState(() => _messages = cached);
      unawaited(dao.deleteExpired());
    } catch (error) {
      log('Unable to load private-message cache: $error');
    }
  }

  Future<void> _cacheMessages(
    Discuz discuz,
    User user,
    List<PrivateMessageDetail> messages,
  ) async {
    if (messages.isEmpty) return;
    try {
      final dao = await AppDatabase.getPrivateMessageCacheDao();
      await dao.upsertMessages([
        for (final message in messages)
          PrivateMessageCache.fromMessage(
            siteKey: discuz.baseURL,
            ownerUid: user.uid,
            peerUid: widget.toUid,
            message: message,
          ),
      ]);
    } catch (error) {
      log('Unable to cache private messages: $error');
    }
  }

  Future<IndicatorResult> _refreshMessages(
    Discuz discuz, {
    int? generation,
  }) {
    _nextPage = 1;
    _refreshController.resetFooter();
    return _loadMessages(
      discuz,
      generation: generation ?? _generation,
      replace: true,
    );
  }

  Future<IndicatorResult> _loadMessages(
    Discuz discuz, {
    required int generation,
    bool replace = false,
  }) async {
    if (_requestInFlight) return IndicatorResult.fail;
    final user =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
    if (user == null) return IndicatorResult.fail;
    _requestInFlight = true;
    final requestPage = _nextPage;
    try {
      final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
      final client = MobileApiClient(dio, baseUrl: discuz.baseURL);
      final value =
          await client.privateMessageDetailResult(widget.toUid, requestPage);
      if (!mounted || generation != _generation) return IndicatorResult.fail;

      await _cacheMessages(discuz, user, value.variables.pmList);
      if (!mounted || generation != _generation) return IndicatorResult.fail;

      final merged = <String, PrivateMessageDetail>{};
      if (replace) {
        for (final message in _messages) {
          if (message.plid >= 0) merged[_messageIdentity(message)] = message;
        }
      } else {
        for (final message in _messages) {
          merged[_messageIdentity(message)] = message;
        }
      }
      for (final message in value.variables.pmList) {
        merged[_messageIdentity(message)] = message;
      }

      DiscuzError? nextError;
      if (value.variables.member_uid != user.uid) {
        nextError = DiscuzError(
          S.of(context).userExpiredTitle(user.username),
          S.of(context).userExpiredSubtitle,
        );
      } else if (value.errorResult != null) {
        nextError =
            DiscuzError(value.errorResult!.key, value.errorResult!.content);
      }
      setState(() {
        result = value;
        _error = nextError;
        _hasLoaded = true;
        _messages = merged.values.toList();
        // A reversed list expects index 0 to be the newest item so that it is
        // laid out beside the composer. Never rely on the server's page order:
        // Discuz installations differ on whether each page is ascending or
        // descending, and mixing pages otherwise scrambles the conversation.
        _messages.sort(_compareMessagesNewestFirst);
        _nextPage = requestPage + 1;
      });

      if (value.getErrorString() != null) {
        EasyLoading.showError(value.getErrorString()!);
      }
      final indicator = _messages.length >= value.variables.count ||
              value.variables.pmList.isEmpty
          ? IndicatorResult.noMore
          : IndicatorResult.success;
      _refreshController.finishRefresh(indicator);
      _refreshController.finishLoad(indicator);
      return indicator;
    } catch (error) {
      log('Unable to load private-message detail: $error');
      if (mounted && generation == _generation) {
        setState(() {
          _error = DiscuzError(error.runtimeType.toString(), error.toString());
        });
        _refreshController.finishRefresh(IndicatorResult.fail);
        _refreshController.finishLoad(IndicatorResult.fail);
      }
      return IndicatorResult.fail;
    } finally {
      _requestInFlight = false;
    }
  }

  String _messageIdentity(PrivateMessageDetail message) {
    if (message.pmId != 0) return 'pm:${message.pmId}';
    return '${message.plid}|${message.msgFromId}|${message.dateTimeString}|'
        '${message.message}';
  }

  int _compareMessagesNewestFirst(
    PrivateMessageDetail left,
    PrivateMessageDetail right,
  ) {
    final leftTime = _messageTime(left);
    final rightTime = _messageTime(right);
    if (leftTime != null && rightTime != null && leftTime != rightTime) {
      return rightTime.compareTo(leftTime);
    }
    if (left.pmId != 0 && right.pmId != 0 && left.pmId != right.pmId) {
      return right.pmId.compareTo(left.pmId);
    }
    return right.plid.compareTo(left.plid);
  }

  DateTime? _messageTime(PrivateMessageDetail message) {
    final normalized = message.readableString.trim();
    final match = RegExp(
      r'^(\d{4})-(\d{1,2})-(\d{1,2})\s+(\d{1,2}):(\d{1,2})',
    ).firstMatch(normalized);
    if (match == null) return null;
    return DateTime(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
      int.parse(match.group(4)!),
      int.parse(match.group(5)!),
    );
  }

  bool _messagesBelongToSameGroup(
    PrivateMessageDetail first,
    PrivateMessageDetail second,
  ) {
    if (first.msgFromId != second.msgFromId) return false;
    final firstTime = _messageTime(first);
    final secondTime = _messageTime(second);
    if (firstTime == null || secondTime == null) return true;
    return firstTime.difference(secondTime).abs() <= const Duration(minutes: 5);
  }

  bool _shouldShowTimestamp(
    PrivateMessageDetail message,
    PrivateMessageDetail? olderMessage,
  ) {
    if (olderMessage == null) return true;
    final time = _messageTime(message);
    final olderTime = _messageTime(olderMessage);
    if (time == null || olderTime == null) return false;
    return time.difference(olderTime).abs() >= const Duration(minutes: 15) ||
        time.day != olderTime.day ||
        time.month != olderTime.month ||
        time.year != olderTime.year;
  }

  Future<void> _sendMessage(Discuz discuz, {String? retryMessage}) async {
    final message = (retryMessage ?? _textController.text).trim();
    if ((_sending || !_hasLoaded) || message.isEmpty) return;
    final user =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
    if (user == null) return;
    final localId = -DateTime.now().microsecondsSinceEpoch;
    final optimisticMessage = PrivateMessageDetail()
      ..plid = localId
      ..toUid = widget.toUid
      ..msgFromId = user.uid
      ..msgFromName = user.username
      ..message = message
      ..dateTimeString = _formatMessageTime(DateTime.now());
    setState(() {
      _sending = true;
      _showSmiley = false;
      _pendingMessageIds.add(localId);
      _messages.insert(0, optimisticMessage);
    });
    if (retryMessage == null) _textController.clear();
    VibrationUtils.vibrateWithClickIfPossible();
    try {
      final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
      final client = MobileApiClient(dio, baseUrl: discuz.baseURL);
      final value = await client.sendPrivateMessageResult(
        result.variables.formHash,
        message,
        widget.toUid,
      );
      if (!mounted) return;
      if (value.errorResult?.key == 'do_success') {
        setState(() {
          _pendingMessageIds.remove(localId);
          _messages.removeWhere((entry) => entry.plid == localId);
        });
        VibrationUtils.vibrateSuccessfullyIfPossible();
        await _refreshMessages(discuz);
      } else {
        _markMessageFailed(localId, message);
      }
    } catch (error) {
      log('Unable to send private message: $error');
      _markMessageFailed(localId, message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _markMessageFailed(int localId, String message) {
    if (!mounted) return;
    VibrationUtils.vibrateErrorIfPossible();
    setState(() {
      _pendingMessageIds.remove(localId);
      _failedMessages[localId] = message;
    });
  }

  Future<void> _retryMessage(Discuz discuz, int localId) async {
    final message = _failedMessages[localId];
    if (message == null || _sending) return;
    setState(() {
      _failedMessages.remove(localId);
      _messages.removeWhere((entry) => entry.plid == localId);
    });
    await _sendMessage(discuz, retryMessage: message);
  }

  String _formatMessageTime(DateTime time) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${time.year}-${twoDigits(time.month)}-${twoDigits(time.day)} '
        '${twoDigits(time.hour)}:${twoDigits(time.minute)}';
  }

  void _insertSmiley(String rawCode) {
    final code = rawCode
        .substring(1, rawCode.length - 1)
        .replaceAll(r'\:', ':')
        .replaceAll(r'\{', '{');
    final text = _textController.text;
    final selection = _textController.selection;
    final start = selection.start < 0 ? text.length : selection.start;
    final end = selection.end < 0 ? text.length : selection.end;
    final newText = text.replaceRange(start, end, code);
    _textController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + code.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DiscuzAndUserNotifier>(
      builder: (context, discuzAndUser, child) {
        final discuz = discuzAndUser.discuz;
        final user = discuzAndUser.user;
        if (discuz == null) {
          return PlatformScaffold(
            appBar: PlatformAppBar(),
            body: NullDiscuzScreen(),
          );
        }
        if (user == null) {
          return PlatformScaffold(
            appBar: PlatformAppBar(),
            body: NullUserScreen(),
          );
        }
        _ensureInitialized(discuz, user);

        return PlatformScaffold(
          iosContentBottomPadding: true,
          iosContentPadding: true,
          appBar: PlatformAppBar(
            title: Text(widget.toUsername),
            trailingActions: [
              PlatformIconButton(
                liquidGlassSymbol: 'person.crop.circle',
                icon: Icon(
                  AppPlatformIcons(context).userProfileSolid,
                  semanticLabel: S.of(context).userProfile,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    platformPageRoute(
                      context: context,
                      iosTitle: S.of(context).userProfile,
                      builder: (context) => UserProfilePage(
                        discuz,
                        user,
                        widget.toUid,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: PlatformLiquidGlassPageBackdrop(
            child: CupertinoComposerViewport(
                child: Column(
              children: [
                if (_error != null)
                  ErrorCard(_error!, () => _refreshController.callRefresh()),
                Expanded(
                  child: EasyRefresh(
                    header: EasyRefreshUtils.i18nClassicHeader(context),
                    footer: EasyRefreshUtils.i18nClassicFooter(context),
                    controller: _refreshController,
                    refreshOnStart: false,
                    onRefresh: () => _refreshMessages(discuz),
                    onLoad: () =>
                        _loadMessages(discuz, generation: _generation),
                    child: ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        final newerMessage =
                            index > 0 ? _messages[index - 1] : null;
                        final olderMessage = index + 1 < _messages.length
                            ? _messages[index + 1]
                            : null;
                        final groupedWithNewer = newerMessage != null &&
                            _messagesBelongToSameGroup(message, newerMessage);
                        final groupedWithOlder = olderMessage != null &&
                            _messagesBelongToSameGroup(message, olderMessage);
                        final localId = message.plid;
                        return PrivateMessageDetailWidget(
                          discuz,
                          user,
                          message,
                          key: ValueKey(_messageIdentity(message)),
                          groupedWithNewer: groupedWithNewer,
                          groupedWithOlder: groupedWithOlder,
                          showTimestamp:
                              _shouldShowTimestamp(message, olderMessage),
                          isPending: _pendingMessageIds.contains(localId),
                          sendFailed: _failedMessages.containsKey(localId),
                          animateEntrance: _pendingMessageIds.contains(localId),
                          onRetry: _failedMessages.containsKey(localId)
                              ? () => _retryMessage(discuz, localId)
                              : null,
                        );
                      },
                    ),
                  ),
                ),
                if (visualStyle(context) == AppVisualStyle.cupertino)
                  CupertinoPrivateMessageComposer(
                    controller: _textController,
                    focusNode: _composerFocus,
                    panelVisible: _showSmiley,
                    sending: _sending,
                    canSend: _canSend,
                    onTogglePanel: _toggleSmiley,
                    onSend: () => _sendMessage(discuz),
                  )
                else
                  SafeArea(
                    top: false,
                    child: PlatformLiquidGlassCard(
                      margin: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                      padding: const EdgeInsets.all(6),
                      borderRadius: BorderRadius.circular(24),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          PlatformIconButton(
                            liquidGlassSymbol:
                                _showSmiley ? 'keyboard' : 'face.smiling',
                            liquidGlassButtonSize: 44,
                            liquidGlassIconSize: 17,
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 160),
                              child: Icon(
                                _showSmiley
                                    ? PlatformIcons(context).keyboard
                                    : PlatformIcons(context).smiley,
                                key: ValueKey(_showSmiley),
                                size: 20,
                                semanticLabel: S.of(context).emoijButtonTooltip,
                              ),
                            ),
                            onPressed: _toggleSmiley,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: PlatformTextField(
                              controller: _textController,
                              focusNode: _composerFocus,
                              minLines: 1,
                              maxLines: 4,
                              textInputAction: TextInputAction.newline,
                              onSubmitted: (_) => _sendMessage(discuz),
                            ),
                          ),
                          const SizedBox(width: 5),
                          if (_sending)
                            const SizedBox.square(
                              dimension: 44,
                              child: Center(
                                child: SizedBox.square(
                                  dimension: 18,
                                  child: PlatformCircularProgressIndicator(),
                                ),
                              ),
                            )
                          else
                            PlatformIconButton(
                              liquidGlassSymbol: 'arrow.up',
                              liquidGlassButtonSize: 44,
                              liquidGlassIconSize: 17,
                              color: _canSend
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                              onPressed:
                                  _canSend ? () => _sendMessage(discuz) : null,
                              icon: Icon(
                                PlatformIcons(context).upArrow,
                                size: 20,
                                color: _canSend
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).disabledColor,
                                semanticLabel: S.of(context).send,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                CupertinoKeyboardAccessory(
                    enabled: visualStyle(context) == AppVisualStyle.cupertino,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      reverseDuration: const Duration(milliseconds: 160),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: _showSmiley
                          ? SmileyListScreen(
                              (smiley) => _insertSmiley(smiley.code),
                            )
                          : const SizedBox.shrink(
                              key: ValueKey('private_message_smiley_hidden'),
                            ),
                    )),
              ],
            )),
          ),
        );
      },
    );
  }
}
