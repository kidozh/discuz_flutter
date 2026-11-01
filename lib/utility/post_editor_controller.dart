import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// The editor displays these complete tokens as a single object. The draft and
/// the API continue to use the original forum markup.
class PostEditorToken {
  static final pattern = RegExp(
    r'\[attachimg\]\d+\[/attachimg\]|\[img(?:=\d+,\d+)?\][^\r\n]*?\[/img\]|\[smiley\].*?\[/smiley\]',
    caseSensitive: false,
    dotAll: true,
  );

  final int start;
  final String text;

  PostEditorToken(this.start, this.text);

  int get end => start + text.length;
  bool get isSmiley => text.toLowerCase().startsWith('[smiley]');
  bool get isAttachment => text.toLowerCase().startsWith('[attachimg]');
  String get content =>
      text.substring(text.indexOf(']') + 1, text.lastIndexOf('['));

  static Iterable<PostEditorToken> inText(String text) => pattern
      .allMatches(text)
      .map((match) => PostEditorToken(match.start, match.group(0)!));
}

/// Keep both keyboard deletion directions, selection replacement and paste
/// atomic. ExtendedTextField's built-in delete handler only handles backward
/// deletion, and can discard replacement text, so our spans delegate edits here.
class PostEditorInputFormatter extends TextInputFormatter {
  const PostEditorInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final before = oldValue.text;
    final after = newValue.text;
    if (before == after) return newValue;

    int start = 0;
    while (start < before.length &&
        start < after.length &&
        before[start] == after[start]) {
      start++;
    }
    int oldEnd = before.length;
    int newEnd = after.length;
    while (oldEnd > start &&
        newEnd > start &&
        before[oldEnd - 1] == after[newEnd - 1]) {
      oldEnd--;
      newEnd--;
    }

    // A selected range is authoritative when repeated characters make the
    // minimal string diff ambiguous (e.g. replacing an image with its URL).
    final selection = oldValue.selection;
    if (selection.isValid &&
        !selection.isCollapsed &&
        selection.end <= before.length) {
      final replacementLength =
          after.length - before.length + selection.end - selection.start;
      if (replacementLength >= 0 &&
          after.startsWith(before.substring(0, selection.start)) &&
          after.endsWith(before.substring(selection.end))) {
        start = selection.start;
        oldEnd = selection.end;
        newEnd = start + replacementLength;
      }
    }

    int expandedStart = start;
    int expandedEnd = oldEnd;
    for (final token in PostEditorToken.inText(before)) {
      if (start == oldEnd && start > token.start && start < token.end) {
        // A stale IME selection can point inside the hidden markup. Insert at
        // the nearest edge without replacing the image.
        final edge = start - token.start < token.end - start
            ? token.start
            : token.end;
        final inserted = after.substring(start, newEnd);
        return TextEditingValue(
          text: before.replaceRange(edge, edge, inserted),
          selection: TextSelection.collapsed(offset: edge + inserted.length),
        );
      }
      if (start < token.end && oldEnd > token.start) {
        if (token.start < expandedStart) expandedStart = token.start;
        if (token.end > expandedEnd) expandedEnd = token.end;
      }
    }
    if (expandedStart == start && expandedEnd == oldEnd) return newValue;

    // Undo can replace one complete image with another that shares its markup
    // prefix/suffix. Preserve a complete replacement when its caret is outside
    // the object; a partial keyboard edit still removes the whole old object.
    final replacementEnd = expandedEnd + after.length - before.length;
    final newTokens = PostEditorToken.inText(after)
        .where(
          (token) =>
              token.start >= expandedStart && token.end <= replacementEnd,
        )
        .toList();
    if (newTokens.isNotEmpty &&
        newTokens.first.start == expandedStart &&
        newTokens.last.end == replacementEnd &&
        postEditorSelection(after, newValue.selection) == newValue.selection) {
      return newValue;
    }

    final inserted = after.substring(start, newEnd);
    final leftRemoved = start - expandedStart;
    final rightRemoved = expandedEnd - oldEnd;
    int mapOffset(int offset) {
      if (offset <= expandedStart) return offset;
      if (offset <= start) return expandedStart;
      if (offset <= newEnd) return offset - leftRemoved;
      if (offset <= newEnd + rightRemoved) {
        return expandedStart + inserted.length;
      }
      return offset - leftRemoved - rightRemoved;
    }

