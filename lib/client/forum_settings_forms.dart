import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';

import '../utility/discuz_json.dart';
import 'ForumInteractionClient.dart';
import 'discuz_web_client.dart';

enum ForumSettingsKind { profile, group, invite }

typedef ForumSettingField = ({
  String name,
  String label,
  String value,
  bool multiline,
  int? maxLength,
  Map<String, String> choices,
});

class ForumSettingsForm {
  const ForumSettingsForm(
    this.action,
    this.hash,
    this.fields, {
    this.initial = const {},
    this.canUploadIcon = false,
    this.invited = const {},
    this.friends = const {},
    this.tabs = const {},
  });
  final Uri action;
  final String hash;
  final List<ForumSettingField> fields;
  final Map<String, dynamic> initial;
  final bool canUploadIcon;
  final Set<int> invited;
  final Map<int, String> friends;
  final Map<String, String> tabs;
}

class ForumSettingsClient {
  const ForumSettingsClient(this.web, this.uid);

  final DiscuzWebClient web;
  final int uid;

  static const profileTabs = ['base', 'contact', 'edu', 'work', 'info'];
  static const _handler = 'disflysettings';

  static Uri website(Uri base, ForumSettingsKind kind, int fid, String tab) {
    final (file, query) = switch (kind) {
      ForumSettingsKind.profile => (
        'home.php',
        {'mod': 'spacecp', 'ac': 'profile', 'op': tab},
      ),
      ForumSettingsKind.group => (
        'forum.php',
        {'mod': 'group', 'action': 'manage', 'op': 'group', 'fid': '$fid'},
      ),
      ForumSettingsKind.invite => (
        'misc.php',
        {'mod': 'invite', 'action': 'group', 'id': '$fid'},
      ),
    };
    return base
        .resolve(file)
        .replace(queryParameters: {...query, 'mobile': 'no'});
  }

