import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Replaces a streamed summary in place when the model starts a new draft.
/// The dimmed tail belongs to the previous draft and is overwritten as new
/// text arrives. Completion commits only the model's final answer.
class SummaryStreamingText extends StatefulWidget {
  const SummaryStreamingText({
    super.key,
    required this.text,
    required this.loading,
  });

  final String text;
  final bool loading;

  @override
  State<SummaryStreamingText> createState() => _SummaryStreamingTextState();
}

class _SummaryStreamingTextState extends State<SummaryStreamingText> {
  String _prefix = '';
  String _tail = '';
  List<String> _previous = const [];

  @override
  void initState() {
    super.initState();
    _replace();
  }

  @override
  void didUpdateWidget(covariant SummaryStreamingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text || widget.loading != oldWidget.loading) {
      _replace();
    }
  }

  void _replace() {
    if (!widget.loading) {
      _prefix = widget.text;
      _tail = '';
      _previous = const [];
      return;
    }
    if (widget.text.isEmpty) return;
    if (!widget.text.startsWith(_prefix)) {
      _previous = '$_prefix$_tail'.characters.toList();
    }
    _prefix = widget.text;
    _tail = _previous.skip(_prefix.characters.length).join();
  }

  @override
  Widget build(BuildContext context) => _SummaryExtent(
    // Reflow normally after a width, font or text-scaling change.
    key: ValueKey((
      MediaQuery.textScalerOf(context),
      DefaultTextStyle.of(context).style,
      Directionality.of(context),
    )),
    holdHeight: widget.loading,
    child: Text.rich(
      TextSpan(
        text: _prefix,
        children: [
          if (_tail.isNotEmpty)
            TextSpan(
              text: _tail,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    ),
  );
}

/// Keeps earlier lines in place without measuring the text a second time.
class _SummaryExtent extends SingleChildRenderObjectWidget {
  const _SummaryExtent({
    super.key,
    required this.holdHeight,
    required super.child,
  });

  final bool holdHeight;

  @override
  _RenderSummaryExtent createRenderObject(BuildContext context) =>
      _RenderSummaryExtent(holdHeight);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderSummaryExtent renderObject,
  ) {
    renderObject.holdHeight = holdHeight;
  }
}

class _RenderSummaryExtent extends RenderProxyBox {
  _RenderSummaryExtent(this._holdHeight);

  bool _holdHeight;
  double _height = 0;
  double? _width;

  set holdHeight(bool value) {
    if (_holdHeight == value) return;
    _holdHeight = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    child!.layout(constraints, parentUsesSize: true);
    if (!_holdHeight || _width != constraints.maxWidth) _height = 0;
    _width = constraints.maxWidth;
    _height = math.max(_height, child!.size.height);
    size = constraints.constrain(Size(child!.size.width, _height));
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final natural = child!.getDryLayout(constraints);
    final height = _holdHeight && _width == constraints.maxWidth
        ? math.max(_height, natural.height)
        : natural.height;
    return constraints.constrain(Size(natural.width, height));
  }
}
