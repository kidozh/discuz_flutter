import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../generated/l10n.dart';
import '../utility/PlatformAdaptiveWidgets.dart';

const _translateUrl = 'https://translate.google.com/';
const _policyUrl = 'https://docs.cloud.google.com/translate/attribution';

/// Kept next to the translated body, separate from any AI-generated summary.
class GoogleTranslationControls extends StatelessWidget {
  const GoogleTranslationControls({
    super.key,
    required this.translated,
    required this.busy,
    required this.onTranslate,
    required this.onChooseLanguage,
  });

  final bool translated;
  final bool busy;
  final VoidCallback onTranslate;
  final VoidCallback onChooseLanguage;

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final label = busy
        ? strings.postTranslating
        : translated
        ? strings.postShowOriginal
        : strings.googleTranslationAction;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (translated) const GoogleTranslationBadge(),
          Tooltip(
            message: strings.translationLongPress,
            child: GestureDetector(
              onSecondaryTap: onChooseLanguage,
              child: TextButton.icon(
                onPressed: busy ? null : onTranslate,
                onLongPress: onChooseLanguage,
                icon: busy
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(translated ? Icons.undo : Icons.translate, size: 18),
                label: Text(label),
                style: TextButton.styleFrom(minimumSize: const Size(44, 44)),
              ),
            ),
          ),
          IconButton(
            tooltip: strings.googleTranslationInfoTitle,
            icon: const Icon(Icons.info_outline, size: 18),
            onPressed: () => showGoogleTranslationInfo(context),
          ),
        ],
      ),
    );
  }
}

/// Original full-colour badge from Google's attribution asset package.
/// A white backing keeps its original black text legible in both themes.
class GoogleTranslationBadge extends StatelessWidget {
  const GoogleTranslationBadge({super.key});

  @override
  Widget build(BuildContext context) {
    void openTranslate() => launchUrl(Uri.parse(_translateUrl));
    final label = S.of(context).googleTranslationAttribution;
    return Semantics(
      label: label,
      link: true,
      onTap: openTranslate,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          child: InkWell(
            onTap: openTranslate,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
              child: Image.asset(
                'assets/translation/google_translate.png',
                width: 176,
                height: 16,
                fit: BoxFit.contain,
                excludeFromSemantics: true,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> showGoogleTranslationInfo(BuildContext context) =>
    showPlatformDialog<void>(
      context: context,
      builder: (context) => PlatformAlertDialog(
        title: Text(S.of(context).googleTranslationInfoTitle),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(S.of(context).googleTranslationInfoBody),
                const SizedBox(height: 16),
                FutureBuilder<String>(
                  future: _disclaimer,
                  builder: (context, snapshot) => snapshot.hasData
                      ? SelectableText(snapshot.data!)
                      : snapshot.hasError
                      ? TextButton(
                          onPressed: () => launchUrl(Uri.parse(_policyUrl)),
                          child: Text(S.of(context).googleTranslationPolicy),
                        )
                      : const CircularProgressIndicator(),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => launchUrl(
                    Uri.parse('https://cloud.google.com/translate'),
                  ),
                  child: const Text('Google Cloud Translation'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          PlatformTextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(S.of(context).ok),
          ),
        ],
      ),
    );

final _disclaimer = rootBundle.loadString(
  'assets/translation/google_disclaimer.txt',
);
