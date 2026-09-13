import 'package:flutter/material.dart';
import '../entity/Discuz.dart';
import '../entity/User.dart';
import '../generated/l10n.dart';
import '../page/ForumFeedSettingsPage.dart';
import '../utility/PlatformAdaptiveWidgets.dart';

class ForumFeedEmptyState extends StatelessWidget {
  final Discuz discuz;
  final User? user;
  const ForumFeedEmptyState({
    super.key,
    required this.discuz,
    required this.user,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.filter_list, size: 32),
        const SizedBox(height: 12),
        Text(S.of(context).feedNoForums, textAlign: TextAlign.center),
        PlatformTextButton(
          onPressed: () => Navigator.push(
            context,
            platformPageRoute(
              context: context,
              builder: (_) => ForumFeedSettingsPage(discuz: discuz, user: user),
            ),
          ),
          child: Text(S.of(context).feedForumsTitle),
        ),
      ],
    ),
  );
}
