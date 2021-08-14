import 'package:flutter_vibrate/flutter_vibrate.dart';

class VibrationUtils{

  static void vibrateWithClickIfPossible() async{
    bool canVibrate = await Vibrate.canVibrate;
    if (canVibrate){
      Vibrate.feedback(FeedbackType.impact);
    }
  }
}