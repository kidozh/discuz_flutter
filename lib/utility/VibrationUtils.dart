import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:vibration/vibration.dart';


class VibrationUtils{

  static void vibrateWithClickIfPossible() async{
    bool canVibrate = await Vibration.hasVibrator == true;
    bool enableHapticFeedback = await UserPreferencesUtils.getHapticFeedbackPreference();
    if (canVibrate == true && enableHapticFeedback){
      Vibration.vibrate(amplitude: 100);
    }
  }

  static void vibrateWithSwitchIfPossible() async{
    bool canVibrate = await Vibration.hasVibrator == true;
    bool enableHapticFeedback = await UserPreferencesUtils.getHapticFeedbackPreference();
    if (canVibrate && enableHapticFeedback){
      Vibration.vibrate(amplitude: 130);
    }
  }

  static void vibrateSuccessfullyIfPossible() async{
    bool canVibrate = await Vibration.hasVibrator == true;
    bool enableHapticFeedback = await UserPreferencesUtils.getHapticFeedbackPreference();
    if (canVibrate && enableHapticFeedback){
      Vibration.vibrate(amplitude: 130);
    }
  }

  static void vibrateWithSelectionIfPossible() async{
    bool canVibrate = await Vibration.hasVibrator == true;
    bool enableHapticFeedback = await UserPreferencesUtils.getHapticFeedbackPreference();
    if (canVibrate && enableHapticFeedback){
      Vibration.vibrate(amplitude: 140);

    }
  }

  static void vibrateErrorIfPossible() async{
    bool canVibrate = await Vibration.hasVibrator == true;
    bool enableHapticFeedback = await UserPreferencesUtils.getHapticFeedbackPreference();
    if (canVibrate && enableHapticFeedback){
      Vibration.vibrate(amplitude: 160);

    }
  }

  static void vibrateWithHeavyFeedbackIfPossible() async{
    bool canVibrate = await Vibration.hasVibrator == true;
    bool enableHapticFeedback = await UserPreferencesUtils.getHapticFeedbackPreference();
    if (canVibrate && enableHapticFeedback){

    }
  }
}