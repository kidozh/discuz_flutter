

import 'package:discuz_flutter/JsonResult/BaseVariableResult.dart';
import 'package:flutter/cupertino.dart';

class DiscuzNotificationProvider with ChangeNotifier{

  NoticeCount _noticeCount = NoticeCount();

  NoticeCount get noticeCount => _noticeCount;

  void setNotificationCount(NoticeCount noticeCount){
    this._noticeCount = noticeCount;
    notifyListeners();
  }

  BaseVariableResult _baseVariableResult = BaseVariableResult();

  BaseVariableResult get baseVariableResult => _baseVariableResult;

  void setBaseVariableResult(BaseVariableResult baseVariableResult){
    this._baseVariableResult = baseVariableResult;
    notifyListeners();
  }

}