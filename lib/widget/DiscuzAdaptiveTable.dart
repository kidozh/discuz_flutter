import 'dart:async';
import 'dart:math' as math;

import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:html/dom.dart' as dom;

/// Repairs a common Discuz table serialization bug before the HTML parser can
/// move orphaned cells outside their table (HTML "foster parenting").
///
/// Affected posts open one `<tr>` per logical row but emit `</tr>` after every
/// cell. In that shape, every `<tr>` opening is still a reliable row boundary.
class DiscuzTableNormalizer {
  static final RegExp _tablePattern = RegExp(
    r'<table\b[\s\S]*?</table\s*>',
    caseSensitive: false,
  );
  static final RegExp _rowOpenPattern = RegExp(
    r'<tr\b[^>]*>',
    caseSensitive: false,
  );
  static final RegExp _rowClosePattern = RegExp(
    r'</tr\s*>',
    caseSensitive: false,
  );
  static final RegExp _rowAndGroupPattern = RegExp(
    r'<tr\b[^>]*>|</tr\s*>|</(?:thead|tbody|tfoot)\s*>',
    caseSensitive: false,
  );

  const DiscuzTableNormalizer._();

  static String normalizeHtml(String html) {
    if (!html.toLowerCase().contains('<table')) return html;
    return html.replaceAllMapped(
      _tablePattern,
      (match) => normalizeTable(match.group(0)!),
    );
  }

  static String normalizeTable(String tableHtml) {
    final rowOpenCount = _rowOpenPattern.allMatches(tableHtml).length;
    final rowCloseCount = _rowClosePattern.allMatches(tableHtml).length;
    if (rowOpenCount == 0 || rowCloseCount <= rowOpenCount) return tableHtml;

    final openEnd = tableHtml.indexOf('>');
    final closeStart = tableHtml.toLowerCase().lastIndexOf('</table');
    if (openEnd < 0 || closeStart <= openEnd) return tableHtml;

    final openingTag = tableHtml.substring(0, openEnd + 1);
    final closingTag = tableHtml.substring(closeStart);
    final body = tableHtml.substring(openEnd + 1, closeStart);
    final repaired = StringBuffer();
    var cursor = 0;
    var rowOpen = false;

    for (final token in _rowAndGroupPattern.allMatches(body)) {
      repaired.write(body.substring(cursor, token.start));
      final rawToken = token.group(0)!;
      final lowerToken = rawToken.toLowerCase();
      if (lowerToken.startsWith('<tr')) {
        if (rowOpen) repaired.write('</tr>');
        repaired.write(rawToken);
        rowOpen = true;
      } else if (lowerToken.startsWith('</tr')) {
        // Ignore all close tags. A correct close is inserted at the next row
        // boundary (or before the row group/table ends).
      } else {
        if (rowOpen) {
          repaired.write('</tr>');
          rowOpen = false;
        }
        repaired.write(rawToken);
      }
      cursor = token.end;
    }
    repaired.write(body.substring(cursor));
    if (rowOpen) repaired.write('</tr>');
    return '$openingTag$repaired$closingTag';
  }
}

class DiscuzAdaptiveTable extends StatelessWidget {
  final dom.Element element;
  final TextStyle textStyle;
  final FutureOr<bool> Function(String)? onTapUrl;
  final ValueChanged<String>? onTapImage;

  const DiscuzAdaptiveTable({
    required this.element,
    required this.textStyle,
    this.onTapUrl,
    this.onTapImage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final data = _DiscuzTableData.fromElement(element);
    if (data.rows.isEmpty || data.columnCount == 0) {
      return const SizedBox.shrink();
    }

    return Semantics(
      container: true,
      child: _buildSurface(
        context,
        LayoutBuilder(
          builder: (context, constraints) {
            if (data.hasComplexSpans) {
              return _buildFallbackTable(context, data);
            }
            final availableWidth = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : MediaQuery.sizeOf(context).width;
            return _buildWideTable(context, data, availableWidth);
          },
        ),
      ),
    );
  }

  Widget _buildSurface(BuildContext context, Widget child) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final glass = usesAppleTranslucentSurface(context);
    final insideGlass = isInsidePlatformLiquidGlassContainer(context);
    const radius = BorderRadius.all(Radius.circular(18));

    if (glass && !insideGlass) {
      return PlatformLiquidGlassCard(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(8),
        borderRadius: radius,
        child: child,
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: glass
            ? Colors.white.withValues(alpha: dark ? 0.055 : 0.15)
            : Color.alphaBlend(
                colors.primary.withValues(alpha: dark ? 0.07 : 0.035),
                colors.surfaceContainerLow,
              ),
        borderRadius: radius,
        border: Border.all(
          color: glass
              ? Color.alphaBlend(
                  colors.primary.withValues(alpha: dark ? 0.22 : 0.12),
                  colors.onSurface.withValues(alpha: dark ? 0.28 : 0.16),
                )
              : colors.outlineVariant.withValues(
                  alpha: dark ? 0.58 : 0.78,
                ),
          width: glass ? 0.8 : 1,
        ),
      ),
      child: child,
    );
  }

