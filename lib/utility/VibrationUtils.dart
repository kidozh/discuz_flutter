import 'dart:developer';

import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:haptic_feedback/haptic_feedback.dart';


class VibrationUtils{

  static void vibrateWithClickIfPossible() async{
    bool canVibrate = await Haptics.canVibrate();
    bool enableHapticFeedback = await UserPreferencesUtils.getHapticFeedbackPreference();
    log("CAN VIBRATE ${canVibrate} ? ${enableHapticFeedback}");
    if (canVibrate == true && enableHapticFeedback){

      await Haptics.vibrate(HapticsType.light);
    }
  }

  static void vibrateWithSwitchIfPossible() async{
    bool canVibrate = await Haptics.canVibrate();
    bool enableHapticFeedback = await UserPreferencesUtils.getHapticFeedbackPreference();
    
    if (canVibrate == true && enableHapticFeedback){
      await Haptics.vibrate(HapticsType.medium);
    }
  }

  static void vibrateSuccessfullyIfPossible() async{
    bool canVibrate = await Haptics.canVibrate();
    bool enableHapticFeedback = await UserPreferencesUtils.getHapticFeedbackPreference();
    
    if (canVibrate == true && enableHapticFeedback){
      await Haptics.vibrate(HapticsType.success);
    }
  }

  static void vibrateWithSelectionIfPossible() async{
    bool canVibrate = await Haptics.canVibrate();
    bool enableHapticFeedback = await UserPreferencesUtils.getHapticFeedbackPreference();
    
    if (canVibrate == true && enableHapticFeedback){
      await Haptics.vibrate(HapticsType.selection);

    }
  }

  static void vibrateErrorIfPossible() async{
    bool canVibrate = await Haptics.canVibrate();
    bool enableHapticFeedback = await UserPreferencesUtils.getHapticFeedbackPreference();
    
    if (canVibrate == true && enableHapticFeedback){
      await Haptics.vibrate(HapticsType.error);

    }
  }

  static void vibrateWithHeavyFeedbackIfPossible() async{
    bool canVibrate = await Haptics.canVibrate();
    bool enableHapticFeedback = await UserPreferencesUtils.getHapticFeedbackPreference();
    
    if (canVibrate == true && enableHapticFeedback){
      await Haptics.vibrate(HapticsType.heavy);
    }
  }
}