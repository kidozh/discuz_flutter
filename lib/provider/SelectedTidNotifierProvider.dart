

import 'package:flutter/foundation.dart';

class SelectedTidNotifierProvider with ChangeNotifier {

  int tid = 0;


  void setTid(int tid){
    this.tid = tid;
    notifyListeners();
  }
}