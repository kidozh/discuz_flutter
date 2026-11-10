import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:flutter/foundation.dart';

class DiscuzAndUserNotifier with ChangeNotifier {
  Discuz? discuz = null;

  User? user = null;
  Object _sessionIdentity = Object();
  Object get sessionIdentity => _sessionIdentity;

  void setDiscuz(Discuz? discuz) {
    if (this.discuz?.baseURL != discuz?.baseURL) _sessionIdentity = Object();
    this.discuz = discuz;
    notifyListeners();
  }

  void initDiscuz(Discuz? discuz) {
    _sessionIdentity = Object();
    this.discuz = discuz;
    this.user = null;
    notifyListeners();
  }

  void setUser(User? user) {
    _sessionIdentity = Object();
    this.user = user;
    notifyListeners();
  }
}
