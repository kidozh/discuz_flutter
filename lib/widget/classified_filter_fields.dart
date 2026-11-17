import 'package:flutter/material.dart';

import '../client/ForumInteractionClient.dart';
import '../client/classified_filters.dart';
import '../client/discuz_web_client.dart';
import '../entity/Discuz.dart';
import '../entity/User.dart';
import '../generated/l10n.dart';
import '../utility/NetworkUtils.dart';
import '../utility/PlatformAdaptiveWidgets.dart';

class ClassifiedFilterFields extends StatefulWidget {
  const ClassifiedFilterFields({
    super.key,
    required this.discuz,
    required this.user,
    required this.fid,
    required this.sortId,
    required this.selection,
    required this.onChanged,
  });

  final Discuz discuz;
  final User? user;
  final int fid;
  final int sortId;
  final Map<String, Set<String>> selection;
  final ValueChanged<Map<String, String>> onChanged;

  @override
  State<ClassifiedFilterFields> createState() => _ClassifiedFilterFieldsState();
}

class _ClassifiedFilterFieldsState extends State<ClassifiedFilterFields> {
  late Future<List<ClassifiedField>> fields = load();
  final controllers = <String, TextEditingController>{};

  Future<List<ClassifiedField>> load() async {
    final dio = await NetworkUtils.getDioWithPersistCookieJar(widget.user);
    try {
      final web = DiscuzWebClient(
        ForumInteractionClient(dio, widget.discuz.baseURL),
      );
      return await ClassifiedFilters(web).load(widget.fid, widget.sortId);
    } finally {
      dio.close();
    }
  }

  @override
  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void change(List<ClassifiedField> fields, String name, Set<String> values) {
    setState(() => widget.selection[name] = values);
    final query = <String, String>{};
    for (final field in fields) {
      field.addQuery(query, widget.selection[field.name] ?? const {});
    }
    widget.onChanged(query);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<ClassifiedField>>(
    future: fields,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Center(child: PlatformCircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return PlatformTextButton(
          onPressed: () => setState(() => fields = load()),
          child: Text(S.of(context).retry),
        );
      }
      final available = snapshot.data ?? const <ClassifiedField>[];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          for (final field in available)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(
                  field.title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if (field.choices.isEmpty)
                  PlatformTextField(
                    controller: controllers.putIfAbsent(
                      field.name,
                      () => TextEditingController(
                        text: widget.selection[field.name]?.firstOrNull,
                      ),
                    ),
                    hintText: field.type == 'calendar'
                        ? 'YYYY-MM-DD'
                        : field.title,
                    keyboardType: field.type == 'number'
                        ? TextInputType.number
                        : null,
                    onChanged: (value) =>
                        change(available, field.name, {value.trim()}),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final choice in field.choices)
                        PlatformChoiceChip(
                          label: Text(choice.title),
                          selected:
                              widget.selection[field.name]?.contains(
                                choice.value,
                              ) ??
                              false,
                          onSelected: (selected) {
                            final values = field.multiple
                                ? {...?widget.selection[field.name]}
                                : <String>{};
                            if (selected) {
                              values.add(choice.value);
                            } else {
                              values.remove(choice.value);
                            }
                            change(available, field.name, values);
                          },
                        ),
                    ],
                  ),
              ],
            ),
        ],
      );
    },
  );
}
