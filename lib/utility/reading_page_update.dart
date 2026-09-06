import 'package:discuz_flutter/JsonResult/ViewThreadResult.dart';
import 'package:discuz_flutter/entity/Post.dart';

/// An accepted page update. Error responses can contain placeholder posts, so
/// validate the response before changing content, cache or the next page number.
class ReadingPageUpdate {
  final List<Post> posts;
  final int nextPage;

  ReadingPageUpdate._(this.posts, this.nextPage);

  static ReadingPageUpdate? fromResponse(ViewThreadResult response,
      {required List<Post> currentPosts,
      required int requestedPage,
      required int initialPage,
      required int cachedPrefixCount}) {
    if (response.getErrorString() != null || response.errorResult != null) {
      return null;
    }
    final prefix = requestedPage == 1
        ? const <Post>[]
        : requestedPage == initialPage
            ? currentPosts.take(cachedPrefixCount)
            : currentPosts;
    return ReadingPageUpdate._(
        [...prefix, ...response.threadVariables.postList], requestedPage + 1);
  }
}
