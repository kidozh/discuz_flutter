import 'package:flutter/foundation.dart';

import '../entity/Discuz.dart';

class SelectedTidNotifierProvider with ChangeNotifier {
  int _tid = 0;
  String? _site;

  int tidFor(Discuz forum) => _site == forum.siteIdentity ? _tid : 0;

  void setTid(int tid, Discuz? forum) {
    _tid = tid;
    _site = forum?.siteIdentity;
    notifyListeners();
  }
}
