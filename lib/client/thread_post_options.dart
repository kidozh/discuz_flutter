import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:html/dom.dart';

import '../entity/PollDraft.dart';
import '../utility/discuz_json.dart';
import 'discuz_web_client.dart';
import 'thread_tags.dart';
import 'ForumInteractionClient.dart';

Future<Element> loadThreadPostForm(
  ForumInteractionClient api,
  int fid,
  int uid, {
  int special = 0,
  int sortId = 0,
}) async {
  final reply = await api.request('newthread', {
    'fid': fid,
    'special': special,
  });
  reply.requireData('formhash');
  final hash = discuzString(reply.variables['formhash']);
  if (hash.isEmpty || discuzInt(reply.variables['member_uid']) != uid) {
    throw const ForumApiException('account_changed', '');
  }
  final web = DiscuzWebClient(api);
  final page = await web.read(
    web.page('forum.php', {
      'mod': 'post',
      'action': 'newthread',
      'fid': '$fid',
      'special': '$special',
      if (sortId > 0) 'sortid': '$sortId',
    }),
  );
  final form = page.document.querySelector('form#postform');
  if (form == null ||
      form.querySelector('input[name=formhash]')?.attributes['value'] != hash) {
    web.rejected(page.document, 'special_post_form_unavailable');
  }
  return form;
}

class PollPostingRules {
  const PollPostingRules(
    this.maximum, {
    this.uploadHash,
    this.maxBytes,
    this.extensions = const {},
  });

  final int maximum;
  final String? uploadHash;
  final int? maxBytes;
  final Set<String> extensions;
  bool get acceptsPictures => uploadHash != null;

  static PollPostingRules parse(Element form, int fid, int uid) {
    final scripts = form
        .querySelectorAll('script')
        .map((e) => e.text)
        .join('\n');
    final maximum = int.tryParse(
      RegExp(r'''\bvar\s+maxoptions\s*=\s*parseInt\(['"]?(\d+)['"]?\)''')
              .firstMatch(scripts)
              ?.group(1) ??
          '',
    );
    if (maximum == null || maximum < 2) {
      throw const FormatException('Missing poll option limit');
    }
    final path =
        'misc.php?mod=swfupload&action=swfupload&operation=poll&fid=$fid';
    final upload = RegExp(
      r'''upload_url\s*:\s*SITEURL\s*\+\s*['"]''' + RegExp.escape(path) + r'''['"]\s*,\s*post_params\s*:\s*\{\s*["']uid["']\s*:\s*["'](\d+)["']\s*,\s*["']hash["']\s*:\s*["']([0-9a-fA-F]{32})["']\s*\}([^}]+)''',
    ).firstMatch(scripts);
    if (upload == null || int.tryParse(upload[1]!) != uid) {
      return PollPostingRules(maximum);
    }
    final config = upload[3]!;
    final size = int.tryParse(
      RegExp(r'''file_size_limit\s*:\s*["'](\d+)["']''')
              .firstMatch(config)
              ?.group(1) ??
          '',
    );
    final types =
        RegExp(r'''file_types\s*:\s*["']([^"']+)["']''')
            .firstMatch(config)
            ?.group(1) ??
        '';
    return PollPostingRules(
      maximum,
      uploadHash: upload[2],
      maxBytes: size == null || size == 0 ? null : size * 1024,
      extensions: RegExp(r'\*\.([a-zA-Z0-9]+)')
          .allMatches(types)
          .map((m) => m[1]!.toLowerCase())
          .toSet(),
    );
  }

  bool accepts(PollDraft draft) =>
      draft.valid &&
      draft.options.length <= maximum &&
      (draft.images.isEmpty || acceptsPictures);

  bool acceptsImage(String name, int size) =>
      acceptsPictures &&
      size > 0 &&
      (maxBytes == null || size <= maxBytes!) &&
      (extensions.isEmpty ||
          extensions.contains(name.split('.').last.toLowerCase()));

  Future<int> upload(
    ForumInteractionClient api,
    int fid,
    int uid,
    File file,
    String name,
  ) async {
    if (!acceptsImage(name, await file.length())) {
      throw const ForumApiException(
        'poll_picture_rejected',
        '',
        fromForum: true,
      );
    }
    final web = DiscuzWebClient(api);
    final uri = web.base
        .resolve('misc.php')
        .replace(
          queryParameters: {
            'mod': 'swfupload',
            'action': 'swfupload',
            'operation': 'poll',
            'fid': '$fid',
          },
        );
    final response = await api.dio.postUri<String>(
      uri,
      data: FormData.fromMap({
        'uid': '$uid',
        'hash': uploadHash!,
        'Filedata': await MultipartFile.fromFile(
          file.path,
          filename: Uri.encodeComponent(name),
        ),
      }),
      options: Options(
        responseType: ResponseType.plain,
        followRedirects: false,
      ),
    );
    final data = discuzMap(jsonDecode(response.data ?? ''));
    final aid = discuzInt(data['aid']);
    if (aid < 1 ||
        !data.containsKey('errorcode') ||
        discuzString(data['errorcode']) != '0') {
      throw const ForumApiException(
        'poll_picture_rejected',
        '',
        fromForum: true,
      );
    }
    return aid;
  }
}