  Future<ForumSettingsForm> load(
    ForumSettingsKind kind,
    int fid,
    String tab, {
    bool withFriends = true,
  }) async {
    if (!profileTabs.contains(tab) ||
        (kind != ForumSettingsKind.profile && fid <= 0)) {
      throw ArgumentError('Invalid forum settings');
    }
    final hash = await web.accountHash(uid);
    final target = website(web.base, kind, fid, tab);
    final page = await web.read(target);
    final selector = switch (kind) {
      ForumSettingsKind.profile => 'form[target="frame_profile"]',
      ForumSettingsKind.group => 'form[name="manage"]',
      ForumSettingsKind.invite => 'form#inviteform',
    };
    final form = page.document.querySelector(selector);
    if (DiscuzWebClient.hasCaptcha(form)) {
      throw const ForumApiException(
        'forum_security_challenge',
        '',
        fromForum: true,
      );
    }
    final action = web.siteLink(
      page.uri,
      form?.attributes['action'],
      target.pathSegments.last,
    );
    if (form == null ||
        action == null ||
        action.queryParametersAll.values.any((values) => values.length != 1) ||
        !target.queryParameters.entries.every(
          (e) => e.key == 'mobile' || action.queryParameters[e.key] == e.value,
        ) ||
        action.queryParameters.keys.any(
          (key) => !target.queryParameters.containsKey(key),
        ) ||
        form.attributes['method']?.toLowerCase() != 'post') {
      web.rejected(page.document, 'forum_api_unavailable');
    }
    final values = DiscuzWebClient.formFields(form);
    if (values['formhash'] != hash) {
      throw const ForumApiException('account_changed', '', fromForum: true);
    }
    if (kind == ForumSettingsKind.invite) {
      if (form.querySelector('button[name="invitesubmit"]') == null) {
        web.rejected(page.document, 'forum_api_unavailable');
      }
      final scripts = page.document.querySelectorAll(
        '#ct script, #main_messaqge script',
      );
      final filter = RegExp(r'\binvitefs\.addFilterUser\(\[([0-9,\s]+)\]\)');
      final invited = {
        for (final script in scripts)
          for (final match in filter.allMatches(script.text))
            for (final part in match[1]!.split(','))
              if (int.tryParse(part.trim()) case final id?) id,
      };
      return ForumSettingsForm(
        action,
        hash,
        const [],
        invited: invited,
        friends: withFriends ? await _friends(invited) : const {},
      );
    }

    if (kind == ForumSettingsKind.group &&
        (!values.containsKey('descriptionnew') ||
            !values.containsKey('jointypenew') ||
            !values.containsKey('gviewpermnew') ||
            form.querySelector('button[name="groupmanage"]') == null)) {
      web.rejected(page.document, 'forum_api_unavailable');
    }
    if (kind == ForumSettingsKind.profile &&
        (values['profilesubmit'] != 'true' ||
            form.querySelector('#profilelist') == null ||
            values.containsKey('vid'))) {
      web.rejected(page.document, 'forum_api_unavailable');
    }

    final tabs = <String, String>{};
    if (kind == ForumSettingsKind.profile) {
      for (final link in page.document.querySelectorAll('#ct ul.tb a[href]')) {
        final query = web
            .siteLink(page.uri, link.attributes['href'], 'home.php')
            ?.queryParameters;
        final operation = query?['op'];
        if (query?['mod'] == 'spacecp' &&
            query?['ac'] == 'profile' &&
            profileTabs.contains(operation)) {
          tabs[operation!] = link.text.trim();
        }
      }
    }
    final controls = <String, ForumSettingField>{};
    for (final input in form.querySelectorAll(
      'input[name], textarea[name], select[name]',
    )) {
      final name = input.attributes['name']!;
      final type = input.attributes['type'] ?? 'text';
      if (input.attributes.containsKey('disabled') ||
          input.attributes.containsKey('readonly'))
        continue;
      final row = _ancestor(input, 'tr');
      if (kind == ForumSettingsKind.group) {
        if (!{'descriptionnew', 'jointypenew'}.contains(name)) continue;
      } else if (!RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*$').hasMatch(name) ||
          {
            'password',
            'file',
            'hidden',
            'email',
            'submit',
            'checkbox',
            'button',
          }.contains(type) ||
          RegExp(
            r'password|email|mobile|seccode|secanswer|country|province|city|birthday|birthyear|birthmonth|birthdist|community|residedist|seccode|question|answer',
            caseSensitive: false,
          ).hasMatch(name) ||
          (row?.id != 'tr_$name' &&
              !{'sightml', 'customstatus', 'timeoffset'}.contains(name)) ||
          input.attributes.containsKey('multiple')) {
        continue;
      }
      final choices = <String, String>{
        if (type == 'radio')
          for (final radio in form.querySelectorAll(
            'input[type="radio"][name="$name"]:not([disabled])',
          ))
            if (radio.attributes['value'] case final value?)
              value: radio.parent?.text.trim() ?? value,
        if (input.localName == 'select')
          for (final option in input.querySelectorAll('option:not([disabled])'))
            if (option.attributes['value'] case final value?)
              value: option.text.trim(),
      };
      final header = row
          ?.querySelector('th')
          ?.text
          .trim()
          .replaceFirst(RegExp(r'^\*\s*'), '');
      if (header == null || header.isEmpty) continue;
      controls[name] = (
        name: name,
        label: header,
        value: discuzString(values[name]),
        multiline: input.localName == 'textarea',
        maxLength: int.tryParse(input.attributes['maxlength'] ?? ''),
        choices: choices,
      );
    }
    return ForumSettingsForm(
      action,
      hash,
      controls.values.toList(),
      initial: values,
      tabs: tabs,
      canUploadIcon:
          kind == ForumSettingsKind.group &&
          form.querySelector(
                'input[type="file"][name="iconnew"]:not([disabled])',
              ) !=
              null,
    );
  }

