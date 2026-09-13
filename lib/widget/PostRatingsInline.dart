import 'PostRatingsCard.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../entity/Discuz.dart';
import '../entity/User.dart';
import '../page/PostRatingsPage.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../utility/DashboardPreferences.dart';
import '../utility/NetworkUtils.dart';

bool shouldLoadFirstPostRatings(String url, String views, bool first) =>
    first &&
    DashboardPreferences.isKeylol(url) &&
    (int.tryParse(views) ?? 0) > 50;

class PostRatingsInline extends StatefulWidget {
  final Discuz discuz;
  final User? user;
  final int tid, pid;
  final bool asSliver;
  const PostRatingsInline({
    super.key,
    required this.discuz,
    required this.user,
    required this.tid,
    required this.pid,
    this.asSliver = false,
  });
  @override
  State<PostRatingsInline> createState() => _PostRatingsInlineState();
}

class _PostRatingsInlineState extends State<PostRatingsInline> {
  PostRatings? result;
  bool get sameAccount {
    final account = context.read<DiscuzAndUserNotifier>();
    return account.discuz?.baseURL == widget.discuz.baseURL &&
        account.user?.uid == widget.user?.uid &&
        account.user?.auth == widget.user?.auth;
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    if (!DashboardPreferences.isKeylol(widget.discuz.baseURL) || !sameAccount)
      return;
    try {
      final dio = await NetworkUtils.getDioWithPersistCookieJar(widget.user);
      final uri =
          Uri.parse('${widget.discuz.baseURL.replaceAll(RegExp(r'/+$'), '')}/')
              .resolve('forum.php')
              .replace(
                queryParameters: {
                  'mod': 'misc',
                  'action': 'viewratings',
                  'tid': '${widget.tid}',
                  'pid': '${widget.pid}',
                  'inajax': '1',
                  'infloat': 'yes',
                  'mobile': 'no',
                },
              );
      final response = await dio.getUri<String>(
        uri,
        options: Options(responseType: ResponseType.plain),
      );
      final parsed = PostRatings.parse(response.data ?? '');
      if (mounted && sameAccount) setState(() => result = parsed);
    } catch (_) {
      // An unrated post returns a message rather than a table. Keep reading
      // uninterrupted; the explicit ratings page provides errors and retry.
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<DiscuzAndUserNotifier>();
    if (!sameAccount || result == null || result!.records.isEmpty) {
      return widget.asSliver
          ? const SliverToBoxAdapter(child: SizedBox.shrink())
          : const SizedBox.shrink();
    }
    return PostRatingsCard(
      total: result!.total,
      rows: result!.records
          .map(
            (record) => [
              record.credit,
              record.author,
              record.date,
              if (record.reason.isNotEmpty) record.reason,
            ].join(' · '),
          )
          .toList(),
      asSliver: widget.asSliver,
    );
  }
}
