import 'dart:convert';

import '../utility/discuz_json.dart';
import '../utility/PostTextFieldUtils.dart';
import '../utility/post_editor_controller.dart';
import 'ForumInteractionClient.dart';
import 'discuz_web_client.dart';
import 'thread_tags.dart';

typedef PostEditField = ({String key, String value, bool toggle});
typedef PostEditResult = ({bool moderated});

class PostEditForm {
  const PostEditForm(
    this.action,
    this.fields,
    this.attachments,
    this.settings, {
    required this.first,
  });
  final Uri action;
  final Map<String, dynamic> fields;
  final Map<String, String> attachments;
  final List<PostEditField> settings;
  final bool first;

  String get subject => discuzString(fields['subject']);
  bool get hasSubject => fields.containsKey('subject');
  String get text => discuzString(fields['message']);
  int get special => discuzInt(fields['special']);

  String get snapshot => jsonEncode([
    fields.entries
        .where(
          (entry) => !{'posttime', 'formhash', 'wysiwyg'}.contains(entry.key),
        )
        .map((entry) => [entry.key, entry.value])
        .toList(),
    attachments,
  ]);
}

class PostEditClient {
  PostEditClient(
    this.web, {
    required this.uid,
    required this.fid,
    required this.tid,
    required this.pid,
    this.serverDraft = false,
  });

  final DiscuzWebClient web;
  final int uid, fid, tid, pid;
  final bool serverDraft;
  static const _handler = 'disflyedit';

  static Uri websiteUri(Uri base, int fid, int tid, int pid) => base
      .resolve('forum.php')
      .replace(
        queryParameters: {
          'mod': 'post',
          'action': 'edit',
          'fid': '$fid',
          'tid': '$tid',
          'pid': '$pid',
          'mobile': 'no',
        },
      );

  Uri get website => websiteUri(web.base, fid, tid, pid);

  Future<({String hash, Map<String, dynamic> post})> _target() async {
    final reply = await web.api.request('viewthread', {
      'tid': tid,
      'viewpid': pid,
    });
    reply.requireData('formhash');
    final hash = discuzString(reply.variables['formhash']);
    if (hash.isEmpty || discuzInt(reply.variables['member_uid']) != uid) {
      throw const ForumApiException('not_loggedin', '', fromForum: true);
    }
    if (serverDraft &&
        discuzInt(discuzMap(reply.variables['thread'])['displayorder']) != -4) {
      throw const ForumApiException('edit_post_changed', '', fromForum: true);
    }
    final post = forumRows(reply.variables['postlist'])
        .map(discuzMap)
        .where(
          (row) => discuzInt(row['pid']) == pid && discuzInt(row['tid']) == tid,
        )
        .firstOrNull;
    if (post == null || discuzInt(post['authorid']) != uid) {
      throw const ForumApiException(
        'post_edit_nopermission',
        '',
        fromForum: true,
      );
    }
    return (hash: hash, post: post);
  }