  Future<void> save(
    ForumSettingsKind kind,
    int fid,
    String tab,
    ForumSettingsForm original,
    Map<String, String> changes, {
    MultipartFile? icon,
    Set<int> invites = const {},
    required bool Function() isCurrent,
  }) async {
    final fresh = await load(
      kind,
      fid,
      tab,
      withFriends: kind == ForumSettingsKind.invite,
    );
    if (!isCurrent()) throw const ForumApiException('account_changed', '');
    final available = {for (final field in fresh.fields) field.name: field};
    for (final field in changes.entries) {
      final live = available[field.key];
      if (live == null ||
          !original.fields.any(
            (old) => old.name == field.key && old.value == live.value,
          ) ||
          (live.choices.isNotEmpty && !live.choices.containsKey(field.value))) {
        throw const ForumApiException(
          'forum_form_changed',
          '',
          fromForum: true,
        );
      }
    }
    if ((icon != null && !fresh.canUploadIcon) ||
        (kind == ForumSettingsKind.invite &&
            (invites.isEmpty ||
                invites.length > 20 ||
                !fresh.friends.keys.toSet().containsAll(invites)))) {
      throw const ForumApiException('forum_form_changed', '', fromForum: true);
    }
    final body = <String, dynamic>{
      if (kind == ForumSettingsKind.group) ...{
        for (final key in [
          'descriptionnew',
          'jointypenew',
          'gviewpermnew',
          'name',
          'parentid',
          'fup',
          'domain',
        ])
          if (fresh.initial.containsKey(key)) key: fresh.initial[key],
        'groupmanage': '1',
        if (icon != null) 'iconnew': icon,
      },
      if (kind == ForumSettingsKind.profile) 'profilesubmit': 'true',
      if (kind == ForumSettingsKind.invite) ...{
        'invitesubmit': 'yes',
        'uids[]': invites.map((id) => '$id').toList(),
      },
      'formhash': fresh.hash,
      ...changes,
    };
    final action = fresh.action.replace(
      queryParameters: {
        ...fresh.action.queryParameters,
        'mobile': 'no',
        if (kind != ForumSettingsKind.profile) ...{
          'inajax': '1',
          'handlekey': _handler,
        },
      },
    );
    final result = await web.read(
      action,
      body: kind == ForumSettingsKind.invite
          ? body
          : FormData.fromMap(body, ListFormat.multi),
    );
    if (!isCurrent()) throw const ForumApiException('account_changed', '');
    if (kind == ForumSettingsKind.profile &&
        RegExp(
          r"""^\s*<script(?: type="text/javascript")?>\s*parent\.show_success\('(?:[^'\\]|\\.)*'\);\s*</script>\s*$""",
        ).hasMatch(result.source))
      return;
    if (kind != ForumSettingsKind.profile) {
      final match = RegExp(r"\bsucceedhandle_disflysettings\('([^']*)'")
          .firstMatch(result.source);
      final destination = web.siteLink(
        result.uri,
        match?.group(1),
        'forum.php',
      );
      if (destination?.queryParameters['mod'] == 'group' &&
          destination?.queryParameters['fid'] == '$fid')
        return;
      final rejected = RegExp(
        r"""\berrorhandle_disflysettings\('((?:[^'\\]|\\.)*)'""",
      ).firstMatch(result.source);
      if (rejected != null) {
        throw ForumApiException(
          'forum_settings_rejected',
          _plain(rejected[1]!),
          fromForum: true,
        );
      }
    } else {
      final rejected = RegExp(
        r'''parent\.show_error\("([^"]*)",\s*"((?:[^"\\]|\\.)*)"\)''',
      ).firstMatch(result.source);
      if (rejected != null) {
        throw ForumApiException(
          'forum_settings_rejected',
          _plain(rejected[2]!.isEmpty ? rejected[1]! : rejected[2]!),
          fromForum: true,
        );
      }
    }
    web.rejected(result.document, 'forum_settings_unconfirmed');
  }

  Future<Map<int, String>> _friends(Set<int> invited) async {
    final found = <int, String>{};
    final scanned = <int>{};
    for (var page = 1; page <= 10; page++) {
      final result = await web.api.request('friend', {'page': page});
      result.requireData('list');
      if (discuzInt(result.variables['member_uid']) != uid) {
        throw const ForumApiException('account_changed', '', fromForum: true);
      }
      var progress = false;
      for (final item in forumRows(result.variables['list'])) {
        final row = discuzMap(item);
        final id = discuzInt(row['uid']);
        final name = _plain(discuzString(row['username']));
        if (id <= 0 || !scanned.add(id)) continue;
        progress = true;
        if (name.isNotEmpty && !invited.contains(id)) found[id] = name;
      }
      if (!progress ||
          scanned.length >=
              (int.tryParse(discuzString(result.variables['count'])) ?? 100))
        break;
    }
    return found;
  }

  static Element? _ancestor(Element element, String tag) {
    for (var node = element.parent; node != null; node = node.parent) {
      if (node.localName == tag) return node;
    }
    return null;
  }

  static String _plain(String source) =>
      parseFragment(source.replaceAll(r"\'", "'").replaceAll(r'\"', '"')).text
          ?.trim() ??
      '';
}