  Widget _buildWideTable(
    BuildContext context,
    _DiscuzTableData data,
    double availableWidth,
  ) {
    final minimumWidth = switch (data.columnCount) {
      <= 1 => availableWidth,
      2 => 360.0,
      _ => 250.0 + (data.columnCount - 1) * 135.0,
    };
    final tableWidth = math.max(availableWidth, minimumWidth);
    final table = SizedBox(
      width: tableWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (data.captionHtml != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
              child: _buildCellHtml(
                context,
                data.captionHtml!,
                style: textStyle.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
          for (var row = 0; row < data.rows.length; row++)
            // Cache rows independently: an image loading or a horizontal scroll
            // must not re-record every other image/text cell in the table.
            RepaintBoundary(child: _buildWideRow(context, data, row)),
        ],
      ),
    );

    if (tableWidth <= availableWidth + 0.5) return table;
    return _DiscuzHorizontalTableViewport(child: table);
  }

  Widget _buildWideRow(
    BuildContext context,
    _DiscuzTableData data,
    int rowIndex,
  ) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final glass = usesAppleTranslucentSurface(context);
    final row = data.rows[rowIndex];
    final header = row.isHeader || rowIndex == data.headerRowIndex;
    final cells = List<_DiscuzTableCell?>.generate(
      data.columnCount,
      (index) => index < row.cells.length ? row.cells[index] : null,
    );

    final rowContent = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var column = 0; column < cells.length; column++)
          Expanded(
            flex: column == 0 && data.columnCount > 2 ? 3 : 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              child: cells[column] == null
                  ? const SizedBox.shrink()
                  : _buildCellHtml(
                      context,
                      cells[column]!.html,
                      style: textStyle.copyWith(
                        fontWeight:
                            header ? FontWeight.w600 : textStyle.fontWeight,
                        height: 1.35,
                      ),
                    ),
            ),
          ),
      ],
    );

    return Container(
      margin: EdgeInsets.only(bottom: glass ? 6 : 1),
      decoration: BoxDecoration(
        color: header
            ? colors.primary.withValues(alpha: dark ? 0.24 : 0.13)
            : rowIndex.isEven
                ? colors.onSurface.withValues(alpha: dark ? 0.045 : 0.025)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(glass ? 11 : 5),
      ),
      child: data.columnCount != 2
          ? rowContent
          : LayoutBuilder(
              builder: (context, constraints) => Stack(
                children: [
                  if (!header)
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: constraints.maxWidth / 2,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(
                            alpha: dark ? 0.055 : 0.035,
                          ),
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(glass ? 11 : 5),
                          ),
                        ),
                      ),
                    ),
                  rowContent,
                  Positioned(
                    left: constraints.maxWidth / 2,
                    top: 7,
                    bottom: 7,
                    child: Container(
                      width: 0.8,
                      color: colors.outlineVariant.withValues(
                        alpha:
                            glass ? (dark ? 0.52 : 0.44) : (dark ? 0.58 : 0.76),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFallbackTable(
    BuildContext context,
    _DiscuzTableData data,
  ) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    String cssColor(Color color) =>
        color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2);
    final border = colors.outlineVariant.withValues(alpha: dark ? 0.45 : 0.7);

    return HtmlWidget(
      data.outerHtml,
      textStyle: textStyle,
      onTapUrl: onTapUrl,
      onTapImage: _handleTapImage,
      customStylesBuilder: (element) {
        return switch (element.localName) {
          'table' => {
              'background-color': 'transparent',
              'border': 'none',
              'border-spacing': '0',
              'margin': '0',
            },
          'th' => {
              'background-color':
                  '#${cssColor(colors.primary.withValues(alpha: 0.15))}',
              'border': '0.05em solid #${cssColor(border)}',
              'padding': '0.55em 0.65em',
              'font-weight': '600',
            },
          'td' => {
              'background-color': 'transparent',
              'border': '0.05em solid #${cssColor(border)}',
              'padding': '0.55em 0.65em',
            },
          _ => _cellStyles(context, element),
        };
      },
    );
  }

  Widget _buildCellHtml(
    BuildContext context,
    String html, {
    required TextStyle style,
  }) {
    if (html.trim().isEmpty) return const SizedBox.shrink();
    return HtmlWidget(
      html,
      textStyle: style,
      onTapUrl: onTapUrl,
      onTapImage: _handleTapImage,
      customStylesBuilder: (element) => _cellStyles(context, element),
    );
  }

  Map<String, String>? _cellStyles(
    BuildContext context,
    dom.Element element,
  ) {
    final colors = Theme.of(context).colorScheme;
    String cssColor(Color color) =>
        color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2);
    final tag = element.localName;

    switch (tag) {
      case 'a':
        return {
          'color': '#${cssColor(colors.primary)}',
          'font-weight': '500',
          'text-decoration': 'none',
        };
      case 'strong':
      case 'b':
        return {'font-weight': '600'};
      case 'font':
        final original = element.attributes['color']?.toLowerCase();
        final isRed = original == '#ff0000' || original == 'red';
        return {
          'color': '#${cssColor(isRed ? colors.error : colors.onSurface)}',
          'background-color': 'transparent',
        };
      case 'p':
      case 'div':
        return {'margin': '0', 'padding': '0'};
      case 'img':
        return {
          'max-width': '100%',
          'height': 'auto',
          'border-radius': '0.5em',
        };
      default:
        return null;
    }
  }

  void _handleTapImage(ImageMetadata metadata) {
    if (onTapImage == null) return;
    for (final source in metadata.sources) {
      onTapImage!(source.url);
      return;
    }
  }
}

