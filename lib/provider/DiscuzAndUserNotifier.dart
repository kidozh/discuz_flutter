import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';


class DiscuzAndUserNotifier with ChangeNotifier {
  Discuz? _discuz = null;
  User? _user = null;

  DiscuzAndUserNotifier() {
    _fetchSomething();
  }

  void setDiscuz(Discuz? discuz){
    this._discuz = discuz;
    notifyListeners();
  }

  void setUser(User? user){
    this._user = user;
    notifyListeners();
  }

  Future<void> _fetchSomething() async {}
}