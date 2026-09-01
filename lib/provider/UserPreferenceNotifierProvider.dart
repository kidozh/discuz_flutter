import 'package:flutter/cupertino.dart';

import '../utility/OnDeviceAiService.dart';

class UserPreferenceNotifierProvider with ChangeNotifier {
  bool _allowPush = false;

  bool get allowPush => _allowPush;

  set allowPush(bool value) {
    this._allowPush = value;
    notifyListeners();
  }

  void updateAllowPush(bool value) {
    this._allowPush = value;
    notifyListeners();
  }

  String _signature = "";

  String get signature => _signature;

  set signature(String value) {
    _signature = value;
    notifyListeners();
  }

  String _adExemptHost = "";

  bool _appleIntelligenceEnabled = false;
  bool _appleIntelligenceAvailable = false;
  bool _appleIntelligenceAvailabilityChecked = false;
  String _appleIntelligenceGuardrail = "standard";
  OnDeviceAiAvailabilityStatus _onDeviceAiStatus =
      OnDeviceAiAvailabilityStatus.unsupportedPlatform;

  bool get appleIntelligenceEnabled => _appleIntelligenceEnabled;
  bool get appleIntelligenceAvailable => _appleIntelligenceAvailable;
  bool get appleIntelligenceAvailabilityChecked =>
      _appleIntelligenceAvailabilityChecked;
  String get appleIntelligenceGuardrail => _appleIntelligenceGuardrail;
  OnDeviceAiAvailabilityStatus get onDeviceAiStatus => _onDeviceAiStatus;

  void setAppleIntelligenceEnabled(bool value) {
    if (_appleIntelligenceEnabled == value) return;
    _appleIntelligenceEnabled = value;
    notifyListeners();
  }

  void setAppleIntelligenceAvailability(bool value) {
    _appleIntelligenceAvailable = value;
    _appleIntelligenceAvailabilityChecked = true;
    _onDeviceAiStatus = value
        ? OnDeviceAiAvailabilityStatus.available
        : OnDeviceAiAvailabilityStatus.unavailable;
    if (!value) _appleIntelligenceEnabled = false;
    notifyListeners();
  }

  void setOnDeviceAiAvailability(OnDeviceAiAvailability availability) {
    _onDeviceAiStatus = availability.status;
    _appleIntelligenceAvailable = availability.isAvailable;
    _appleIntelligenceAvailabilityChecked = true;
    if (!availability.isAvailable) _appleIntelligenceEnabled = false;
    notifyListeners();
  }

  void setAppleIntelligenceGuardrail(String value) {
    if (_appleIntelligenceGuardrail == value) return;
    _appleIntelligenceGuardrail = value;
    notifyListeners();
  }

  String get adExemptHost => _adExemptHost;

  set adExemptHost(String value) {
    _adExemptHost = value;
    notifyListeners();
  }

  UserPreferenceNotifierProvider();
}