class _DiscuzTableData {
  final String outerHtml;
  final List<_DiscuzTableRow> rows;
  final int columnCount;
  final bool hasComplexSpans;
  final String? captionHtml;
  final int? headerRowIndex;

  const _DiscuzTableData({
    required this.outerHtml,
    required this.rows,
    required this.columnCount,
    required this.hasComplexSpans,
    required this.captionHtml,
    required this.headerRowIndex,
  });

  factory _DiscuzTableData.fromElement(dom.Element table) {
    bool belongsToTable(dom.Element candidate) {
      dom.Element? parent = candidate.parent;
      while (parent != null && parent.localName != 'table') {
        parent = parent.parent;
      }
      return identical(parent, table);
    }

    final rowElements = table
        .querySelectorAll('tr')
        .where(belongsToTable)
        .toList(growable: false);
    var complex = false;
    final rows = <_DiscuzTableRow>[];
    var columnCount = 0;

    for (final rowElement in rowElements) {
      final cellElements = rowElement.children
          .where(
            (child) => child.localName == 'td' || child.localName == 'th',
          )
          .toList(growable: false);
      if (cellElements.isEmpty) continue;
      final cells = <_DiscuzTableCell>[];
      var rowColumns = 0;
      for (final cell in cellElements) {
        final columnSpan = int.tryParse(cell.attributes['colspan'] ?? '') ?? 1;
        final rowSpan = int.tryParse(cell.attributes['rowspan'] ?? '') ?? 1;
        complex = complex || columnSpan != 1 || rowSpan != 1;
        rowColumns += math.max(1, columnSpan);
        cells.add(
          _DiscuzTableCell(
            html: cell.innerHtml.trim(),
            plainText: cell.text.trim(),
          ),
        );
      }
      columnCount = math.max(columnCount, rowColumns);
      final parentTag = rowElement.parent?.localName;
      rows.add(
        _DiscuzTableRow(
          cells: cells,
          isHeader: parentTag == 'thead' ||
              cellElements.every((cell) => cell.localName == 'th'),
        ),
      );
    }

    int? headerRowIndex;
    final explicitHeader = rows.indexWhere((row) => row.isHeader);
    if (explicitHeader >= 0) {
      headerRowIndex = explicitHeader;
    } else if (rows.length > 1 &&
        table.classes.contains('dzcode_table') &&
        rows.first.cells.length == columnCount) {
      headerRowIndex = 0;
    }

    final captions = table
        .querySelectorAll('caption')
        .where(belongsToTable)
        .toList(growable: false);
    return _DiscuzTableData(
      outerHtml: table.outerHtml,
      rows: rows,
      columnCount: columnCount,
      hasComplexSpans: complex,
      captionHtml: captions.isEmpty ? null : captions.first.innerHtml.trim(),
      headerRowIndex: headerRowIndex,
    );
  }
}

class _DiscuzTableRow {
  final List<_DiscuzTableCell> cells;
  final bool isHeader;

  const _DiscuzTableRow({required this.cells, required this.isHeader});
}

class _DiscuzTableCell {
  final String html;
  final String plainText;

  const _DiscuzTableCell({required this.html, required this.plainText});
}

class _DiscuzHorizontalTableViewport extends StatefulWidget {
  final Widget child;

  const _DiscuzHorizontalTableViewport({required this.child});

  @override
  State<_DiscuzHorizontalTableViewport> createState() =>
      _DiscuzHorizontalTableViewportState();
}

class _DiscuzHorizontalTableViewportState
    extends State<_DiscuzHorizontalTableViewport> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scrollView = SingleChildScrollView(
      controller: _controller,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(bottom: 6),
      child: widget.child,
    );
    if (isCupertino(context)) {
      return CupertinoScrollbar(
        controller: _controller,
        thumbVisibility: true,
        child: scrollView,
      );
    }
    return Scrollbar(
      controller: _controller,
      thumbVisibility: true,
      scrollbarOrientation: ScrollbarOrientation.bottom,
      child: scrollView,
    );
  }
}
