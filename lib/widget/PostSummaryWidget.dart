import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../generated/l10n.dart';
import '../provider/UserPreferenceNotifierProvider.dart';
import '../utility/AiPostText.dart';
import '../utility/FoundationModelFrameworkUtils.dart';
import '../utility/OnDeviceAiService.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import 'post_summary_card.dart';
import 'summary_streaming_text.dart';
import 'summary_sweep.dart';

class PostSummaryWidget extends StatefulWidget {
  const PostSummaryWidget({super.key, required this.html});
  final String html;

  @override
  State<PostSummaryWidget> createState() => _PostSummaryWidgetState();
}

class _PostSummaryWidgetState extends State<PostSummaryWidget> {
  String? _requestKey;
  Future<String>? _summary;
  Object? _request;
  bool _finished = false;
  String? _source;
  String _text = '';
  String _partial = '';
  bool _visible = true;

  void _clearRequest() {
    _requestKey = null;
    _request = null;
    _summary = null;
    _finished = false;
    _partial = '';
  }

  @override
  Widget build(BuildContext context) {
    final preferences = context.watch<UserPreferenceNotifierProvider>();
    _visible = TickerMode.valuesOf(context).enabled;
    if (_source != widget.html) {
      _source = widget.html;
      _text = AiPostText.plainText(widget.html);
    }
    if (!OnDeviceAiService.isSupportedPlatform ||
        !preferences.appleIntelligenceEnabled ||
        !preferences.appleIntelligenceAvailable ||
        !preferences.autoSummarizeEnabled ||
        _text.runes.length <= AiPostText.summaryThreshold) {
      _clearRequest();
      return const SizedBox.shrink();
    }
    final language = Localizations.localeOf(context).toLanguageTag();
    final key = '$language|${preferences.appleIntelligenceGuardrail}|$_text';
    if (!_visible) {
      // A hidden reader cancels pending inference, but keeps a settled answer
      // (or error) so returning does not flash the loading state or retry it.
      if (!_finished || _requestKey != key) {
        _clearRequest();
        return const SizedBox.shrink();
      }
    }
    if (_requestKey != key) {
      _requestKey = key;
      final request = _request = Object();
      _finished = false;
      _partial = '';
      _summary =
          OnDeviceAiService.summarize(
            _text,
            language: language,
            guardrailLevel:
                FoundationModelFrameworkUtils.guardrailLevelFromName(
                  preferences.appleIntelligenceGuardrail,
                ),
            onPartial: (text) {
              if (mounted && identical(_request, request) && _partial != text) {
                setState(() => _partial = text);
              }
            },
            shouldContinue: () =>
                mounted &&
                _visible &&
                identical(_request, request) &&
                preferences.autoSummarizeEnabled &&
                preferences.appleIntelligenceAvailable &&
                preferences.appleIntelligenceEnabled,
          ).whenComplete(() {
            if (mounted && identical(_request, request)) _finished = true;
          });
    }
    return Offstage(
      offstage: !_visible,
      child: FutureBuilder<String>(
        key: ObjectKey(_request),
        future: _summary,
        builder: (context, snapshot) {
          final loading = snapshot.connectionState != ConnectionState.done;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PostSummaryCard(
              active: loading && !snapshot.hasError,
              loading: loading,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          S.of(context).postSummaryTitle,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (snapshot.hasError)
                    PlatformTextButton(
                      onPressed: () => setState(() => _requestKey = null),
                      child: Text(S.of(context).postSummaryFailed),
                    )
                  else
                    SummarySweep(
                      active: loading && _partial.isEmpty,
                      child: loading && _partial.isEmpty
                          ? Text(S.of(context).postSummaryLoading)
                          : SummaryStreamingText(
                              key: ObjectKey(_request),
                              text: loading ? _partial : snapshot.data ?? '',
                              loading: loading,
                            ),
                    ),
                  if (!loading && !snapshot.hasError) ...[
                    const SizedBox(height: 8),
                    Text(
                      S.of(context).postSummaryDisclaimer,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
