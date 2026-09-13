import 'package:dio/dio.dart';
import '../JsonResult/ViewThreadResult.dart';

/// Resolve through Discuz: position/15 is wrong for deleted and trade posts.
/// Both requests use the site's default ppp and explicit ascending order.
class LocatedPostPage {
  final ViewThreadResult result;
  final int page;
  LocatedPostPage(this.result, this.page);
}

class PostLocator {
  static Future<LocatedPostPage> locate(
    Dio dio,
    String baseUrl,
    int tid,
    int pid,
  ) async {
    if (tid <= 0 || pid <= 0) throw const FormatException('Invalid post');
    final base = Uri.parse('${baseUrl.replaceAll(RegExp(r'/+$'), '')}/');
    final redirect = await dio.getUri<String>(
      base
          .resolve('forum.php')
          .replace(
            queryParameters: {
              'mod': 'redirect',
              'goto': 'findpost',
              'ptid': '$tid',
              'pid': '$pid',
              'ordertype': '0',
            },
          ),
      options: Options(
        followRedirects: false,
        responseType: ResponseType.plain,
        validateStatus: (status) =>
            status != null && status >= 200 && status < 400,
      ),
    );
    final destination = parseDestination(
      base,
      redirect.headers.value('location'),
      tid,
      pid,
    );
    if (destination == null)
      throw const FormatException('Post destination unavailable');
    final response = await dio.getUri(
      base
          .resolve('api/mobile/index.php')
          .replace(
            queryParameters: {
              'version': '4',
              'module': 'viewthread',
              'tid': '$tid',
              'page': '$destination',
              'ordertype': '0',
            },
          ),
      options: Options(responseType: ResponseType.json),
    );
    final result = ViewThreadResult.fromJson(
      response.data as Map<String, dynamic>,
    );
    if (result.getErrorString() != null ||
        result.threadVariables.threadInfo.tid != tid ||
        (int.tryParse(result.threadVariables.ppp) ?? 0) <= 0 ||
        !result.threadVariables.postList.any(
          (post) => post.pid == pid && post.tid == tid,
        )) {
      throw const FormatException('Post unavailable');
    }
    return LocatedPostPage(result, destination);
  }

  static int? parseDestination(Uri base, String? location, int tid, int pid) {
    if (location == null) return null;
    final uri = base.resolve(location.replaceAll('&amp;', '&'));
    if (uri.origin != base.origin ||
        uri.queryParameters['tid'] != '$tid' ||
        uri.queryParameters['mod'] != 'viewthread' ||
        uri.fragment != 'pid$pid')
      return null;
    final page = int.tryParse(uri.queryParameters['page'] ?? '1');
    return page != null && page > 0 ? page : null;
  }
}

class PostLinkTarget {
  final int tid;
  final int? pid;
  PostLinkTarget(this.tid, this.pid);
  static PostLinkTarget? parse(Uri uri) {
    final q = uri.queryParameters;
    if (q['mod'] != 'redirect' && q['mod'] != 'viewthread') return null;
    final tid = int.tryParse(q['tid'] ?? q['ptid'] ?? '');
    if (tid == null || tid <= 0) return null;
    final fragment = RegExp(
      r'^(?:pid|post_)(\d+)$',
    ).firstMatch(uri.fragment)?.group(1);
    final pid = int.tryParse(q['pid'] ?? q['viewpid'] ?? fragment ?? '');
    return PostLinkTarget(tid, pid != null && pid > 0 ? pid : null);
  }
}

/// Absolute page position matters when reading starts in the middle of a thread.
bool hasMoreThreadPages({
  required int page,
  required int postsPerPage,
  required int replies,
}) => postsPerPage > 0 && page * postsPerPage < replies + 1;
