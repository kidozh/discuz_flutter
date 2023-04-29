import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

class VibrationUtils{

  static void vibrateWithClickIfPossible() async{
    bool canVibrate = await Vibrate.canVibrate;
    bool enableHapticFeedback = await UserPreferencesUtils.getHapticFeedbackPreference();
    if (canVibrate && enableHapticFeedback){
      Vibrate.feedback(FeedbackType.medium);
    }
  }

  static void vibrateWithSwitchIfPossible() async{
    bool canVibrate = await Vibrate.canVibrate;
    bool enableHapticFeedback = await UserPreferencesUtils.getHapticFeedbackPreference();
    if (canVibrate && enableHapticFeedback){
      Vibrate.feedback(FeedbackType.heavy);
    }
  }

  static void vibrateSuccessfullyIfPossible() async{
    bool canVibrate = await Vibrate.canVibrate;
    bool enableHapticFeedback = await UserPreferencesUtils.getHapticFeedbackPreference();
    if (canVibrate && enableHapticFeedback){
      Vibrate.feedback(FeedbackType.success);
    }
  }

  static void vibrateWithSelectionIfPossible() async{
    bool canVibrate = await Vibrate.canVibrate;
    bool enableHapticFeedback = await UserPreferencesUtils.getHapticFeedbackPreference();
    if (canVibrate && enableHapticFeedback){
      Vibrate.feedback(FeedbackType.selection);
    }
  }

  static void vibrateErrorIfPossible() async{
    bool canVibrate = await Vibrate.canVibrate;
    bool enableHapticFeedback = await UserPreferencesUtils.getHapticFeedbackPreference();
    if (canVibrate && enableHapticFeedback){
      Vibrate.feedback(FeedbackType.error);
    }
  }
}