  Future<PostEditForm> load() async {
    final target = await _target();
    final response = await web.read(website);
    final form = response.document.querySelector('form#postform');
    if (DiscuzWebClient.hasCaptcha(form)) {
      throw const ForumApiException(
        'submit_seccode_invalid',
        '',
        fromForum: true,
      );
    }
    if (form == null) web.rejected(response.document, 'post_edit_nopermission');
    final action = web.siteLink(
      response.uri,
      form.attributes['action'],
      'forum.php',
    );
    final fields = DiscuzWebClient.formFields(form)
      ..removeWhere(
        (key, _) =>
            key.startsWith('attachnew[') ||
            key.startsWith('attachupdate[') ||
            {
              'imglocalid[]',
              'localid[]',
              'delete',
              'delattachop',
              'handlekey',
            }.contains(key),
      );
    for (final key in ['fid', 'tid', 'pid', 'formhash']) {
      final value = fields[key];
      if (value is List<String> &&
          value.isNotEmpty &&
          value.every((entry) => entry == value.first)) {
        fields[key] = value.first;
      }
    }
    final special = discuzInt(fields['special']);
    final first = discuzPermission(target.post['first']) == true;
    if (action == null ||
        action.queryParameters['mod'] != 'post' ||
        action.queryParameters['action'] != 'edit' ||
        action.queryParameters['editsubmit'] != 'yes' ||
        fields['formhash'] != target.hash ||
        discuzInt(fields['tid']) != tid ||
        discuzInt(fields['pid']) != pid ||
        discuzInt(fields['fid']) != fid ||
        fields['message'] is! String ||
        (first && !{0, 1, 3, 4}.contains(special)) ||
        (first && discuzInt(fields['sortid']) != 0)) {
      web.rejected(response.document, 'edit_post_unsupported');
    }

    // Keep the fields that the website would submit for this edit (including
    // the activity's cover image and profile checkboxes).
    final settings = <PostEditField>[];
    if (first) {
      final names = switch (special) {
        1 => [
          for (final key in fields.keys)
            if (RegExp(r'^polloption\[\d+\]$').hasMatch(key)) key,
          'maxchoices',
          'expiration',
          'visibilitypoll',
          'overt',
        ],
        3 => ['rewardprice'],
        4 => [
          'activityclass',
          'activityplace',
          'starttimefrom[0]',
          'starttimefrom[1]',
          'starttimeto',
          'activityexpiration',
          'activitynumber',
          'cost',
          'activitycredit',
          'extfield',
        ],
        _ => <String>[],
      };
      final ranged = fields.containsKey('activitytime');
      for (final name in [...names, 'tags']) {
        if (name == 'starttimefrom[${ranged ? 0 : 1}]' ||
            (name == 'starttimeto' && !ranged))
          continue;
        final input = form.querySelector(
          'input[name="$name"], textarea[name="$name"]',
        );
        if (input == null ||
            input.attributes.containsKey('disabled') ||
            input.attributes.containsKey('readonly'))
          continue;
        if (name == 'rewardprice' &&
            (int.tryParse(discuzString(fields[name])) ?? 0) < 1) {
          continue;
        }
        settings.add((
          key: name,
          value: discuzString(fields[name]),
          toggle: input.attributes['type'] == 'checkbox',
        ));
      }
    }
    final cover = discuzString(fields['activityaid']);
    final attachments = <String, String>{};
    for (final entry in discuzMap(target.post['attachments']).entries) {
      final row = discuzMap(entry.value);
      final aid = discuzString(row['aid']).isEmpty
          ? entry.key
          : discuzString(row['aid']);
      if (RegExp(r'^[1-9]\d*$').hasMatch(aid) && aid != cover) {
        attachments[aid] = discuzString(row['filename']);
      }
    }
    // The mobile thread response omits images already expanded into the post
    // body. The edit page still exposes their existing attachment controls.
    for (final link in response.document.querySelectorAll(
      '#e_imgattachlist a[id^="imageattach"]',
    )) {
      final id = link.id.substring('imageattach'.length);
      if (id != cover &&
          RegExp(r'^[1-9]\d*$').hasMatch(id) &&
          link.parent?.id == 'image_td_$id') {
        attachments.putIfAbsent(
          id,
          () => link.attributes['title']?.trim() ?? '',
        );
      }
    }
    return PostEditForm(action, fields, attachments, settings, first: first);
  }

