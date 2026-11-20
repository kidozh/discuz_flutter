import 'package:discuz_flutter/JsonResult/ApiResult.dart';
import 'package:discuz_flutter/client/thread_post_options.dart';
import 'package:discuz_flutter/entity/PollDraft.dart';
import 'package:discuz_flutter/utility/reply_draft_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart';

void main() {
  test(
    'the forum cap is separate from draft decoding and keeps per-option images',
    () {
      final form = parse('''
      <form><script>
      var maxoptions = parseInt('3');
      var upload = {
        upload_url: SITEURL + 'misc.php?mod=swfupload&action=swfupload&operation=poll&fid=2',
        post_params: {"uid":"3", "hash":"0123456789abcdef0123456789abcdef"},
        file_size_limit: "2", file_types: "*.png;*.jpg"
      };</script></form>
      ''').querySelector('form')!;
      final rules = PollPostingRules.parse(form, 2, 3);
      const image = ReplyDraftAttachment(
        '0123456789abcdef0123456789abcdef',
        'test.png',
        true,
      );
      const poll = PollDraft(
        ['A', 'B'],
        2,
        7,
        images: {1: image},
        hideResults: true,
      );
      final restored = PollDraft.decode(poll.encode())!;
      expect(restored.images[1]!.id, image.id);
      expect(restored.fields['visibilitypoll'], '1');
      expect(rules.accepts(restored), isTrue);
      expect(
        rules.accepts(const PollDraft(['A', 'B', 'C', 'D'], 1, 7)),
        isFalse,
      );
      expect(rules.acceptsImage('a.png', 2048), isTrue);
      expect(rules.acceptsImage('a.png', 2049), isFalse);
      expect(rules.acceptsImage('text.txt', 500), isFalse);
      expect(PollPostingRules.parse(form, 2, 9).accepts(restored), isFalse);
    },
  );

  test('classified form follows required fields, choices and expiration', () {
    final form = ClassifiedPostingForm.parse(
      parse('''
      <form><div><input name="selectsortid" value="95">
      <table><tr><th><span class="rq">*</span>Location</th>
      <td><div id="select_region">
      <label><input name="typeoption[region]" value="1" onclick="checkoption('region', '1', 'radio')">Alpine</label>
      </div></td></tr>
      <tr><th>Extras</th><td><div id="select_extras">
      <label><input name="typeoption[extras][]" value="2" onclick="checkoption('extras','0','checkbox')">A</label>
      <label><input name="typeoption[extras][]" value="3" onclick="checkoption('extras','0','checkbox')">B</label>
      </div></td></tr></table>
      <select name="typeexpiration"><option value="10">Short</option></select>
      </div></form>
      ''').querySelector('form')!,
      95,
    );
    expect(form.accepts(const ClassifiedPostDraft(95, {}, '10')), isFalse);
    final d = ClassifiedPostDraft.decode(
      const ClassifiedPostDraft(95, {
        'region': ['1'],
        'extras': ['2', '3'],
      }, '10').encode(),
    )!;
    expect(form.accepts(d), isTrue);
    expect(form.submission(d), {
      'sortid': '95',
      'selectsortid': '95',
      'typeexpiration': '10',
      'typeoption[region]': '1',
      'typeoption[extras][0]': '2',
      'typeoption[extras][1]': '3',
    });
  });

  test(
    'rush drafts retain wildcard floors and reject an inverted time window',
    () {
      const draft = RushPostDraft({
        'rewardfloor': '8,*88,9*,*',
        'stopfloor': '90',
        'replylimit': '1',
      });
      expect(
        RushPostDraft.decode(draft.encode())!.submission['rewardfloor'],
        '8,*88,9*,*',
      );
      expect(draft.valid, isTrue);
      expect(
        const RushPostDraft({
          'rushreplyfrom': '2026-11-22 01:23',
          'rushreplyto': '2026-11-21 01:23',
        }).valid,
        isFalse,
      );
    },
  );

  test('reply responses preserve string and numeric locators', () {
    final reply = ApiResult.fromJson({
      'Variables': {'pid': '52', 'tid': 29},
    });
    expect(reply.postedPid, 52);
    expect(reply.postedTid, 29);
  });
}
