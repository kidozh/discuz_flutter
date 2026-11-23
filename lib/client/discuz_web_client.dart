import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html;

import '../utility/discuz_json.dart';
import 'ForumInteractionClient.dart';

typedef ForumLink = ({int tid, int? pid});

class DiscuzWebClient {
  DiscuzWebClient(this.api) : base = api.endpoint.resolve('../../');

  final ForumInteractionClient api;
  final Uri base;

  Uri page(String file, Map<String, String> query) =>
      base.resolve(file).replace(queryParameters: {...query, 'mobile': 'no'});

  Uri? siteLink(Uri from, String? href, String file) {
    if (href == null || href.isEmpty) return null;
    final link = from.resolveUri(Uri.tryParse(href) ?? Uri());
    if (link.scheme != base.scheme ||
        link.host != base.host ||
        link.port != base.port ||
        link.userInfo.isNotEmpty ||
        link.path != base.resolve(file).path) {
      return null;
    }
    return link;
  }

  ForumLink? threadLink(Uri from, String? href) {
    final query = siteLink(from, href, 'forum.php')?.queryParameters;
    if (query == null) return null;
    final mod = query['mod'];
    final tid = int.tryParse(query['tid'] ?? query['ptid'] ?? '');
    if (tid == null || tid <= 0 || !{'viewthread', 'redirect'}.contains(mod)) {
      return null;
    }
    final pid = int.tryParse(query['pid'] ?? '');
    return (tid: tid, pid: pid != null && pid > 0 ? pid : null);
  }

  Future<({Uri uri, Document document, String source})> read(
    Uri uri, {
    Map<String, dynamic>? body,
  }) async {
    var target = uri;
    var data = body;
    for (var redirects = 0; redirects <= 4; redirects++) {
      final response = await api.dio.requestUri<String>(
        target,
        data: data,
        options: Options(
          method: data == null ? 'GET' : 'POST',
          contentType: data == null ? null : Headers.formUrlEncodedContentType,
          responseType: ResponseType.plain,
          followRedirects: false,
          validateStatus: (status) =>
              status != null && status >= 200 && status < 400,
          headers: {'referer': uri.toString()},
          listFormat: ListFormat.multi,
        ),
      );
      if (response.statusCode! < 300) {
        final source = response.data ?? '';
        if (ForumReply.isSecurityChallenge(source)) {
          throw const ForumApiException(
            'forum_security_challenge',
            '',
            fromForum: true,
          );
        }
        return (uri: target, document: html.parse(source), source: source);
      }
      final location = response.headers.value('location');
      final destination =
          siteLink(target, location, 'search.php') ??
          siteLink(target, location, 'forum.php') ??
          siteLink(target, location, 'home.php') ??
          siteLink(target, location, 'group.php') ??
          siteLink(target, location, 'misc.php') ??
          siteLink(target, location, 'portal.php');
      if (destination == null ||
          (data != null && !{301, 302, 303}.contains(response.statusCode))) {
        throw const ForumApiException(
          'forum_webpage_redirect',
          '',
          fromForum: true,
        );
      }
      target = destination.replace(
        queryParameters: {...destination.queryParametersAll, 'mobile': 'no'},
      );
      data = null;
    }
    throw const ForumApiException(
      'forum_webpage_redirect',
      '',
      fromForum: true,
    );
  }

  static bool hasCaptcha(Element? content) =>
      content?.querySelector(
        'input[name="seccodeverify"], input[name="secanswer"], '
        'input[name="seccodehash"], input[name="secqaahash"], iframe[src*="captcha"]',
      ) !=
      null;

  Never rejected(Document document, String code) {
    final message =
        document.querySelector('#messagetext > p')?.text.trim() ?? '';
    throw ForumApiException(code, message, fromForum: true);
  }

  Future<String> accountHash(int uid, {int? tid, int? pid}) async {
    final reply = tid == null
        ? await api.request('profile', {'uid': uid})
        : await api.request('viewthread', {
            'tid': tid,
            if (pid != null) 'viewpid': pid,
          });
    reply.requireData('formhash');
    final hash = discuzString(reply.variables['formhash']);
    if (hash.isEmpty || discuzInt(reply.variables['member_uid']) != uid) {
      throw const ForumApiException('not_loggedin', '', fromForum: true);
    }
    return hash;
  }

  static Map<String, dynamic> formFields(Element form) {
    final fields = <String, dynamic>{};
    for (final field in form.querySelectorAll(
      'input[name], textarea[name], select[name]',
    )) {
      final name = field.attributes['name']!;
      final type = field.attributes['type']?.toLowerCase();
      if (field.attributes.containsKey('disabled') ||
          {'button', 'submit', 'reset', 'file', 'image'}.contains(type) ||
          ({'checkbox', 'radio'}.contains(type) &&
              !field.attributes.containsKey('checked'))) {
        continue;
      }
      final values = switch (field.localName) {
        'textarea' => [field.text.replaceAll('\r\n', '\n')],
        'select' => _selectedOptions(field),
        _ => [
          field.attributes['value'] ??
              ({'checkbox', 'radio'}.contains(type) ? 'on' : ''),
        ],
      };
      for (final value in values) {
        if (name.endsWith('[]') || fields.containsKey(name)) {
          final previous = fields[name];
          if (previous is List<String>) {
            previous.add(value);
          } else {
            fields[name] = [if (previous is String) previous, value];
          }
        } else {
          fields[name] = value;
        }
      }
    }
    return fields;
  }

  static List<String> _selectedOptions(Element select) {
    final options = select.querySelectorAll('option:not([disabled])');
    final selected = options
        .where((option) => option.attributes.containsKey('selected'))
        .toList();
    if (selected.isEmpty &&
        options.isNotEmpty &&
        !select.attributes.containsKey('multiple')) {
      selected.add(options.first);
    }
    return selected
        .map((option) => option.attributes['value'] ?? option.text)
        .toList();
  }
}
