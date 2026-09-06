import 'dart:math' as math;

import 'package:discuz_flutter/JsonResult/DisplayForumResult.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/ForumThread.dart';
import 'package:discuz_flutter/page/ViewThreadSliverPage.dart';
import 'package:discuz_flutter/page/FullImagePage.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/widget/DiscuzHtmlWidget.dart';
import 'package:discuz_flutter/widget/ForumThreadWidget.dart';
import 'package:discuz_flutter/widget/PostWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart' as html;
import 'package:provider/provider.dart';

// Public samples selected from Keylol's featured topics and checked anonymously.
// Metadata is only for the list. The real page fetches its live content itself.
final readingSamples = [
  ForumThread()
    ..tid = '1048330'
    ..subject = '2026年9月发售游戏汇总，鬼武者 | 漫威金刚狼 | 火焰之纹章 | 控制 共振 | 寂静岭 | 巫师3 等'
    ..author = 'Xiao-Nan'
    ..authorId = '472159',
  ForumThread()
    ..tid = '1043189'
    ..subject = 'Steam上实体电子化桌游整理（255）'
    ..author = 'ShovalW'
    ..authorId = '861786',
];

Widget buildReadingSampleList(Discuz discuz) => ListView(
      key: const ValueKey('reading-samples'),
      children: readingSamples
          .map((thread) =>
              ForumThreadWidget(discuz, null, thread, ThreadType(), null))
          .toList(),
    );

typedef MeasureReadingPhase = Future<void> Function(
    String name, String label, Future<void> Function() action);

