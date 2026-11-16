import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:discuz_flutter/JsonResult/ViewThreadResult.dart';
import 'package:discuz_flutter/client/ForumInteractionClient.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/client/SpecialThreadForm.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/motion_photo.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/widget/PollWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'discuz_six_features_test.dart' show discuz, fake, host;

void main() {
  test('reward limits and total come from the authenticated Discuz form', () {
    const form = '''
      <form id="postform"><input name="formhash" value="signed">
      <div><input id="rewardprice" value="5">点金币，含手续费
      <strong id="realprice">0</strong><p class="xg1">最低 5 点金币，最高 30 点金币，余额 20 点金币</p>
      </div>
      <script>function getrealprice(price) {
        n = Math.ceil(parseInt(price) + price * 0.1);
        if (price < 5 || (30 > 0 && price > 30)) {}
      }</script></form>''';
    final parsed = SpecialThreadForm.parse(
      form,
      'signed',
      SpecialThreadKind.reward,
    );
    final reward = parsed.reward!;
    expect(reward.total(11), 13);
    expect(reward.balance, 20);
    expect(reward.allows(18), isTrue);
    expect(reward.allows(19), isFalse);
    expect(reward.allows(4), isFalse);
    expect(
      () =>
          SpecialThreadForm.parse(form, 'different', SpecialThreadKind.reward),
      throwsA(isA<ForumApiException>()),
    );
  });

  test(
    'activity submits dates, configured fields and credit in the form body',
    () async {
      final form = SpecialThreadForm.parse(
        '''
      <form id="postform"><input name="formhash" value="signed">
      <input id="activityplace"><input id="activityclass">
      <ul id="activitytypelist"><li>Meetup</li></ul>
      <label><input name="userfield[]" value="realname">Name</label>
      <label><input name="userfield[]" value="mobile">Mobile</label>
      <dd><textarea id="extfield"></textarea>Up to 2 fields</dd>
      <dd><input id="activitycredit">Coins</dd></form>
      ''',
        'signed',
        SpecialThreadKind.activity,
      );

      const draft = SpecialThreadDraft(SpecialThreadKind.activity, {
        'starttime': '2027-01-01T10:00:00+08:00',
        'starttimeto': '2027-01-01T11:00:00+08:00',
        'activityexpiration': '2026-12-31T10:00:00+08:00',
        'activityclass': 'Meetup',
        'activityplace': 'Hall',
        'userfield': 'realname,mobile',
        'activitycredit': '3',
        'extfield': 'Team\nRole',
      });
      expect(form.accepts(SpecialThreadDraft.decode(draft.encode())!), isTrue);
      expect(
        form.accepts(
          SpecialThreadDraft(draft.kind, {
            ...draft.fields,
            'userfield': 'unavailable',
          }),
        ),
        isFalse,
      );
      expect(
        form.accepts(
          SpecialThreadDraft(draft.kind, {
            ...draft.fields,
            'extfield': 'A\nB\nC',
          }),
        ),
        isFalse,
      );
      final requests = <RequestOptions>[];
      final dio = fake((_) => {'Variables': <String, dynamic>{}}, requests);
      addTearDown(dio.close);
      await MobileApiClient(
        dio,
        baseUrl: discuz.baseURL,
      ).postNewThread(form.submissionFields(draft));
      expect(
        requests.single.uri.queryParameters.containsKey('userfield[]'),
        isFalse,
      );
      expect(requests.single.data['special'], '4');
      expect(
        requests.single.data['starttimefrom[1]'],
        '2027-01-01T02:00:00.000Z',
      );
      expect(requests.single.data['userfield[]'], ['realname', 'mobile']);
    },
  );

  testWidgets('vote controls respect the forum maximum and hidden results', (
    tester,
  ) async {
    final poll = Poll.fromJson({
      'multiple': '1',
      'maxchoices': '2',
      'allowvote': '1',
      'visiblepoll': '1',
      'expirations':
          DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch ~/
          1000,
      'polloptions': [
        for (var id = 1; id <= 3; id++)
          {'polloptionid': '$id', 'polloption': 'Choice $id', 'votes': '5'},
      ],
    });
    await tester.pumpWidget(
      host(Scaffold(body: PollWidget(poll, 'signed', 4, 5))),
    );
    expect(poll.isResultVisible, isFalse);
    expect(find.text(S.current.pollSelectUpTo(2)), findsOneWidget);
    await tester.tap(find.text('Choice 1'));
    await tester.tap(find.text('Choice 2'));
    await tester.pump();
    final tiles = tester
        .widgetList<PlatformListTile>(find.byType(PlatformListTile))
        .toList();
    expect(tiles[0].selected, isTrue);
    expect(tiles[1].selected, isTrue);
    expect(tiles[2].onTap, isNull);
    expect(find.text('33.3%'), findsNothing);
  });

  test(
    'reply pin verifies the current topic owner and uses the fresh formhash',
    () async {
      final requests = <RequestOptions>[];
      final dio = fake(
        (request) => request.method == 'POST'
            ? {
                'Message': {'messageval': 'admin_succeed'},
              }
            : {
                'Variables': {
                  'fid': '3',
                  'member_uid': '1',
                  'formhash': 'fresh',
                  'thread': {'authorid': '1'},
                  'postlist': [
                    {'pid': '2', 'tid': '8', 'first': '0'},
                  ],
                },
              },
        requests,
      );
      addTearDown(dio.close);
      final client = ForumInteractionClient(dio, discuz.baseURL);
      await expectLater(
        client.setReplyPinned(
          tid: 8,
          pid: 2,
          uid: 1,
          pinned: true,
          sameAccount: () => false,
        ),
        throwsA(isA<ForumApiException>()),
      );
      expect(requests.where((request) => request.method == 'POST'), isEmpty);
      await client.setReplyPinned(
        tid: 8,
        pid: 2,
        uid: 1,
        pinned: false,
        sameAccount: () => true,
      );
      final request = requests.singleWhere(
        (request) => request.method == 'POST',
      );
      expect(request.uri.queryParameters['action'], 'stickreply');
      expect(request.data['formhash'], 'fresh');
      expect(request.data['topiclist[]'], [2]);
      expect(request.data['stickreply'], '0');
    },
  );

  test('motion JPEG extracts the XMP clip and keeps regular JPEGs static', () {
    List<int> box(String type) => [
      0,
      0,
      0,
      12,
      ...ascii.encode(type),
      0,
      0,
      0,
      0,
    ];
    final video = [...box('ftyp'), ...box('moov'), ...box('mdat')];
    final xmp = utf8.encode(
      '<Container:Item Item:Mime="video/mp4" Item:Semantic="MotionPhoto" Item:Length="${video.length}" />',
    );
    final bytes = Uint8List.fromList([
      0xff,
      0xd8,
      0xff,
      0xe1,
      0,
      xmp.length + 2,
      ...xmp,
      0xff,
      0xd9,
      ...video,
    ]);
    expect(motionPhotoVideo(bytes), video);
    expect(
      motionPhotoVideo(
        Uint8List.sublistView(bytes, 0, bytes.length - video.length),
      ),
      isNull,
    );
  });
}
