import '../utility/DashboardPreferences.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../JsonResult/DisplayForumResult.dart';
import '../entity/DiscuzError.dart';
import '../generated/l10n.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../screen/EmptyScreen.dart';
import '../utility/KeylolPortalParser.dart';
import '../utility/NetworkUtils.dart';
import 'ErrorCard.dart';
import 'ForumThreadWidget.dart';
import 'KeylolTopicTabs.dart';
import 'LoadingStateWidget.dart';

class KeylolMobileTopicWidget extends StatefulWidget {
  final ValueChanged<int>? onSelectTid;

  const KeylolMobileTopicWidget({super.key, this.onSelectTid});

  @override
  State<KeylolMobileTopicWidget> createState() => _KeylolMobileTopicState();
}

class _KeylolMobileTopicState extends State<KeylolMobileTopicWidget> {
  bool _isLoading = true;
  List<KeylolPortalTopic> _topics = [];
  DiscuzError? _error;
  CancelToken? _request;

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  Future<void> _loadTopics() async {
    _request?.cancel();
    final request = CancelToken();
    _request = request;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final user = context.read<DiscuzAndUserNotifier>().user;
      final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
      if (!mounted || request.isCancelled) return;
      dio.options.connectTimeout = const Duration(seconds: 20);
      final response = await dio.get<String>(
        'https://keylol.com',
        cancelToken: request,
        options: Options(
          responseType: ResponseType.plain,
          receiveTimeout: const Duration(seconds: 20),
        ),
      );
      if (!mounted || request.isCancelled) return;
      final topics = parseKeylolPortalTopics(response.data ?? '');
      setState(() {
        _topics = topics;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted || request.isCancelled) return;
      setState(() {
        _isLoading = false;
        _error = DiscuzError(
          'keylol_portal_load_failed',
          S.of(context).loadFailed,
          dioError: error is DioException ? error : null,
        );
      });
    }
  }

  @override
  void dispose() {
    _request?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final source = context.watch<DiscuzAndUserNotifier>();
    final discuz = source.discuz;
    if (discuz == null || !DashboardPreferences.isKeylol(discuz.baseURL)) {
      return const SizedBox.shrink();
    }
    if (_isLoading) return const Center(child: LoadingStateWidget());
    if (_error != null) return ErrorCard(_error!, _loadTopics);
    if (_topics.isEmpty) return EmptyScreen();
    return KeylolTopicTabs(
      titles: _topics.map((topic) => topic.title).toList(),
      topicBuilder: (context, topicIndex) {
        final threads = _topics[topicIndex].threads;
        return ListView.builder(
          itemCount: threads.length,
          itemBuilder: (context, index) {
            final item = threads[index];
            final threadType = ThreadType()..idNameMap = {'0': item.forum};
            return ForumThreadWidget(
              discuz,
              source.user,
              item.convertToForumThread(),
              threadType,
              widget.onSelectTid,
            );
          },
        );
      },
    );
  }
}
