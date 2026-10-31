import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../generated/l10n.dart';
import '../utility/PlatformAdaptiveWidgets.dart';

const _translateUrl = 'https://translate.google.com/';
const _policyUrl = 'https://docs.cloud.google.com/translate/attribution';

/// Android attribution appears only alongside the translated body.
class GoogleTranslationAttribution extends StatelessWidget {
  const GoogleTranslationAttribution({super.key, required this.translated});

  final bool translated;

  @override
  Widget build(BuildContext context) {
    if (!translated) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: const Align(
        alignment: AlignmentDirectional.centerStart,
        child: GoogleTranslationBadge(),
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
