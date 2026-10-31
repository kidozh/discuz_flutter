// Interactive paired-simulator QA entry point. Build ONLY on dedicated test
// simulators with FLUTTER_TARGET=integration_test/apple_watch_pairing_qa.dart.
// Uses the production host, API client, cookie stack and native WCSession bridge.
// The loopback forum is explicitly synthetic; no real private account is used.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:discuz_flutter/JsonResult/BaseVariableResult.dart';
import 'package:discuz_flutter/JsonResult/DiscuzIndexResult.dart';
import 'package:discuz_flutter/JsonResult/ViewThreadResult.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/HotThread.dart';
import 'package:discuz_flutter/entity/Post.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/provider/DiscuzNotificationProvider.dart';
import 'package:discuz_flutter/provider/ReplyPostNotifierProvider.dart';
import 'package:discuz_flutter/provider/SelectedTidNotifierProvider.dart';
import 'package:discuz_flutter/provider/ThemeNotifierProvider.dart';
import 'package:discuz_flutter/provider/TypeSettingNotifierProvider.dart';
import 'package:discuz_flutter/provider/UserPreferenceNotifierProvider.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/utility/ToastUtils.dart';
import 'package:discuz_flutter/widget/apple_watch_companion_host.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await AppDatabase.initBoxes();
  final fixture = await WatchQaForum.start();
  final dao = await AppDatabase.getDiscuzDao();
  await dao.insertDiscuz(fixture.discuz);
  final selection = DiscuzAndUserNotifier()
    ..initDiscuz(fixture.discuz)
    ..setUser(fixture.user);
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    fixture.record('flutter_error', {'message': details.exceptionAsString()});
    previous?.call(details);
  };
  final navigator = GlobalKey<NavigatorState>();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: selection),
        ChangeNotifierProvider(create: (_) => DiscuzNotificationProvider()),
        ChangeNotifierProvider(create: (_) => SelectedTidNotifierProvider()),
        ChangeNotifierProvider(create: (_) => ReplyPostNotifierProvider()),
        ChangeNotifierProvider(create: (_) => ThemeNotifierProvider()),
        ChangeNotifierProvider(create: (_) => TypeSettingNotifierProvider()),
        ChangeNotifierProvider(
          create: (_) => UserPreferenceNotifierProvider()
            ..setAutoSummarizeEnabled(false)
            ..setAutoTranslateEnabled(false)
            ..adExemptHost = '127.0.0.1',
        ),
      ],
      child: AppleWatchCompanionHost(
        navigatorKey: navigator,
        child: PlatformProvider(
          initialPlatform: TargetPlatform.iOS,
          builder: (_) => MaterialApp(
            navigatorKey: navigator,
            debugShowCheckedModeBanner: false,
            locale: const Locale('zh', 'CN'),
            supportedLocales: S.delegate.supportedLocales,
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            theme: ThemeData(platform: TargetPlatform.iOS),
            builder: ToastUtils.easyLoadingBuilder(),
            home: WatchQaControls(fixture: fixture, selection: selection),
          ),
        ),
      ),
    ),
  );
}

class WatchQaForum extends ChangeNotifier {
  final HttpServer server;
  final File report;
  final List<Map<String, Object>> events = [];
  late final Discuz discuz = Discuz(
    'http://127.0.0.1:${server.port}',
    'X3.5',
    'utf-8',
    4,
    '0.0.0',
    '',
    false,
    '',
    '',
    '手表联调（测试数据）',
    'qa',
    'http://127.0.0.1:${server.port}/uc_server',
    '161',
  );
  int uid = 7;
  bool expired = false;
  bool offline = false;
  bool noticesRead = false;
  bool messagesRead = false;
  final List<String> sentMessages = [];
  final List<String> sentReplies = [];

  WatchQaForum(this.server, this.report);

  User get user => User(
    'qa-only-auth',
    'qa-only-salt',
    uid == 7 ? 'Alice 测试账号' : 'Bob 测试账号',
    '',
    1,
    uid,
    10,
    discuz,
  );

