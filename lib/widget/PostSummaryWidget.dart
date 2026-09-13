import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../generated/l10n.dart';
import '../provider/UserPreferenceNotifierProvider.dart';
import '../utility/AiPostText.dart';
import '../utility/FoundationModelFrameworkUtils.dart';
import '../utility/OnDeviceAiService.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import 'summary_sweep.dart';

class PostSummaryWidget extends StatefulWidget {
  const PostSummaryWidget({
    super.key,
    required this.html,
    this.onContentChanged,
  });
  final String html;
  final VoidCallback? onContentChanged;

  @override
  State<PostSummaryWidget> createState() => _PostSummaryWidgetState();
}

class _PostSummaryWidgetState extends State<PostSummaryWidget> {
  String? _requestKey;
  Future<String>? _summary;
  String? _source;
  String _text = '';
  AsyncSnapshot<String>? _lastSnapshot;

  @override
  Widget build(BuildContext context) {
    final preferences = context.watch<UserPreferenceNotifierProvider>();
    if (_source != widget.html) {
      _source = widget.html;
      _text = AiPostText.plainText(widget.html);
    }
    if (!OnDeviceAiService.isApplePlatform ||
        !preferences.appleIntelligenceEnabled ||
        !preferences.appleIntelligenceAvailable ||
        !preferences.autoSummarizeEnabled ||
        _text.runes.length <= AiPostText.summaryThreshold) {
      _requestKey = null;
      _summary = null;
      return const SizedBox.shrink();
    }
    final language = Localizations.localeOf(context).toLanguageTag();
    final key = '$language|${preferences.appleIntelligenceGuardrail}|$_text';
    if (_requestKey != key) {
      _requestKey = key;
      _summary = OnDeviceAiService.summarize(
        _text,
        language: language,
        guardrailLevel: FoundationModelFrameworkUtils.guardrailLevelFromName(
          preferences.appleIntelligenceGuardrail,
        ),
        shouldContinue: () =>
            mounted &&
            _requestKey == key &&
            preferences.autoSummarizeEnabled &&
            preferences.appleIntelligenceEnabled,
      );
    }
    return FutureBuilder<String>(
      future: _summary,
      builder: (context, snapshot) {
        if (_lastSnapshot != snapshot) {
          _lastSnapshot = snapshot;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) widget.onContentChanged?.call();
          });
        }
        final loading = snapshot.connectionState != ConnectionState.done;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PlatformLiquidGlassCard(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            borderRadius: BorderRadius.circular(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SummarySweep(
                  active: loading,
                  child: Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        S.of(context).postSummaryTitle,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (snapshot.hasError)
                  PlatformTextButton(
                    onPressed: () => setState(() => _requestKey = null),
                    child: Text(S.of(context).postSummaryFailed),
                  )
                else
                  SummarySweep(
                    active: loading,
                    child: Text(
                      loading
                          ? S.of(context).postSummaryLoading
                          : snapshot.data ?? '',
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
