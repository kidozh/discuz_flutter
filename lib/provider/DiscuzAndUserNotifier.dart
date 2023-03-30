import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:flutter/foundation.dart';


class DiscuzAndUserNotifier with ChangeNotifier {
  Discuz? discuz = null;


  User? user = null;

  void setDiscuz(Discuz? discuz){
    this.discuz = discuz;
    notifyListeners();
  }

  void initDiscuz(Discuz? discuz){
    this.discuz = discuz;
    this.user = null;
    notifyListeners();
  }

  void setUser(User? user){
    this.user = user;
    notifyListeners();
  }
}