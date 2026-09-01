import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:html/dom.dart' as dom;

class DiscuzCodeBlock extends StatefulWidget {
  const DiscuzCodeBlock({
    required this.code,
    required this.textStyle,
    this.language,
    super.key,
  });

  final String code;
  final TextStyle textStyle;
  final String? language;

  static String extractCode(dom.Element element) {
    final listItems = element.querySelectorAll('ol > li');
    var value = listItems.isEmpty
        ? (element.querySelector('code')?.text ?? element.text)
        : listItems.map((item) => item.text).join('\n');
    value = value.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    if (value.startsWith('\n')) value = value.substring(1);
    if (value.endsWith('\n')) value = value.substring(0, value.length - 1);
    return value;
  }

  static String? extractLanguage(dom.Element element) {
    final code = element.querySelector('code');
    final attributes = <String?>[
      element.attributes['data-language'],
      element.attributes['lang'],
      code?.attributes['data-language'],
      code?.attributes['lang'],
    ];
    for (final candidate in attributes) {
      final language = _sanitizeLanguage(candidate);
      if (language != null) return language;
    }
    for (final candidate in [...element.classes, ...?code?.classes]) {
      for (final prefix in const ['language-', 'lang-']) {
        if (candidate.toLowerCase().startsWith(prefix)) {
          final language =
              _sanitizeLanguage(candidate.substring(prefix.length));
          if (language != null) return language;
        }
      }
    }
    return null;
  }

  static String? _sanitizeLanguage(String? value) {
    final language = value?.trim() ?? '';
    if (language.isEmpty || language.length > 24) return null;
    return RegExp(r'^[a-zA-Z0-9_+#.\-]+$').hasMatch(language) ? language : null;
  }

  @override
  State<DiscuzCodeBlock> createState() => _DiscuzCodeBlockState();
}

class _DiscuzCodeBlockState extends State<DiscuzCodeBlock> {
  final ScrollController _scrollController = ScrollController();
  bool _copied = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _copyCode() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    if (!mounted) return;
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final radius = BorderRadius.circular(15);
    final codeStyle = widget.textStyle.copyWith(
      color: colors.onSurface,
      fontFamily: isCupertino(context) ? 'Menlo' : 'monospace',
      fontFamilyFallback: const [
        'SF Mono',
        'Menlo',
        'Roboto Mono',
        'Noto Sans Mono CJK SC',
      ],
      fontSize: (widget.textStyle.fontSize ?? 14) * 0.92,
      fontWeight: FontWeight.w400,
      height: 1.55,
      letterSpacing: 0,
    );
    final borderColor = colors.onSurface.withValues(
      alpha: dark ? 0.24 : 0.13,
    );
    final backgroundColor = usesAppleTranslucentSurface(context)
        ? colors.surface.withValues(alpha: dark ? 0.26 : 0.38)
        : Color.alphaBlend(
            colors.primary.withValues(alpha: dark ? 0.10 : 0.045),
            colors.surfaceContainerLow,
          );

    final cardContent = ClipRRect(
      borderRadius: radius,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 38,
            padding: const EdgeInsetsDirectional.only(start: 13, end: 5),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: dark ? 0.12 : 0.065),
              border:
                  Border(bottom: BorderSide(color: borderColor, width: 0.7)),
            ),
            child: Row(
              children: [
                Icon(Icons.code_rounded, size: 16, color: colors.primary),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    (widget.language ?? 'code').toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.7,
                    ),
                  ),
                ),
                SizedBox(
                  width: 34,
                  height: 34,
                  child: IconButton(
                    tooltip: MaterialLocalizations.of(context).copyButtonLabel,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    onPressed: _copyCode,
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 160),
                      child: Icon(
                        _copied ? Icons.check_rounded : Icons.copy_rounded,
                        key: ValueKey(_copied),
                        size: 17,
                        color:
                            _copied ? colors.primary : colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              Widget scroller = SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(15, 13, 15, 15),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth:
                        (constraints.maxWidth - 30).clamp(0, double.infinity),
                  ),
                  child: SelectableText(
                    widget.code,
                    key: const ValueKey('discuz-code-text'),
                    style: codeStyle,
                  ),
                ),
              );
              scroller = isMaterial(context)
                  ? Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      child: scroller,
                    )
                  : CupertinoScrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      child: scroller,
                    );
              return scroller;
            },
          ),
        ],
      ),
    );

    if (usesAppleTranslucentSurface(context) &&
        !isInsidePlatformLiquidGlassContainer(context)) {
      return PlatformLiquidGlassCard(
        key: const ValueKey('discuz-code-block'),
        margin: const EdgeInsets.symmetric(vertical: 10),
        borderRadius: radius,
        tintColor: colors.primary,
        child: cardContent,
      );
    }

    return Container(
      key: const ValueKey('discuz-code-block'),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: radius,
        border: Border.all(color: borderColor, width: 0.8),
        boxShadow: dark
            ? null
            : [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: 0.055),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: cardContent,
    );
  }
}
