import 'package:discuz_flutter/generated/l10n.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

Map<String, MaterialColor> themeColorMap = {
  'grey': Colors.grey,
  'blue': Colors.blue,
  'cyan': Colors.cyan,
  'deepPurple': Colors.purple,
  'deepOrange': Colors.orange,
  'green': Colors.green,
  'indigo': Colors.indigo,
  'orange': Colors.orange,
  'purple': Colors.purple,
  'pink': Colors.pink,
  'red': Colors.red,
  'teal': Colors.teal,
  'brown': Colors.brown,
  "amber": Colors.amber,
  "lightBlue": Colors.lightBlue,
  "blueGrey":Colors.blueGrey,
  "lightGreen": Colors.lightGreen,
  "lime":Colors.lime,
  "yellow":Colors.yellow,
};



class ThemeNotifierProvider with ChangeNotifier{
  int _themeColor = Colors.blue.value;

  String _platformName ="";

  String get themeColorName => ColorTools.nameThatColor(Color(_themeColor));

  Brightness? _brightnessPreference;

  bool _useMaterial3 = true;

  get useMaterial3 => _useMaterial3;

  set userMaterial3(bool value){
    this._useMaterial3 = value;
    notifyListeners();
  }

  setBrightness(Brightness? brightness){
    _brightnessPreference = brightness;
    notifyListeners();
  }

  Brightness? get brightness => _brightnessPreference;

  //Brightness? get brightness => null;


  setTheme(int themeColorValue){
    _themeColor = themeColorValue;
    notifyListeners();
  }

  String get platformName => _platformName;

  setPlatformName(String platformName){
    _platformName = platformName;
    notifyListeners();
  }

  Color get themeColor => Color(_themeColor);

  MaterialColor get themeMaterialColor => getMaterialColor(themeColor);

  MaterialColor getMaterialColor(Color color) {
    final Map<int, Color> shades = {
      50: Color.fromRGBO(136, 14, 79, .1),
      100: Color.fromRGBO(136, 14, 79, .2),
      200: Color.fromRGBO(136, 14, 79, .3),
      300: Color.fromRGBO(136, 14, 79, .4),
      400: Color.fromRGBO(136, 14, 79, .5),
      500: Color.fromRGBO(136, 14, 79, .6),
      600: Color.fromRGBO(136, 14, 79, .7),
      700: Color.fromRGBO(136, 14, 79, .8),
      800: Color.fromRGBO(136, 14, 79, .9),
      900: Color.fromRGBO(136, 14, 79, 1),
    };
    return MaterialColor(color.value, shades);
  }

  String getPlatformLocaleName(BuildContext context){
    Map<String, String> platformMap = {
      "":S.of(context).followSystem,
      "ios":S.of(context).ios,
      "android":S.of(context).materialDesign,
      "fuchsia":S.of(context).fuchsia
    };
    if (platformMap.containsKey(_platformName)){
      return platformMap[_platformName]!;
    }
    else{
      return S.of(context).followSystem;
    }
  }

  String getBrightnessName(BuildContext context){
    if(brightness == null){
      return S.of(context).followSystem;
    }
    else if(brightness == Brightness.light){
      return S.of(context).brightnessLight;
    }
    else if(brightness == Brightness.dark){
      return S.of(context).brightnessDark;
    }
    else{
      return S.of(context).followSystem;
    }
  }

  setMaterial3(bool material3Property){
    this._useMaterial3 = material3Property;
    notifyListeners();
  }





}