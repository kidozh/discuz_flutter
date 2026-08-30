import 'package:flutter/cupertino.dart';

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

  bool get appleIntelligenceEnabled => _appleIntelligenceEnabled;
  bool get appleIntelligenceAvailable => _appleIntelligenceAvailable;
  bool get appleIntelligenceAvailabilityChecked =>
      _appleIntelligenceAvailabilityChecked;
  String get appleIntelligenceGuardrail => _appleIntelligenceGuardrail;

  void setAppleIntelligenceEnabled(bool value) {
    if (_appleIntelligenceEnabled == value) return;
    _appleIntelligenceEnabled = value;
    notifyListeners();
  }

  void setAppleIntelligenceAvailability(bool value) {
    _appleIntelligenceAvailable = value;
    _appleIntelligenceAvailabilityChecked = true;
    if (!value) _appleIntelligenceEnabled = false;
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
