import 'package:discuz_flutter/JsonResult/PrivateMessageDetailResult.dart';

/// Discuz numbers conversation pages from oldest to newest. Page zero asks
/// space_pm.php to resolve the latest page on the server.
class PrivateMessagePagination {
  int _nextOlderPage = 0;
  bool hasMore = true;

  int pageFor({bool latest = false}) => latest ? 0 : _nextOlderPage;

  void accept(PrivateMessageDetailVariables response) {
    _nextOlderPage = response.page > 1 ? response.page - 1 : 0;
    // Cached/local messages are not evidence that every server page was read.
    hasMore = _nextOlderPage > 0 && response.pmList.isNotEmpty;
  }
}