    final composing = newValue.composing;
    return newValue.copyWith(
      text: before.replaceRange(expandedStart, expandedEnd, inserted),
      selection: newValue.selection.isValid
          ? newValue.selection.copyWith(
              baseOffset: mapOffset(newValue.selection.baseOffset),
              extentOffset: mapOffset(newValue.selection.extentOffset),
            )
          : newValue.selection,
      composing: composing.isValid
          ? TextRange(
              start: mapOffset(composing.start),
              end: mapOffset(composing.end),
            )
          : TextRange.empty,
    );
  }
}

TextSelection postEditorSelection(
  String text,
  TextSelection selection, {
  TextSelection? previous,
}) {
  if (!selection.isValid) return selection;
  int start = selection.start;
  int end = selection.end;
  for (final token in PostEditorToken.inText(text)) {
    if (selection.isCollapsed && start > token.start && start < token.end) {
      final oldOffset = previous?.isValid == true && previous!.isCollapsed
          ? previous.extentOffset
          : start;
      final edge = oldOffset < start
          ? token.end
          : oldOffset > start
          ? token.start
          : start - token.start < token.end - start
          ? token.start
          : token.end;
      return selection.copyWith(baseOffset: edge, extentOffset: edge);
    }
    if (start > token.start && start < token.end) start = token.start;
    if (end > token.start && end < token.end) end = token.end;
  }
  return selection.copyWith(
    baseOffset: selection.baseOffset <= selection.extentOffset ? start : end,
    extentOffset: selection.baseOffset <= selection.extentOffset ? end : start,
  );
}

/// Per-draft paths give freshly uploaded images a preview even when attachment
/// history is disabled. Paths never become part of the posted message.
class PostEditorController extends TextEditingController {
  final Map<String, String> _imagePaths = {};

  PostEditorController({super.text});

  String? imagePathFor(String token) => _imagePaths[token];

  void insertText(String inserted, {bool image = false}) {
    final selected = postEditorSelection(text, selection);
    final start = selected.isValid ? selected.start : text.length;
    final end = selected.isValid ? selected.end : text.length;
    final prefix = image && start > 0 && text[start - 1] != '\n' ? '\n' : '';
    final suffix = image && (end == text.length || text[end] != '\n')
        ? '\n'
        : '';
    final replacement = '$prefix$inserted$suffix';
    value = TextEditingValue(
      text: text.replaceRange(start, end, replacement),
      selection: TextSelection.collapsed(offset: start + replacement.length),
    );
  }

  void insertAttachment(String aid, String path) {
    if (!RegExp(r'^\d+$').hasMatch(aid)) return;
    _insertImage('[attachimg]$aid[/attachimg]', path);
  }

  void insertHostedImage(String url, String path) {
    final uri = Uri.tryParse(url);
    if (uri == null ||
        !['http', 'https'].contains(uri.scheme) ||
        uri.host.isEmpty) {
      return;
    }
    _insertImage('[img]$url[/img]', path);
  }

  void _insertImage(String token, String path) {
    if (path.isNotEmpty) _imagePaths[token] = path;
    insertText(token, image: true);
  }
}

void removePostEditorImage(
  TextEditingController controller,
  PostEditorToken token,
) {
  if (token.start < 0 ||
      token.end > controller.text.length ||
      controller.text.substring(token.start, token.end) != token.text) {
    return;
  }
  final text = controller.text;
  // Remove the separator belonging to a standalone image line as well.
  final ownLine = token.start == 0 || text[token.start - 1] == '\n';
  final end = ownLine && token.end < text.length && text[token.end] == '\n'
      ? token.end + 1
      : token.end;
  int mapOffset(int offset) => offset <= token.start
      ? offset
      : offset < end
      ? token.start
      : offset - end + token.start;
  final selection = controller.selection;
  controller.value = TextEditingValue(
    text: text.replaceRange(token.start, end, ''),
    selection: selection.isValid
        ? selection.copyWith(
            baseOffset: mapOffset(selection.baseOffset),
            extentOffset: mapOffset(selection.extentOffset),
          )
        : TextSelection.collapsed(offset: token.start),
  );
}
