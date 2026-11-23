import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import '../generated/l10n.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import '../utility/forum_local_records.dart';
import '../widget/forum_record_dialog.dart';

class ForumSavedSearchesPage extends StatelessWidget {
  const ForumSavedSearchesPage({
    super.key,
    required this.history,
    required this.presets,
    required this.criteria,
    required this.describe,
    required this.isCurrent,
  });

  final ForumLocalRecords history, presets;
  final ForumRecord? criteria;
  final String Function(ForumRecord) describe;
  final bool Function() isCurrent;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return PlatformScaffold(
      iosContentPadding: true,
      iosContentBottomPadding: true,
      appBar: PlatformAppBar(title: Text(s.savedSearches)),
      body: ValueListenableBuilder(
        valueListenable: presets,
        builder: (context, saved, _) => ValueListenableBuilder(
          valueListenable: history,
          builder: (context, recent, _) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _group(context, s.searchPresets, saved, presets, save: true),
              const SizedBox(height: 12),
              _group(context, s.searchHistory, recent, history),
              if (recent.isNotEmpty)
                PlatformTextButton(
                  onPressed: () async {
                    if (!isCurrent()) return;
                    await showPlatformAlert(
                      context: context,
                      title: s.clearSearchHistory,
                      actions: [
                        PlatformAlertAction(
                          label: s.cancel,
                          isCancelAction: true,
                        ),
                        PlatformAlertAction(
                          label: s.clearSearchHistory,
                          isDestructiveAction: true,
                          onPressed: () =>
                              perform(context, () => history.update((_) => [])),
                        ),
                      ],
                    );
                  },
                  child: Text(s.clearSearchHistory),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _group(
    BuildContext context,
    String title,
    List<ForumRecord> records,
    ForumLocalRecords store, {
    bool save = false,
  }) {
    final s = S.of(context);
    final icons = PlatformIcons(context);
    return PlatformCard(
      margin: EdgeInsets.zero,
      elevation: 0,
      semanticContainer: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Semantics(
              header: true,
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          for (final record in records)
            PlatformListTile(
              title: Text(
                (record['name'] ?? record['query'])?.toString().isNotEmpty ==
                        true
                    ? (record['name'] ?? record['query']).toString()
                    : s.searchFiltersSort,
              ),
              subtitle: Text(describe(record)),
              isThreeLine: true,
              onTap: () {
                if (isCurrent()) Navigator.pop(context, record);
              },
              trailing: PlatformIconButton(
                icon: Icon(
                  icons.pick(Icons.delete_outline, CupertinoIcons.trash),
                  semanticLabel: s.removeLocalRecord,
                ),
                onPressed: () =>
                    perform(context, () => store.remove(record['id'])),
              ),
            ),
          if (records.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(save ? s.noSearchPresets : s.noSearchHistory),
            ),
          if (save && criteria != null)
            PlatformListTile(
              leading: Icon(
                icons.pick(
                  Icons.bookmark_add_outlined,
                  CupertinoIcons.bookmark,
                ),
              ),
              title: Text(s.saveSearchPreset),
              onTap: () async {
                final name = await showForumRecordDialog(
                  context,
                  s.searchPresetName,
                );
                if (name == null || !context.mounted) return;
                await perform(
                  context,
                  () => presets.put({
                    ...criteria!,
                    'id': name.toLowerCase(),
                    'name': name,
                  }),
                );
              },
            ),
        ],
      ),
    );
  }

  Future<void> perform(
    BuildContext context,
    Future<void> Function() operation,
  ) async {
    if (!isCurrent()) return;
    try {
      await operation();
    } catch (_) {
      if (context.mounted && isCurrent()) {
        await showPlatformAlert(
          context: context,
          title: S.of(context).forumLocalSaveFailed,
          actions: [PlatformAlertAction(label: S.of(context).ok)],
        );
      }
    }
  }
}