Future<Map<String, dynamic>> runReadingScenario(
  LiveWidgetController tester, {
  required bool Function() shouldStop,
  required Future<Map<String, dynamic>> Function() sample,
  required MeasureReadingPhase measure,
  required List<Map<String, Object?>> gestures,
  bool diagnose = false,
  ValueChanged<Map<String, dynamic>>? onStarted,
}) async {
  final visits = <Map<String, dynamic>>[];
  final result = <String, dynamic>{
    'completed': false,
    'visits': visits,
    'limitations': 'Anonymous live content; no login, ads, replies or photo saving. '
        'Gallery opening, swiping and return are checked outside scroll measurements. '
        'Content-ready latency includes network and polling (100 ms), '
        'not touch-to-photon. First visit is not a guaranteed cold disk image cache. '
        'Return uses Navigator.pop, not native back-button touch injection.',
  };
  onStarted?.call(result);
  Future<void> wait(Duration duration) async {
    final watch = Stopwatch()..start();
    while (watch.elapsed < duration && !shouldStop()) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      await sample();
    }
  }

  await measure('reading_idle_before', '看帖测试 · 静置 15 秒',
      () => wait(const Duration(seconds: 15)));

  for (final thread in readingSamples) {
    for (var visit = 0; visit < 2; visit++) {
      if (shouldStop()) return result;
      final id = '${thread.tid}_${visit == 0 ? 'first' : 'reopen'}';
      final details = <String, dynamic>{
        'tid': thread.getTid(),
        'title': thread.subject,
        'url': 'https://keylol.com/t${thread.tid}-1-1',
        'visit': visit,
      };
      visits.add(details);
      final page = find.byType(ViewThreadSliverPage);
      final posts =
          find.descendant(of: page, matching: find.byType(PostWidget));
      final scroll =
          find.descendant(of: page, matching: find.byType(CustomScrollView));
      ScrollPosition position() => tester
          .state<ScrollableState>(find
              .descendant(of: scroll, matching: find.byType(Scrollable))
              .first)
          .position;
      await measure(
          '${id}_open', '正在${visit == 0 ? '首次打开' : '重开'}：${thread.tid}',
          () async {
        final row = find.text(thread.decodedSubject);
        if (row.evaluate().length != 1) {
          throw StateError('Sample row unavailable');
        }
        final dao = await AppDatabase.getViewThreadScrollDistanceDao();
        final site = tester.element(row).read<DiscuzAndUserNotifier>().discuz!;
        details['saved_offset_before_open'] = dao
            .findViewThreadCacheListByDiscuz(site, thread.getTid(), true)
            ?.offset;
        final opening = Stopwatch()..start();
        await tester.tap(row); // Real production row onTap and page route.
        while (posts.evaluate().isEmpty && !shouldStop()) {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          await sample();
          if (opening.elapsed > const Duration(seconds: 45)) {
            throw StateError(
                'Thread ${thread.tid} did not render a post in 45 s');
          }
        }
        details['tap_to_first_post_observed_ms'] = opening.elapsedMilliseconds;
        if (shouldStop()) return;
        if (tester.widget<ViewThreadSliverPage>(page).tid != thread.getTid()) {
          throw StateError('Wrong thread opened');
        }
        if (!usesLiquidGlass(tester.element(page))) {
          throw StateError('Glass disabled');
        }
        // Include entry animation and immediate content layout in the open phase.
        await wait(const Duration(seconds: 2));
        details['offset_after_open'] = position().pixels;
        details['max_extent_after_open'] = position().maxScrollExtent;
        details['sliver_post_count'] = tester
            .widgetList<PostWidget>(posts)
            .where((post) => post.asSliver)
            .length;
        final expected = details['saved_offset_before_open'] as double?;
        if (expected != null) {
          final reachable = expected.clamp(0.0, position().maxScrollExtent);
          final error = (position().pixels - reachable).abs();
          final rawError = (position().pixels - expected).abs();
          details['restoration_error_px'] = error;
          details['restoration_raw_error_px'] = rawError;
          details['restoration_clamped'] = expected != reachable;
          // A pre-existing offset may belong to removed/previously erroneous
          // content. But our own immediate reopen must restore what we saved;
          // clamping must not silently turn that regression into a passing test.
          if (diagnose && (error > 1 || (visit > 0 && rawError > 1))) {
            throw StateError('Reading position did not restore');
          }
        }
      });
      if (shouldStop()) return result;
      if (diagnose) {
        // Normalize only the test's viewport, outside opening/scroll measurement.
        // Let production's restore animation finish before resetting the offset.
        await measure('${id}_prepare', '统一滚动起点 · ${thread.tid}', () async {
          await wait(const Duration(seconds: 1));
          position().jumpTo(0);
          await wait(const Duration(seconds: 1));
        });
      }
      final htmlSeen = <String>{};
      var maxDecodedImages = 0;
      var maxImagePixels = 0;
      var moved = 0;
      void inspectContent() {
        for (final widget in tester.widgetList<DiscuzHtmlWidget>(find
            .descendant(of: posts, matching: find.byType(DiscuzHtmlWidget)))) {
          htmlSeen.add(widget.html);
        }
        final images = tester
            .widgetList<RawImage>(
                find.descendant(of: posts, matching: find.byType(RawImage)))
            .where((widget) => widget.image != null)
            .toList();
        maxDecodedImages = math.max(maxDecodedImages, images.length);
        for (final widget in images) {
          maxImagePixels = math.max(
              maxImagePixels, widget.image!.width * widget.image!.height);
        }
      }

      await measure(
          '${id}_scroll', '${thread.tid} · ${visit == 0 ? '首次' : '重开'}快慢交替滑动',
          () async {
        final duration =
            Duration(seconds: diagnose ? 15 : (visit == 0 ? 60 : 25));
        final watch = Stopwatch()..start();
        var down = true;
        var count = 0;
        while (watch.elapsed < duration && !shouldStop()) {
          inspectContent();
          final before = position().pixels;
          final extent = position().maxScrollExtent;
          if (extent < 50) throw StateError('Heavy thread is not scrollable');
          if (before >= extent - 5) down = false;
          if (before <= 5) down = true;
          final fast = count++ % 3 == 0;
          final travel = math.min(380.0, tester.getSize(scroll).height * .55);
          await tester.timedDrag(scroll, Offset(0, down ? -travel : travel),
              Duration(milliseconds: fast ? 220 : 700));
          await wait(Duration(milliseconds: fast ? 800 : 500));
          final after = position().pixels;
          if ((after - before).abs() > 20) moved++;
          gestures.add({
            'phase': id,
            'wall_us': DateTime.now().microsecondsSinceEpoch,
            'fast': fast,
            'before': before,
            'after': after,
            'max_extent': position().maxScrollExtent
          });
        }
        inspectContent();
      });
      if (shouldStop()) return result;
      if (moved < 5) throw StateError('Not enough verified reading gestures');
      details['verified_moving_gestures'] = moved;
      details['max_mounted_decoded_images'] = maxDecodedImages;
      details['largest_observed_decoded_image_pixels'] = maxImagePixels;
      // Outside the scroll window: parsing this instrumentation must not inflate it.
      final documents = htmlSeen.map(html.parse).toList();
      details['observed_html_chars'] =
          htmlSeen.fold<int>(0, (n, s) => n + s.length);
      details['observed_text_chars'] =
          documents.fold<int>(0, (n, d) => n + (d.body?.text.length ?? 0));
      details['observed_html_image_tags'] = documents.fold<int>(
          0, (n, d) => n + d.querySelectorAll('img').length);
      final discuz = tester.widget<ViewThreadSliverPage>(page).discuz;
      final cache = await AppDatabase.getViewThreadCacheDao();
      details['cached_pages_after'] = cache
          .findAllViewThreadCacheListByDiscuz(discuz, thread.getTid(), true)
          .length;
      double? stoppedAt;
      if (diagnose) {
        await measure('${id}_save_check', '校验阅读位置保存', () async {
          // Cancel inertia outside the scrolling measurement, then wait for save.
          stoppedAt = position().pixels;
          position().jumpTo(stoppedAt!);
          await wait(const Duration(seconds: 1));
          final dao = await AppDatabase.getViewThreadScrollDistanceDao();
          final saved = dao
              .findViewThreadCacheListByDiscuz(discuz, thread.getTid(), true)
              ?.offset;
          details['stopped_offset'] = stoppedAt;
          details['saved_offset'] = saved;
          if (saved == null || (saved - stoppedAt!).abs() > 1) {
            throw StateError('Latest reading position was not saved');
          }
        });
      }
      if (visit == 0 && maxDecodedImages > 1) {
        await measure('${id}_gallery_check', '校验原图查看、图库翻页及返回', () async {
          final originalOffset = position().pixels;
          Finder visibleImages() => find
              .descendant(
                  of: posts,
                  matching: find.descendant(
                      of: find.byType(DiscuzHtmlWidget),
                      matching: find.byType(RawImage)))
              .hitTestable();
          if (visibleImages().evaluate().isEmpty) {
            // The middle/end may consist entirely of replies. Locate a visible
            // image in the main article instead of assuming half the page is one.
            position().jumpTo(0);
            await wait(const Duration(seconds: 1));
            for (var attempt = 0;
                attempt < 12 && visibleImages().evaluate().isEmpty;
                attempt++) {
              position().jumpTo(math.min(
                  position().pixels + 250, position().maxScrollExtent));
              await wait(const Duration(milliseconds: 500));
            }
          }
          if (visibleImages().evaluate().isEmpty) {
            throw StateError('No visible article image for gallery check');
          }
          final articleOffset = position().pixels;
          await tester.tap(visibleImages().first);
          await wait(const Duration(seconds: 2));
          final gallery = find.byType(FullImagePage);
          if (gallery.evaluate().length != 1) {
            throw StateError('Article image did not open the full gallery');
          }
          final widget = tester.widget<FullImagePage>(gallery);
          final originals = documents
              .expand((d) => d.querySelectorAll('img'))
              .map((e) => e.attributes['src'])
              .whereType<String>()
              .toSet();
          if (!originals.contains(widget.imageUrl) ||
              !widget.imageUrlList.toSet().containsAll(originals)) {
            throw StateError('Gallery changed an original URL or lost images');
          }
          final initial = tester.state<FullImagePageState>(gallery).currentPage;
          final next = initial + 1 < widget.imageUrlList.length
              ? initial + 1
              : initial - 1;
          final direction = next > initial ? -1.0 : 1.0;
          await tester.timedDrag(
              gallery,
              Offset(direction * tester.getSize(gallery).width * .8, 0),
              const Duration(milliseconds: 350));
          await wait(const Duration(seconds: 1));
          if (tester.state<FullImagePageState>(gallery).currentPage != next) {
            throw StateError('Gallery swipe did not change the image');
          }
          details['gallery_check'] = {
            'original_urls_preserved': true,
            'image_count': widget.imageUrlList.length,
            'initial_index': initial,
            'swiped_index': next
          };
          Navigator.of(tester.element(gallery)).pop();
          await wait(const Duration(seconds: 1));
          if (gallery.evaluate().isNotEmpty ||
              (position().pixels - articleOffset).abs() > 1) {
            throw StateError('Gallery return changed the article position');
          }
          if ((position().pixels - originalOffset).abs() > 1) {
            position().jumpTo(originalOffset);
            await wait(const Duration(seconds: 1));
          }
        });
      }
      await measure('${id}_return', '返回列表 · ${thread.tid}', () async {
        Navigator.of(tester.element(page)).pop();
        await wait(const Duration(seconds: 2));
        if (page.evaluate().isNotEmpty) {
          throw StateError('Thread route did not close');
        }
        final dao = await AppDatabase.getViewThreadScrollDistanceDao();
        details['saved_offset_after_return'] = dao
            .findViewThreadCacheListByDiscuz(discuz, thread.getTid(), true)
            ?.offset;
      });
    }
  }
  await measure('reading_idle_after', '看帖测试结束 · 观察 15 秒',
      () => wait(const Duration(seconds: 15)));
  result['completed'] = !shouldStop() && visits.length == 4;
  return result;
}
