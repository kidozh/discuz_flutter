import 'package:html/dom.dart';

import '../JsonResult/DisplayForumResult.dart';
import 'ForumInteractionClient.dart';
import 'discuz_web_client.dart';

typedef ClassifiedChoice = ({String value, String title});

class ClassifiedField {
  const ClassifiedField(this.name, this.title, this.type, this.choices);

  final String name;
  final String title;
  final String type;
  final List<ClassifiedChoice> choices;

  bool get multiple => type == 'checkbox';
  bool get quickLink => type == 'link';

  void addQuery(Map<String, String> query, Set<String> values) {
    final selected = values.where(
      (value) =>
          value.isNotEmpty &&
          (choices.isEmpty || choices.any((item) => item.value == value)),
    );
    if (selected.isEmpty) return;
    if (quickLink) {
      query['searchsort'] = '1';
      query[name] = selected.first;
      return;
    }
    final parameter = 'searchoption[$name]';
    query['$parameter[type]'] = type;
    if (multiple) {
      // Discuz combines the checkbox values in form order.
      for (final choice in choices.where(
        (item) => selected.contains(item.value),
      )) {
        query['$parameter[value][${choice.value}]'] = choice.value;
      }
    } else {
      query['$parameter[value]'] = selected.first;
    }
  }
}

class ClassifiedFilters {
  ClassifiedFilters(this.web);

  final DiscuzWebClient web;

  static Uri page(Uri base, int fid, int sortId) => base
      .resolve('forum.php')
      .replace(
        queryParameters: {
          'mod': 'forumdisplay',
          'fid': '$fid',
          'filter': 'sortid',
          'sortid': '$sortId',
          'mobile': 'no',
        },
      );

  Future<List<ClassifiedField>> load(int fid, int sortId) async {
    final response = await web.read(page(web.base, fid, sortId));
    return parse(response.document, response.uri, fid, sortId);
  }

  Future<DisplayForumResult> display(
    int fid,
    int page,
    Map<String, String> query,
  ) async {
    final body = <String, String>{};
    final params = <String, String>{
      'version': '4',
      'module': 'forumdisplay',
      'fid': '$fid',
      'page': '$page',
    };
    for (final entry in query.entries) {
      // The stock desktop form also posts searchoption. Putting its nested
      // values in the URL breaks forumdisplay's filter URL builder on PHP 8.
      final target = entry.key.startsWith('searchoption[') ? body : params;
      target[entry.key] = entry.value;
    }
    final response = await web.read(
      web.api.endpoint.replace(queryParameters: params),
      body: body,
    );
    final payload = ForumReply.decodePayload(response.source);
    final failure = ForumReply(payload).serverError;
    if (failure != null) throw failure;
    return DisplayForumResult.fromJson(payload);
  }

  List<ClassifiedField> parse(Document document, Uri uri, int fid, int sortId) {
    final fields = <ClassifiedField>[];
    // The mobile response supplies category names. The forum's desktop form
    // supplies each category's currently enabled fields and option values.
    final form = document.querySelector('form#searhsort');
    if (_matches(
      web.siteLink(uri, form?.attributes['action'], 'forum.php'),
      fid,
      sortId,
    )) {
      final names = RegExp(r'^searchoption\[(\d+)\]\[value\](?:\[[\w.]+\])?$');
      final controls = form!.querySelectorAll('input[name], select[name]');
      final byId = <String, List<Element>>{};
      for (final control in controls) {
        if (control.attributes.containsKey('disabled')) continue;
        final id = names.firstMatch(control.attributes['name'] ?? '')?.group(1);
        if (id != null) (byId[id] ??= []).add(control);
      }
      for (final entry in byId.entries) {
        final id = entry.key;
        final first = entry.value.first;
        var row = first.parent;
        while (row != null && row != form && row.localName != 'div') {
          row = row.parent;
        }
        final title = _label(row?.children.firstOrNull?.text ?? '');
        final type =
            form
                .querySelector('input[name="searchoption[$id][type]"]')
                ?.attributes['value'] ??
            (first.localName == 'input' ? 'text' : '');
        if (title.isEmpty ||
            !{
              'select',
              'radio',
              'range',
              'checkbox',
              'number',
              'text',
              'calendar',
              'email',
              'url',
              'textarea',
            }.contains(type))
          continue;
        final choices = <ClassifiedChoice>[
          if (first.localName == 'select')
            for (final item in first.querySelectorAll('option:not([disabled])'))
              if (_option(item.attributes['value']))
                (value: item.attributes['value']!, title: _label(item.text)),
          if (type == 'checkbox')
            for (final item in entry.value)
              if (_option(item.attributes['value']))
                (
                  value: item.attributes['value']!,
                  title: _label(item.parent?.text ?? ''),
                ),
        ];
        if (choices.isEmpty &&
            {'select', 'radio', 'range', 'checkbox'}.contains(type))
          continue;
        fields.add(ClassifiedField(id, title, type, choices));
      }
    }
    for (final row in document.querySelectorAll('#fontsearch tr')) {
      final title = _label(row.querySelector('th')?.text ?? '');
      if (title.isEmpty || fields.any((field) => field.title == title))
        continue;
      final links = [
        for (final anchor in row.querySelectorAll('a[href]'))
          if (web.siteLink(uri, anchor.attributes['href'], 'forum.php')
              case final link?)
            if (_matches(link, fid, sortId))
              (uri: link, title: _label(anchor.text)),
      ];
      final key = links.firstOrNull?.uri.queryParameters.entries
          .where(
            (entry) =>
                entry.value == 'all' &&
                RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*$').hasMatch(entry.key),
          )
          .singleOrNull
          ?.key;
      if (key == null) continue;
      final choices = <ClassifiedChoice>[
        for (final link in links)
          if (link.uri.queryParameters[key] case final value?)
            if (value != 'all' && _option(value) && link.title.isNotEmpty)
              (value: value, title: link.title),
      ];
      if (choices.isNotEmpty)
        fields.add(ClassifiedField(key, title, 'link', choices));
    }
    return fields;
  }

  static bool _matches(Uri? uri, int fid, int sortId) {
    final query = uri?.queryParameters;
    return query?['mod'] == 'forumdisplay' &&
        query?['fid'] == '$fid' &&
        query?['sortid'] == '$sortId';
  }

  static String _label(String text) =>
      text.trim().replaceFirst(RegExp(r'[:：]\s*$'), '').trim();

  static bool _option(String? value) =>
      value != null &&
      RegExp(r'^[\w.|-]{1,100}$').hasMatch(value) &&
      value != '0';
}