  static Future<WatchQaForum> start() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final directory = await getApplicationDocumentsDirectory();
    final fixture = WatchQaForum(
      server,
      File('${directory.path}/watch-qa-report.json'),
    );
    server.listen(fixture.handle);
    fixture.record('started', {
      'scope': 'loopback fixtures; optional public Keylol guest reading',
    });
    return fixture;
  }

  void record(String kind, Map<String, Object> details) {
    events.add({
      'kind': kind,
      'time': DateTime.now().toIso8601String(),
      ...details,
    });
    report.writeAsStringSync(jsonEncode({'events': events}));
    notifyListeners();
  }

  Map<String, dynamic> variables() =>
      (BaseVariableResult()
            ..member_uid = expired ? 0 : uid
            ..member_username = uid == 0 ? '' : user.username
            ..auth = 'qa-only-auth'
            ..saltkey = 'qa-only-salt'
            ..formHash = 'qa-only-formhash'
            ..groupId = 1
            ..readAccess = 10
            ..noticeCount = (NoticeCount()
              ..newprompt = uid == 0 || noticesRead ? 0 : (uid == 7 ? 2 : 1)
              ..newmypost = uid == 7 && !noticesRead ? 3 : 0
              ..newpm = uid == 7 && !messagesRead ? 4 : 0))
          .toJson();

  Future<void> handle(HttpRequest request) async {
    final module = request.uri.queryParameters['module'] ?? 'asset';
    record('request', {'module': module, 'uid': uid, 'offline': offline});
    if (offline) {
      request.response.statusCode = 503;
      await request.response.close();
      return;
    }
    if (module == 'asset') {
      request.response.headers.contentType = ContentType('image', 'png');
      request.response.add(
        base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
        ),
      );
      await request.response.close();
      return;
    }
    if (request.method == 'POST' && {'sendpm', 'sendreply'}.contains(module)) {
      final fields = Uri.splitQueryString(
        await utf8.decoder.bind(request).join(),
      );
      final allowed =
          !expired && uid > 0 && fields['formhash'] == 'qa-only-formhash';
      if (allowed) {
        (module == 'sendpm' ? sentMessages : sentReplies).add(
          fields['message'] ?? '',
        );
        record('submitted', {
          'module': module,
          'uid': uid,
          'text': fields['message'] ?? '',
        });
      }
      request.response.headers.contentType = ContentType.json;
      request.response.write(
        jsonEncode({
          'Variables': variables(),
          'Message': {
            'messageval': allowed
                ? (module == 'sendpm' ? 'do_success' : 'post_reply_succeed')
                : 'submit_invalid',
            'messagestr': allowed ? '发送成功（测试论坛）' : '请求已拒绝',
          },
        }),
      );
      await request.response.close();
      return;
    }
    if (request.method != 'GET') {
      request.response.statusCode = 405;
      await request.response.close();
      return;
    }
    final values = variables();
    switch (module) {
      case 'hotthread':
        values.addAll({
          'perpage': '20',
          'data': [
            for (var index = 0; index < 10; index++)
              (HotThread()
                    ..tid = 100 + index
                    ..fid = 161
                    ..subject = index == 0
                        ? 'Apple Watch 同步验证'
                        : '测试热帖 ${index + 1}'
                    ..author = uid == 0 ? '公开作者' : user.username
                    ..authorId = uid
                    ..replies = 12 + index
                    ..views = '123'
                    ..message =
                        '<p>${uid == 7
                            ? 'Alice'
                            : uid == 8
                            ? 'Bob'
                            : '游客'} 的测试摘要：抬腕阅读中文、英文和 emoji 😀。</p>'
                        '${List.filled(20, '<p>这段内容用于检查摘要截断、滚动和文字排版。</p>').join()}'
                        '<script>hidden-script-must-not-show</script>')
                  .toJson(),
          ],
        });
      case 'mynotelist':
        noticesRead = true;
        values.addAll({
          'count': '1',
          'perpage': '20',
          'page': '1',
          'list': [
            {
              'id': '301',
              'uid': '$uid',
              'type': 'post',
              'new': '1',
              'author': '测试回复者',
              'authorid': '42',
              'note': '<p>回复了你的帖子 <a href="forum.php?mod=viewthread&tid=100">Apple Watch 同步验证</a>。</p>',
              'dateline': '${DateTime.now().millisecondsSinceEpoch ~/ 1000}',
              'from_id': '100',
              'from_idtype': 'tid',
            },
          ],
        });
      case 'mypm':
        final detail = request.uri.queryParameters['subop'] == 'view';
        if (detail) messagesRead = true;
        values.addAll({
          'count': '1',
          'perpage': '20',
          'page': '1',
          'pmid': '501',
          'list': [
            for (var index = 0; index < sentMessages.length; index++)
              {
                'plid': '${600 + index}',
                'pmid': '${600 + index}',
                'touid': '42',
                'msgfromid': '$uid',
                'msgfrom': user.username,
                'subject': '',
                'message': sentMessages[index],
                'vdateline': '2026-10-17 03:00',
                'isnew': '0',
                'tousername': '测试联系人',
              },
            {
              'plid': '401',
              'isnew': '1',
              'subject': '测试私信',
              'touid': '42',
              'pmid': '501',
              'msgfromid': '42',
              'msgfrom': '测试联系人',
              'tousername': '测试联系人',
              'message': '<p>只属于 ${uid == 7 ? 'Alice' : 'Bob'} 的私信预览。</p>',
              'vdateline': '2026-10-17 03:00',
            },
          ],
        });
      case 'viewthread':
        final content = ThreadVariables()
          ..fid = 161
          ..ppp = request.uri.queryParameters['ppp'] ?? '15'
          ..threadInfo = (DetailedThreadInfo()
            ..tid =
                int.tryParse(request.uri.queryParameters['tid'] ?? '') ?? 100
            ..fid = 161
            ..authorId = 42
            ..author = '测试作者'
            ..subject = 'Apple Watch 同步验证'
            ..views = '123'
            ..closed = false
            ..replies = 6 + sentReplies.length)
          ..postList = [
            for (
              var index =
                  ((int.tryParse(request.uri.queryParameters['page'] ?? '') ??
                          1) -
                      1) *
                  (int.tryParse(request.uri.queryParameters['ppp'] ?? '') ??
                      15);
              index < 7 + sentReplies.length &&
                  index <
                      (int.tryParse(
                                request.uri.queryParameters['page'] ?? '',
                              ) ??
                              1) *
                          (int.tryParse(
                                request.uri.queryParameters['ppp'] ?? '',
                              ) ??
                              15);
              index++
            )
              (Post()
                ..pid = 2001 + index
                ..tid =
                    int.tryParse(request.uri.queryParameters['tid'] ?? '') ??
                    100
                ..first = index == 0
                ..number = index + 1
                ..position = index + 1
                ..author = index >= 7 ? user.username : '测试作者'
                ..authorId = index >= 7 ? uid : 42
                ..message = index >= 7
                    ? sentReplies[index - 7]
                    : index == 0
                    ? '<p>这是手表内阅读的完整正文，包含中文和 emoji 😀。</p>${List.generate(600, (n) => '<p>正文第 $n 段，可以继续阅读，无需跳到手机。</p>').join()}'
                    : '<p>第 $index 条回复（合成测试数据）。</p>'),
          ];
        values.addAll(content.toJson());
        values.addAll(variables());
      case 'forumindex':
        values.addAll(
          (DiscuzIndexVariables()
                ..groupInfo = (GroupInfo()
                  ..groupId = '1'
                  ..groupTitle = '测试组'))
              .toJson(),
        );
        values.addAll(variables());
      case 'checkpost':
        values['allowperm'] = {'allowpost': '0', 'allowreply': '1'};
    }
    request.response.headers.contentType = ContentType.json;
    request.response.write(
      jsonEncode({'Version': '4', 'Charset': 'utf-8', 'Variables': values}),
    );
    await request.response.close();
  }
}