  Future<PostEditResult> save({
    required PostEditForm original,
    required String subject,
    required String text,
    required Map<String, String> settings,
    required Set<String> newAttachments,
    required Set<String> removeAttachments,
    required bool Function() isCurrent,
    bool keepDraft = false,
  }) async {
    final fresh = await load();
    if (keepDraft && (!serverDraft || !fresh.fields.containsKey('save'))) {
      throw const ForumApiException('edit_post_changed', '', fromForum: true);
    }
    if (!isCurrent()) throw const ForumApiException('account_changed', '');
    if (fresh.snapshot != original.snapshot ||
        !fresh.attachments.keys.toSet().containsAll(removeAttachments)) {
      throw const ForumApiException('edit_post_changed', '', fromForum: true);
    }
    final patches = <String, String>{
      for (final setting in fresh.settings)
        if (settings[setting.key] case final value? when value != setting.value)
          setting.key: value,
    };
    if (patches['tags'] case final value?) {
      final tags = forumThreadTags(value);
      if (tags == null) {
        throw const ForumApiException(
          'thread_tags_invalid',
          '',
          fromForum: true,
        );
      }
      patches['tags'] = tags;
    }
    final edits = {...fresh.fields};
    for (final change in patches.entries) {
      if ({'visibilitypoll', 'overt'}.contains(change.key) &&
          change.value.isEmpty) {
        edits.remove(change.key);
      } else {
        edits[change.key] = change.value;
      }
    }
    if (fresh.special == 1 && patches.keys.every((key) => key == 'tags')) {
      edits.remove('polls');
    }
    final message = stripAttachments(text, removeAttachments);
    edits.addAll({
      if (fresh.hasSubject) 'subject': subject.trim(),
      'message': message,
      'wysiwyg': '0',
      if (serverDraft && keepDraft && fresh.fields.containsKey('save'))
        'save': '1',
      'delattachop': removeAttachments.isEmpty ? '0' : '1',
      for (final aid in PostTextFieldUtils.getAttachmentAidList(message))
        if (newAttachments.contains(aid)) 'attachnew[$aid][description]': '',
    });
    var removalSubmitted = false;
    try {
      if (removeAttachments.isNotEmpty) {
        removalSubmitted = true;
        final removal = await web.read(
          web.page('forum.php', {
            'mod': 'ajax',
            'action': 'deleteattach',
            'fid': '$fid',
            'tid': '$tid',
            'pid': '$pid',
            'inajax': 'yes',
          }),
          body: {
            'formhash': edits['formhash'],
            'aids[]': removeAttachments.toList(),
          },
        );
        final count = int.tryParse(
          RegExp(r'<root>\s*<!\[CDATA\[\s*(\d+)\s*\]\]>\s*</root>')
                  .firstMatch(removal.source)
                  ?.group(1) ??
              '',
        );
        if (count != removeAttachments.length || !isCurrent()) {
          throw const ForumApiException(
            'edit_post_attachment_partial',
            '',
            fromForum: true,
          );
        }
      }
      final submitted = await web.read(
        fresh.action.replace(
          queryParameters: {
            ...fresh.action.queryParameters,
            'inajax': '1',
            'handlekey': _handler,
            'mobile': 'no',
          },
        ),
        body: edits,
      );
      final source = submitted.source.trim();
      final target = _ajaxSuccess(source, submitted.uri);
      if (target == null) {
        final rejected = RegExp(
          r"\berrorhandle_disflyedit\('((?:\\.|[^'\\])*)'[,)]",
        ).firstMatch(source);
        if (rejected != null) {
          throw ForumApiException(
            'post_edit_rejected',
            rejected[1]!.replaceAll(r"\'", "'"),
            fromForum: true,
          );
        }
        if (submitted.document.querySelector('#messagetext > p') != null) {
          web.rejected(submitted.document, 'post_edit_rejected');
        }
        throw const ForumApiException('edit_post_verify', '', fromForum: true);
      }
      return (
        moderated: !keepDraft && target.queryParameters['mod'] != 'viewthread',
      );
    } catch (_) {
      if (removalSubmitted) {
        throw const ForumApiException(
          'edit_post_attachment_partial',
          '',
          fromForum: true,
        );
      }
      rethrow;
    }
  }

  Uri? _ajaxSuccess(String source, Uri from) {
    if (!RegExp(r'^(?:<\?xml[^>]*\?>\s*)?<root>\s*<!\[CDATA\[')
        .hasMatch(source))
      return null;
    final match = RegExp(r"\bsucceedhandle_disflyedit\('([^']*)'")
        .firstMatch(source);
    final link = web.siteLink(from, match?.group(1), 'forum.php');
    if (link?.queryParameters['mod'] == 'viewthread' &&
        link?.queryParameters['tid'] == '$tid')
      return link;
    if (link?.queryParameters['mod'] == 'forumdisplay' &&
        link?.queryParameters['fid'] == '$fid')
      return link;
    return null;
  }

  static String stripAttachments(String message, Set<String> ids) =>
      message.replaceAllMapped(PostEditorToken.pattern, (match) {
        final token = PostEditorToken(match.start, match.group(0)!);
        return (token.isAttachment || token.isFile) &&
                !token.isPending &&
                ids.contains(token.content)
            ? ''
            : token.text;
      });
}
