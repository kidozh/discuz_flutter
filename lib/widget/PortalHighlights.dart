import 'package:flutter/material.dart';
import 'package:html/parser.dart' show parseFragment;
import '../client/ForumInteractionClient.dart';
import '../entity/Discuz.dart';
import '../entity/User.dart';
import '../generated/l10n.dart';
import '../JsonResult/DiscuzIndexResult.dart';
import 'ForumPartitionWidget.dart';
import '../utility/NetworkUtils.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import '../utility/discuz_json.dart';

class PortalHighlights extends StatefulWidget {
  final Discuz discuz;
  final User? user;
  final int refresh;
  final Future<ForumInteractionClient> Function()? createClient;
  const PortalHighlights({
    super.key,
    required this.discuz,
    this.user,
    required this.refresh,
    this.createClient,
  });
  @override
  State<PortalHighlights> createState() => _PortalHighlightsState();
}

class _PortalHighlightsState extends State<PortalHighlights> {
  List<Forum> forums = [];
  bool loading = true, failed = false;
  int generation = 0;
  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void didUpdateWidget(covariant PortalHighlights oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refresh != widget.refresh) load();
  }

  Future<void> load() async {
    final run = ++generation;
    setState(() => loading = true);
    try {
      final api = widget.createClient != null
          ? await widget.createClient!()
          : ForumInteractionClient(
              await NetworkUtils.getDioWithPersistCookieJar(widget.user),
              widget.discuz.baseURL,
            );
      final reply = await api.request('hotforum', {});
      reply.requireData('data');
      final rows = forumRows(reply.variables['data'])
          .map(discuzMap)
          .where((row) => discuzInt(row['fid']) > 0)
          .take(4)
          .map(
            (row) => Forum()
              ..fid = discuzString(row['fid'])
              ..name = parseFragment(discuzString(row['name'])).text ?? ''
              ..todayPosts = row['todayposts'] == null
                  ? '0'
                  : discuzString(row['todayposts'])
              ..threads = discuzString(row['threads'])
              ..posts = discuzString(row['posts']),
          )
          .toList();
      if (mounted && run == generation)
        setState(() {
          forums = rows;
          failed = false;
        });
    } catch (_) {
      if (mounted && run == generation) setState(() => failed = true);
    } finally {
      if (mounted && run == generation) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (forums.isEmpty && !loading && !failed) return const SizedBox.shrink();
    final partition = ForumPartition()
      ..name = S.of(context).hotForums
      ..forumIdList = forums.map((forum) => forum.fid).toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ForumPartitionWidget(widget.discuz, widget.user, partition, forums),
        if (loading && forums.isEmpty)
          Padding(
            padding: const EdgeInsets.all(12),
            child: PlatformCircularProgressIndicator(),
          ),
        if (failed)
          PlatformTextButton(
            onPressed: loading ? null : load,
            child: Text(S.of(context).retry),
          ),
      ],
    );
  }
}
