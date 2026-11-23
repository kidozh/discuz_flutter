import 'package:discuz_flutter/entity/SpecialThread.dart';
import 'package:discuz_flutter/client/reply_reward_form.dart';
import 'package:discuz_flutter/JsonResult/ViewThreadResult.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart';

void main() {
  test('debate settings label a known reply without assigning a side to unrelated replies', () {
    final debate = DebateInfo.parse({
      'affirmavatars': {
        '7': {'pid': '20', 'authorid': '7'},
      },
      'negaavatars': {
        '8': {'pid': '21', 'authorid': '8'},
      },
      'affirmvoterids': '7\t',
    }, viewer: 7)!;
    expect(debate.sideForAuthor(7), DebateSide.affirm);
    expect(debate.sideForPost(20), DebateSide.affirm);
    expect(debate.sideForPost(21), DebateSide.against);
    expect(debate.sideForPost(19), isNull);
    expect(debate.voted, isTrue);
    expect(
      DebateInfo.parse(debate.toJson())?.sideForPost(21),
      DebateSide.against,
    );
  });

  const html =
      '<form id="postform"><input name="formhash" value="current"><label>Each<input name="replycredit_extcredits"> 金钱</label><input name="replycredit_times"><select name="replycredit_membertimes"><option value="1">1</option></select><select name="replycredit_random"><option value="100">100</option></select></form><script>var creditstax = 0.2; var userextcredit = 8;</script>';
  test(
    'quote taxes the pool once and rejects unaffordable or unavailable options',
    () {
      final f = ReplyRewardForm.parse(parse(html), 'current')!;
      const d = ReplyRewardDraft(2, 3, 1, 100);
      expect(f.unit, '金钱');
      expect(f.total(d), 8);
      expect(f.accepts(d), isTrue);
      expect(f.accepts(const ReplyRewardDraft(3, 3, 1, 100)), isFalse);
      expect(f.accepts(const ReplyRewardDraft(2, 3, 2, 100)), isFalse);
      expect(ReplyRewardDraft.decode(d.encode())?.fields, d.fields);
      expect(
        () => ReplyRewardForm.parse(parse(html), 'another-account'),
        throwsFormatException,
      );
      expect(
        () => ReplyRewardForm.parse(
          parse(html.replaceFirst('0.2', 'unknown')),
          'current',
        ),
        throwsFormatException,
      );
      expect(
        ReplyRewardForm.parse(
          parse(html.replaceFirst('name="replycredit_extcredits"', '')),
          'current',
        ),
        isNull,
      );
    },
  );
  test('cache round-trip keeps separate original and thumbnail, distinguishes missing from zero votes', () {
    final v = ThreadVariables.fromJson({
      'special_debate': {
        'affirmpoint': 'Transit',
        'negapoint': 'Roads',
        'affirmvotes': '0',
      },
      'special_poll': {
        'polloptions': {
          '1': {
            'polloptionid': '1',
            'imginfo': {'big': 'original.jpg', 'small': 'thumb.jpg'},
          },
          '2': {'polloptionid': '2', 'imginfo': []},
        },
      },
    });
    final copy = ThreadVariables.fromJson(v.toJson());
    expect(copy.debate!.affirmVotes, 0);
    expect(copy.debate!.againstVotes, isNull);
    expect(copy.debate!.against, 'Roads');
    expect(copy.poll!.pollOptionsMap['1']!.images, {
      'big': 'original.jpg',
      'small': 'thumb.jpg',
    });
    expect(copy.poll!.pollOptionsMap['2']!.images, isEmpty);
  });
}
