

import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:flutter/cupertino.dart';

class CaptchaWidget extends StatelessWidget{

  Discuz _discuz;
  User? _user;
  String captchaType;

  CaptchaWidget(this._discuz, this._user, this.captchaType);

  @override
  Widget build(BuildContext context) {
    return CaptchaStatefulWidget(_discuz, _user, captchaType);
  }
}


class CaptchaStatefulWidget extends StatefulWidget{
  Discuz _discuz;
  User? _user;
  String captchaType;

  CaptchaStatefulWidget(this._discuz, this._user, this.captchaType);

  @override
  State<StatefulWidget> createState() {
    return CaptchaState(_discuz, _user, captchaType);
  }


}

class CaptchaState extends State<CaptchaStatefulWidget>{
  Discuz _discuz;
  User? _user;
  String captchaType;



  CaptchaState(this._discuz, this._user, this.captchaType);



  @override
  Widget build(BuildContext context) {

    return Column(

    );
  }

}