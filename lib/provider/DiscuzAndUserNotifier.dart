import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:flutter/foundation.dart';

class DiscuzAndUserNotifier with ChangeNotifier {
  Discuz? _discuz;
  User? _user;
  Object _sessionIdentity = Object();

  Discuz? get discuz => _discuz;
  User? get user => _user;
  Object get sessionIdentity => _sessionIdentity;

  User? userFor(Discuz forum) => forum.isSameSite(_discuz) ? _user : null;

  void setDiscuz(Discuz? discuz) {
    if (discuz == null || !discuz.isSameSite(_discuz)) {
      initDiscuz(discuz);
      return;
    }
    _discuz = discuz;
    notifyListeners();
  }

  void initDiscuz(Discuz? discuz, {User? user}) {
    _discuz = discuz;
    _user = user != null && user.discuz.isSameSite(discuz) ? user : null;
    _sessionIdentity = Object();
    notifyListeners();
  }

  bool setUser(User? user, {Object? expectedSession}) {
    if ((expectedSession != null &&
            !identical(expectedSession, _sessionIdentity)) ||
        (user != null && !user.discuz.isSameSite(_discuz))) {
      return false;
    }
    _user = user;
    _sessionIdentity = Object();
    notifyListeners();
    return true;
  }
}
