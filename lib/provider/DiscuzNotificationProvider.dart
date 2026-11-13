import 'package:discuz_flutter/JsonResult/BaseVariableResult.dart';
import 'package:flutter/cupertino.dart';

import 'DiscuzAndUserNotifier.dart';

class DiscuzNotificationProvider with ChangeNotifier {
  DiscuzNotificationProvider({DiscuzAndUserNotifier? account})
    : _account = account,
      _session = account?.sessionIdentity {
    _account?.addListener(_onSessionChanged);
  }

  final DiscuzAndUserNotifier? _account;
  Object? _session;

  void _onSessionChanged() {
    final session = _account!.sessionIdentity;
    if (identical(session, _session)) return;
    _session = session;
    _noticeCount = NoticeCount();
    _baseVariableResult = BaseVariableResult();
    notifyListeners();
  }

  @override
  void dispose() {
    _account?.removeListener(_onSessionChanged);
    super.dispose();
  }

  NoticeCount _noticeCount = NoticeCount();

  NoticeCount get noticeCount => _noticeCount;

  void setNotificationCount(NoticeCount noticeCount) {
    this._noticeCount = noticeCount;
    notifyListeners();
  }

  BaseVariableResult _baseVariableResult = BaseVariableResult();

  BaseVariableResult get baseVariableResult => _baseVariableResult;

  void setBaseVariableResult(BaseVariableResult baseVariableResult) {
    this._baseVariableResult = baseVariableResult;
    notifyListeners();
  }
}
