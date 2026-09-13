/// A translation belongs to one post revision and target language only.
class PostTranslationState {
  Object? _identity;
  int _revision = 0;
  String? translation;
  bool showingTranslation = false;
  bool busy = false;

  void bind(Object identity) {
    if (_identity == identity) return;
    _identity = identity;
    _revision++;
    translation = null;
    showingTranslation = false;
    busy = false;
  }

  int begin() {
    busy = true;
    return ++_revision;
  }

  bool isCurrent(int revision) => revision == _revision;

  void complete(int revision, String text) {
    if (!isCurrent(revision)) return;
    busy = false;
    translation = text;
    showingTranslation = true;
  }

  void finish(int revision) {
    if (isCurrent(revision)) busy = false;
  }

  void toggle() {
    if (!busy && translation != null) showingTranslation = !showingTranslation;
  }
}