class WatchQaControls extends StatelessWidget {
  final WatchQaForum fixture;
  final DiscuzAndUserNotifier selection;
  const WatchQaControls({
    super.key,
    required this.fixture,
    required this.selection,
  });

  void account(int uid) {
    fixture.uid = uid;
    fixture.expired = fixture.offline = fixture.noticesRead =
        fixture.messagesRead = false;
    selection.initDiscuz(fixture.discuz);
    if (uid != 0) selection.setUser(fixture.user);
    fixture.record('account', {'uid': uid});
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Apple Watch 配对联调')),
    body: ListenableBuilder(
      listenable: Listenable.merge([fixture, selection]),
      builder: (context, _) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '仅专用模拟器 · 私信为合成测试数据',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            '论坛：${selection.discuz?.siteName}\n账号：${selection.user?.username ?? '游客'}',
          ),
          Wrap(
            spacing: 8,
            children: [
              ElevatedButton(
                onPressed: () => account(7),
                child: const Text('切换 Alice'),
              ),
              ElevatedButton(
                onPressed: () => account(8),
                child: const Text('切换 Bob'),
              ),
              ElevatedButton(
                onPressed: () => account(0),
                child: const Text('退出测试账号'),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              fixture.expired = true;
              fixture.record('expired', {});
            },
            child: const Text('模拟登录过期（然后在手表刷新）'),
          ),
          ElevatedButton(
            onPressed: () {
              fixture.offline = !fixture.offline;
              fixture.record('network', {'offline': fixture.offline});
            },
            child: Text(fixture.offline ? '恢复测试网络' : '模拟断网（然后在手表刷新）'),
          ),
          ElevatedButton(
            onPressed: () {
              selection.initDiscuz(
                Discuz(
                  'https://keylol.com',
                  'X3.2',
                  'utf-8',
                  4,
                  '1.4.8',
                  'register',
                  true,
                  'true',
                  'true',
                  '其乐 Keylol（公开内容）',
                  '0',
                  'https://keylol.com/uc_server',
                  '161',
                ),
              );
              fixture.record('public_forum', {});
            },
            child: const Text('真实公开热帖（Keylol 游客）'),
          ),
          const Divider(),
          Text(
            '接口调用数：${fixture.events.where((event) => event['kind'] == 'request').length}',
          ),
          for (final module in [
            'hotthread',
            'mynotelist',
            'mypm',
            'viewthread',
          ])
            Text(
              '$module: ${fixture.events.where((event) => event['module'] == module).length}',
            ),
          const Text('在手表打开提醒 / 私信，并尝试“在 iPhone 继续”。账号切换、断网和登录过期后检查旧内容是否清理。'),
        ],
      ),
    ),
  );
}
