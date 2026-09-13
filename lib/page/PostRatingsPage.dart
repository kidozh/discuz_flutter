import '../widget/PostRatingsCard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html;
import '../entity/Discuz.dart';
import '../entity/User.dart';
import '../generated/l10n.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../utility/NetworkUtils.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import 'InternalWebviewBrowserPage.dart';

class PostRatingRecord {
  final String credit, author, date, reason;
  PostRatingRecord(this.credit, this.author, this.date, this.reason);
}

class PostRatings {
  final List<PostRatingRecord> records;
  final String total;
  PostRatings(this.records, this.total);
  static PostRatings parse(String source) {
    final cdata = RegExp(r'<!\[CDATA\[([\s\S]*?)\]\]>').firstMatch(source);
    final doc = html.parse(cdata?.group(1) ?? source);
    final table = doc.querySelector('.floatwrap table.list');
    if (table == null) throw const FormatException('Unsupported rating list');
    final records = <PostRatingRecord>[];
    for (final row in table.querySelectorAll('tr')) {
      if (row.parent?.localName == 'thead') continue;
      final cells = row.children.where((e) => e.localName == 'td').toList();
      if (cells.length != 4) continue;
      records.add(
        PostRatingRecord(
          cells[0].text.trim(),
          cells[1].text.trim(),
          cells[2].text.trim(),
          cells[3].text.trim(),
        ),
      );
    }
    return PostRatings(records, doc.querySelector('.o.pns')?.text.trim() ?? '');
  }
}

class PostRatingsPage extends StatefulWidget {
  final Discuz discuz;
  final User? user;
  final int tid, pid;
  const PostRatingsPage({
    super.key,
    required this.discuz,
    required this.user,
    required this.tid,
    required this.pid,
  });
  @override
  State<PostRatingsPage> createState() => _PostRatingsPageState();
}

class _PostRatingsPageState extends State<PostRatingsPage> {
  PostRatings? result;
  bool loading = true, failed = false;
  Uri get url =>
      Uri.parse('${widget.discuz.baseURL.replaceAll(RegExp(r'/+$'), '')}/')
          .resolve('forum.php')
          .replace(
            queryParameters: {
              'mod': 'misc',
              'action': 'viewratings',
              'tid': '${widget.tid}',
              'pid': '${widget.pid}',
            },
          );
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
    setState(() {
      loading = true;
      failed = false;
    });
    try {
      if (!sameAccount) return;
      final dio = await NetworkUtils.getDioWithPersistCookieJar(widget.user);
      final response = await dio.getUri<String>(
        url.replace(
          queryParameters: {
            ...url.queryParameters,
            'inajax': '1',
            'infloat': 'yes',
            'mobile': 'no',
          },
        ),
        options: Options(responseType: ResponseType.plain),
      );
      final parsed = PostRatings.parse(response.data ?? '');
      if (mounted && sameAccount) result = parsed;
    } catch (_) {
      if (mounted) failed = true;
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<DiscuzAndUserNotifier>();
    final s = S.of(context);
    return PlatformScaffold(
      iosContentPadding: true,
      appBar: PlatformAppBar(
        title: Text(s.postViewRatings),
        trailingActions: [
          PlatformIconButton(
            liquidGlassSymbol: 'arrow.clockwise',
            icon: Icon(PlatformIcons(context).refresh),
            onPressed: loading ? null : load,
          ),
          PlatformIconButton(
            liquidGlassSymbol: 'safari',
            icon: const Icon(Icons.open_in_browser),
            onPressed: !sameAccount
                ? null
                : () => Navigator.push(
                    context,
                    platformPageRoute(
                      context: context,
                      builder: (_) => InternalWebviewBrowserPage(
                        widget.discuz,
                        widget.user,
                        url.toString(),
                      ),
                    ),
                  ),
          ),
        ],
      ),
      body: !sameAccount
          ? Center(child: Text(s.forumAccountChanged))
          : loading
          ? const Center(child: PlatformCircularProgressIndicator())
          : failed
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(s.postRatingsUnavailable),
              ),
            )
          : CustomScrollView(
              slivers: [
                if (result?.records.isNotEmpty == true)
                  PostRatingsCard(
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
                    asSliver: true,
                  )
                else
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(s.forumEmpty),
                    ),
                  ),
              ],
            ),
    );
  }
}