enum ClassifiedInput { text, number, longText, radio, multiple }

class ClassifiedPostField {
  const ClassifiedPostField(
    this.id,
    this.name,
    this.type,
    this.required,
    this.initial,
    this.choices, {
    this.minimum,
    this.maximum,
    this.maxLength,
  });
  final String id, name;
  final ClassifiedInput type;
  final bool required;
  final List<String> initial;
  final Map<String, String> choices;
  final int? minimum, maximum, maxLength;
  bool accepts(List<String> values) {
    if (values.isEmpty) return !required;
    if (type != ClassifiedInput.multiple && values.length != 1) return false;
    if (type == ClassifiedInput.radio || type == ClassifiedInput.multiple) {
      return values.every(choices.containsKey);
    }
    if (maxLength != null && values.single.length > maxLength!) return false;
    if (type != ClassifiedInput.number) return true;
    final n = num.tryParse(values.single);
    return n != null &&
        n.isFinite &&
        (minimum == null || n >= minimum!) &&
        (maximum == null || n <= maximum!);
  }
}

class ClassifiedPostingForm {
  const ClassifiedPostingForm(this.fields, this.expirations);
  final List<ClassifiedPostField> fields;
  final Map<String, String> expirations;

  static ClassifiedPostingForm parse(Element form, int sortId) {
    const unsupported = ForumApiException(
      'classified_post_unsupported',
      '',
      fromForum: true,
    );
    final marker = form.querySelector('input[name=selectsortid]');
    if (marker?.attributes['value'] != '$sortId' || marker?.parent == null)
      throw unsupported;
    final fields = <ClassifiedPostField>[];
    final re = RegExp(
      r'''checkoption\('([a-zA-Z0-9_]+)',\s*'([01])',\s*'([a-z]+)'(?:,\s*'?(\-?\d+)'?)?(?:,\s*'?(\-?\d+)'?)?(?:,\s*'?(\d+)'?)?\)''',
    );
    for (final row in marker!.parent!.querySelectorAll('tr')) {
      final cell = row.querySelector('th');
      final input = row.querySelector('[id^="select_"]');
      if (input == null) continue;
      final id = input.id.substring(7);
      final name = (cell?.text ?? '')
          .replaceFirst(RegExp(r'^\s*\*'), '')
          .trim();
      final elements = input.querySelectorAll(
        'input[name],select,textarea[name]',
      );
      if (elements.isEmpty || name.isEmpty) throw unsupported;
      final control = elements.first;
      final attributes = control.attributes;
      final match = re.firstMatch(attributes.values.join(' '));
      if (match == null ||
          match[1] != id ||
          fields.any((f) => f.id == id) ||
          elements.any((e) => e.attributes.containsKey('disabled')))
        throw unsupported;
      final required = match[2] == '1' || cell?.querySelector('.rq') != null;
      final kind = switch (match[3]) {
        'text' => ClassifiedInput.text,
        'textarea' => ClassifiedInput.longText,
        'number' => ClassifiedInput.number,
        'radio' => ClassifiedInput.radio,
        'checkbox' => ClassifiedInput.multiple,
        _ => throw unsupported,
      };
      final choices = <String, String>{};
      final initial = <String>[];
      if (kind == ClassifiedInput.radio || kind == ClassifiedInput.multiple) {
        final suffix = kind == ClassifiedInput.multiple ? '[]' : '';
        for (final element in elements) {
          final attr = element.attributes;
          final value = attr['value'];
          if (attr['name'] != 'typeoption[$id]$suffix' ||
              value == null ||
              value.isEmpty)
            throw unsupported;
          choices[value] = (element.parent?.text ?? '').trim();
          if (attr.containsKey('checked')) initial.add(value);
        }
      } else {
        if (attributes['name'] != 'typeoption[$id]' || elements.length != 1)
          throw unsupported;
        initial.add(
          control.localName == 'textarea'
              ? control.text
              : attributes['value'] ?? '',
        );
      }
      int? bound(int index) {
        final n = int.tryParse(match[index] ?? '');
        return n == 0 ? null : n;
      }

      fields.add(
        ClassifiedPostField(
          id,
          name,
          kind,
          required,
          initial,
          choices,
          maximum: bound(4),
          minimum: bound(5),
          maxLength: bound(6),
        ),
      );
    }
    if (fields.isEmpty) throw unsupported;
    final expiration = form.querySelector('select[name=typeexpiration]');
    return ClassifiedPostingForm(fields, {
      for (final option
          in expiration?.querySelectorAll('option:not([disabled])') ??
              <Element>[])
        if (option.attributes['value'] case final value?)
          value: option.text.trim(),
    });
  }

  bool accepts(ClassifiedPostDraft draft) =>
      draft.values.keys.every(
        (key) => fields.any((field) => field.id == key),
      ) &&
      fields.every((f) => f.accepts(draft.values[f.id] ?? const [])) &&
      (expirations.isEmpty
          ? draft.expiration.isEmpty
          : expirations.containsKey(draft.expiration));

