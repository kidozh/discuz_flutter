import 'dart:convert';

import 'package:html/dom.dart';

import '../utility/discuz_json.dart';
import 'discuz_web_client.dart';
import 'ForumInteractionClient.dart';

class ReplyRewardDraft {
  const ReplyRewardDraft(this.amount, this.times, this.perMember, this.chance);
  final int amount, times, perMember, chance;
  int get pool => amount * times;
  Map<String, int> get fields => {
    'replycredit_extcredits': amount,
    'replycredit_times': times,
    'replycredit_membertimes': perMember,
    'replycredit_random': chance,
  };
  String encode() => jsonEncode(fields);
  static ReplyRewardDraft? decode(String source) {
    if (source.isEmpty) return null;
    try {
      final m = discuzMap(jsonDecode(source));
      final d = ReplyRewardDraft(
        discuzInt(m['replycredit_extcredits']),
        discuzInt(m['replycredit_times']),
        discuzInt(m['replycredit_membertimes']),
        discuzInt(m['replycredit_random']),
      );
      return d.valid ? d : null;
    } on FormatException {
      return null;
    }
  }

  bool get valid =>
      amount > 0 &&
      times > 0 &&
      amount <= 2147483647 &&
      times <= 2147483647 &&
      amount <= 2147483647 ~/ times &&
      perMember > 0 &&
      perMember <= 10 &&
      chance >= 0 &&
      chance <= 100;
}

class ReplyRewardForm {
  const ReplyRewardForm(
    this.hash,
    this.unit,
    this.balance,
    this.tax,
    this.limits,
    this.chances,
  );
  final String hash, unit;
  final int balance;
  final double tax;
  final List<int> limits, chances;
  int total(ReplyRewardDraft d) => (d.pool + d.pool * tax).ceil();
  bool accepts(ReplyRewardDraft d) =>
      d.valid &&
      limits.contains(d.perMember) &&
      chances.contains(d.chance) &&
      total(d) <= balance;

  static Future<ReplyRewardForm?> load(
    ForumInteractionClient client,
    int fid,
    int uid,
    int special,
  ) async {
    final web = DiscuzWebClient(client);
    final reply = await client.request('newthread', {
      'fid': fid,
      'special': special,
    });
    reply.requireData('formhash');
    final hash = discuzString(reply.variables['formhash']);
    if (hash.isEmpty || discuzInt(reply.variables['member_uid']) != uid) {
      throw const ForumApiException('account_changed', '');
    }
    final page = await web.read(
      web.page('forum.php', {
        'mod': 'post',
        'action': 'newthread',
        'fid': '$fid',
        'special': '$special',
      }),
    );
    return parse(page.document, hash);
  }

  static ReplyRewardForm? parse(Document doc, String hash) {
    const invalid = FormatException('Invalid reply reward form');
    final form = doc.querySelector('form#postform');
    if (hash.isEmpty ||
        form == null ||
        form.querySelector('input[name=formhash]')?.attributes['value'] !=
            hash) {
      throw invalid;
    }
    final amount = form.querySelector('input[name=replycredit_extcredits]');
    if (amount == null) return null;
    List<int> options(String key) => [
      for (final o in form.querySelectorAll(
        'select[name=$key]:not([disabled]) option:not([disabled])',
      ))
        if (int.tryParse(o.attributes['value'] ?? '') case final int n) n,
    ];
    String? number(String key) =>
        RegExp('\\bvar\\s+' + key + r'\s*=\s*(\d+(?:\.\d+)?)\s*;')
            .firstMatch(
              doc.querySelectorAll('script').map((s) => s.text).join('\n'),
            )
            ?.group(1);
    final tax = double.tryParse(number('creditstax') ?? '');
    final balance = int.tryParse(number('userextcredit') ?? '');
    final unit =
        amount.parent?.nodes
            .skipWhile((n) => n != amount)
            .skip(1)
            .map((n) => n.text ?? '')
            .join()
            .trim() ??
        '';
    final limits = options('replycredit_membertimes');
    final chances = options('replycredit_random');
    if (amount.attributes.containsKey('disabled') ||
        form.querySelector('input[name=replycredit_times]:not([disabled])') ==
            null ||
        tax == null ||
        !tax.isFinite ||
        tax < 0 ||
        tax > 1 ||
        balance == null ||
        unit.isEmpty ||
        limits.isEmpty ||
        chances.isEmpty) {
      throw invalid;
    }
    return ReplyRewardForm(hash, unit, balance, tax, limits, chances);
  }
}
