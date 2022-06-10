

import 'package:flutter/cupertino.dart';

class UserPreferenceNotifierProvider with ChangeNotifier{
  bool _allowPush = false;

  bool get allowPush => _allowPush;

  set allowPush(bool value){
    this._allowPush = value;
    notifyListeners();
  }

  void updateAllowPush(bool value){
    this._allowPush = value;
    notifyListeners();
  }

  String _signature = "";

  String get signature => _signature;

  set signature(String value){
    _signature = value;
    notifyListeners();
  }

  UserPreferenceNotifierProvider();
}