  Map<String, dynamic> submission(ClassifiedPostDraft draft) => {
    'sortid': '${draft.sortId}',
    'selectsortid': '${draft.sortId}',
    if (expirations.isNotEmpty) 'typeexpiration': draft.expiration,
    for (final f in fields)
      if ((draft.values[f.id] ?? const []).isNotEmpty)
        if (f.type == ClassifiedInput.multiple)
          for (final (i, value) in draft.values[f.id]!.indexed)
            'typeoption[${f.id}][$i]': value
        else
          'typeoption[${f.id}]': draft.values[f.id]!.single,
  };
}

class ClassifiedPostDraft {
  const ClassifiedPostDraft(this.sortId, this.values, this.expiration);
  final int sortId;
  final Map<String, List<String>> values;
  final String expiration;
  String encode() =>
      jsonEncode({'sort': sortId, 'values': values, 'expiration': expiration});
  static ClassifiedPostDraft? decode(String raw) {
    final data = _draftMap(raw);
    final sortId = discuzInt(data['sort']);
    return sortId <= 0
        ? null
        : ClassifiedPostDraft(
            sortId,
            discuzMap(data['values']).map((k, v) => MapEntry(k, discuzIds(v))),
            discuzString(data['expiration']),
          );
  }
}

class RushPostDraft {
  const RushPostDraft(this.fields);
  final Map<String, String> fields;
  static const names = [
    'rushreplyfrom',
    'rushreplyto',
    'rewardfloor',
    'stopfloor',
    'replylimit',
    'creditlimit',
  ];

  static bool supported(Element form) =>
      form.querySelector('input[name=rushreply]:not([disabled])') != null &&
      names.every(
        (name) =>
            form.querySelector('input[name=$name]:not([disabled])') != null,
      );
  bool get valid {
    final start = fields['rushreplyfrom'] ?? '',
        end = fields['rushreplyto'] ?? '';
    final first = DateTime.tryParse(start), last = DateTime.tryParse(end);
    if ((start.isNotEmpty && first == null) ||
        (end.isNotEmpty && last == null) ||
        (first != null && last != null && first.isAfter(last)))
      return false;
    for (final key in ['stopfloor', 'replylimit', 'creditlimit']) {
      final raw = fields[key] ?? '';
      if (raw.isEmpty) continue;
      final n = int.tryParse(raw);
      if (n == null ||
          n > 2147483647 ||
          (key == 'creditlimit' ? n < -2147483648 || n == -996 : n < 0))
        return false;
    }
    final floors = fields['rewardfloor'] ?? '';
    return floors.isEmpty || RegExp(r'^[\d*]+(?:,[\d*]+)*$').hasMatch(floors);
  }

  Map<String, String> get submission => {
    'rushreply': '1',
    for (final key in names) key: fields[key] ?? '',
  };
  String encode() => jsonEncode(fields);
  static RushPostDraft? decode(String source) {
    final data = _draftMap(source);
    if (data.isEmpty) return null;
    return RushPostDraft({
      for (final name in names) name: discuzString(data[name]),
    });
  }
}

Map<String, dynamic> _draftMap(String raw) {
  if (raw.isEmpty) return {};
  try {
    return discuzMap(jsonDecode(raw));
  } on FormatException {
    return {};
  }
}

class ExtraThreadOptions {
  const ExtraThreadOptions(this.available);

  final Set<String> available;
  static const flags = {'allownoticeauthor', 'isanonymous'};
  static const names = {...flags, 'readperm', 'cronpublishdate', 'tags'};

  factory ExtraThreadOptions.fromForm(Element form) => ExtraThreadOptions({
    for (final name in names)
      if (form.querySelector('[name="$name"]:not([disabled]):not([readonly])') != null &&
          (name != 'cronpublishdate' ||
              form.querySelector('[name=cronpublish]:not([disabled])') != null))
        name,
  });

  Map<String, String>? submission(Map<String, String> values, DateTime now) {
    if (!available.containsAll(values.keys)) return null;
    final result = <String, String>{};
    for (final entry in values.entries) {
      final name = entry.key;
      final value = entry.value;
      if (name == 'cronpublishdate') {
        final date = DateTime.tryParse(value);
        if (date == null || !date.isAfter(now)) return null;
        result['cronpublish'] = 'true';
        result[name] = date.toUtc().toIso8601String();
      } else if (name == 'tags') {
        final tags = forumThreadTags(value);
        if (tags == null) return null;
        result[name] = tags;
      } else if (name == 'readperm') {
        final access = int.tryParse(value);
        if (access == null || access < 0 || access > 255) return null;
        result[name] = '$access';
      } else {
        if (value != '1' && value != '0') return null;
        result[name] = value;
      }
    }
    return result;
  }

  static Map<String, String> restore(String value) {
    if (value.isEmpty) return {};
    try {
      final json = discuzMap(jsonDecode(value));
      return {
        for (final name in names)
          if (json[name] is String) name: json[name] as String,
      };
    } on FormatException {
      return {};
    }
  }
}
