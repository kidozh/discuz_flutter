import 'package:flutter_test/flutter_test.dart';
import 'package:discuz_flutter/utility/post_translation_state.dart';

void main() {
  test('translation toggles in place using cached result', () {
    final state = PostTranslationState()..bind(('post', 'en'));
    final request = state.begin();
    state.toggle();
    expect(state.showingTranslation, isFalse);
    state.complete(request, 'Translated');
    expect(state.showingTranslation, isTrue);
    state.toggle();
    expect(state.showingTranslation, isFalse);
    expect(state.translation, 'Translated');
    state.toggle();
    expect(state.showingTranslation, isTrue);
  });
  test('post or language changes invalidate in-flight requests', () {
    final state = PostTranslationState()..bind(('post', 'en'));
    final oldRequest = state.begin();
    state.bind(('post', 'zh'));
    state.complete(oldRequest, 'Stale');
    expect(state.translation, isNull);
    expect(state.busy, isFalse);
    final request = state.begin();
    state.bind(('post', 'zh'));
    expect(state.isCurrent(request), isTrue);
    state.finish(request);
    expect(state.busy, isFalse);
    expect(state.showingTranslation, isFalse);
  });
}
