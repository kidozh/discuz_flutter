import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../entity/forum_display_preferences.dart';
import '../generated/l10n.dart';
import '../provider/UserPreferenceNotifierProvider.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import '../utility/UserPreferencesUtils.dart';

class ForumDisplaySettingsPage extends StatelessWidget {
  const ForumDisplaySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final preference = context.watch<UserPreferenceNotifierProvider>();
    final display = preference.forumDisplay;
    final strings = S.of(context);

    String cookiePolicyLabel(ForumImageCookiePolicy policy) => switch (policy) {
      ForumImageCookiePolicy.always => strings.imageCookiePolicyAlways,
      ForumImageCookiePolicy.sameSite => strings.imageCookiePolicySameSite,
      ForumImageCookiePolicy.never => strings.imageCookiePolicyNever,
    };

    String cookiePolicyDescription(ForumImageCookiePolicy policy) =>
        switch (policy) {
          ForumImageCookiePolicy.always =>
            strings.imageCookiePolicyAlwaysDescription,
          ForumImageCookiePolicy.sameSite =>
            strings.imageCookiePolicySameSiteDescription,
          ForumImageCookiePolicy.never =>
            strings.imageCookiePolicyNeverDescription,
        };

    // Cupertino list tiles impose a line limit. Let settings text wrap so
    // labels and explanations remain readable at larger accessibility sizes.
    Widget wrappingText(String text) => Builder(
      builder: (context) => DefaultTextStyle(
        style: DefaultTextStyle.of(context).style,
        softWrap: true,
        child: Text(text),
      ),
    );

    Widget switchTile({
      required String title,
      required IconData icon,
      required bool value,
      required ForumDisplayPreferences Function(bool) update,
      String? description,
    }) {
      void change(bool next) {
        final updated = update(next);
        preference.setForumDisplay(updated);
        UserPreferencesUtils.putForumDisplayPreference(updated);
      }

      return PlatformSettingsTile(
        title: wrappingText(title),
        subtitle: description == null ? null : wrappingText(description),
        leading: Icon(icon),
        trailing: PlatformSwitch(
          value: value,
          activeColor: Theme.of(context).colorScheme.primary,
          onChanged: change,
        ),
        onTap: () => change(!value),
      );
    }

    Future<void> chooseCookiePolicy() async {
      final selected = await showPlatformModalSheet<ForumImageCookiePolicy>(
        context: context,
        material: const MaterialModalSheetData(isScrollControlled: true),
        builder: (sheetContext) => PlatformSettingsList(
          shrinkWrap: true,
          children: [
            PlatformSettingsSection(
              title: wrappingText(strings.imageCookiePolicyTitle),
              children: [
                for (final policy in ForumImageCookiePolicy.values)
                  PlatformSettingsTile(
                    title: wrappingText(cookiePolicyLabel(policy)),
                    subtitle: wrappingText(cookiePolicyDescription(policy)),
                    trailing: policy == display.imageCookiePolicy
                        ? const Icon(Icons.check)
                        : null,
                    onTap: () => Navigator.of(sheetContext).pop(policy),
                  ),
              ],
            ),
          ],
        ),
      );
      if (!context.mounted || selected == null) return;
      final current = preference.forumDisplay;
      if (selected == current.imageCookiePolicy) return;
      final updated = current.copyWith(imageCookiePolicy: selected);
      preference.setForumDisplay(updated);
      await UserPreferencesUtils.putForumDisplayPreference(updated);
    }

    return PlatformScaffold(
      iosContentPadding: true,
      appBar: PlatformAppBar(title: Text(strings.forumDisplaySettingsTitle)),
      body: PlatformSettingsList(
        children: [
          PlatformSettingsSection(
            children: [
              switchTile(
                title: strings.mergeHomeNavigation,
                description: strings.mergeHomeNavigationDescription,
                icon: Icons.tab_unselected,
                value: display.mergeHomeNavigation,
                update: (value) => preference.forumDisplay.copyWith(
                  mergeHomeNavigation: value,
                ),
              ),
              switchTile(
                title: strings.showForumName,
                icon: Icons.public,
                value: display.showForumName,
                update: (value) =>
                    preference.forumDisplay.copyWith(showForumName: value),
              ),
              switchTile(
                title: strings.showAccountInfo,
                icon: Icons.person_outline,
                value: display.showAccountInfo,
                update: (value) =>
                    preference.forumDisplay.copyWith(showAccountInfo: value),
              ),
              switchTile(
                title: strings.showThreadStats,
                icon: Icons.bar_chart,
                value: display.showThreadStats,
                update: (value) =>
                    preference.forumDisplay.copyWith(showThreadStats: value),
              ),
              if (!kIsWeb)
                PlatformSettingsTile(
                  title: wrappingText(strings.imageCookiePolicyTitle),
                  subtitle: wrappingText(
                    cookiePolicyLabel(display.imageCookiePolicy),
                  ),
                  leading: const Icon(Icons.image_outlined),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: chooseCookiePolicy,
                ),
              switchTile(
                title: strings.showForumCarousel,
                icon: Icons.view_carousel_outlined,
                value: display.showCarousel,
                update: (value) =>
                    preference.forumDisplay.copyWith(showCarousel: value),
              ),
              switchTile(
                title: strings.compactForumCarousel,
                icon: Icons.view_compact_outlined,
                value: display.compactCarousel,
                update: (value) =>
                    preference.forumDisplay.copyWith(compactCarousel: value),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
