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

extension ColorsExt on Color {

  MaterialColor toMaterialColor() {
    final int red = this.red;
    final int green = this.green;
    final int blue = this.blue;

    final Map<int, Color> shades = {
      50: Color.fromRGBO(red, green, blue, .1),
      100: Color.fromRGBO(red, green, blue, .2),
      200: Color.fromRGBO(red, green, blue, .3),
      300: Color.fromRGBO(red, green, blue, .4),
      400: Color.fromRGBO(red, green, blue, .5),
      500: Color.fromRGBO(red, green, blue, .6),
      600: Color.fromRGBO(red, green, blue, .7),
      700: Color.fromRGBO(red, green, blue, .8),
      800: Color.fromRGBO(red, green, blue, .9),
      900: Color.fromRGBO(red, green, blue, 1),
    };

    return MaterialColor(value, shades);
  }
}



class ThemeNotifierProvider with ChangeNotifier{


  int _themeColor = Colors.blue.value;

  DynamicSchemeVariant _dynamicSchemeVariant = DynamicSchemeVariant.fidelity;

  String getDynamicSchemeVariantName(BuildContext context){
    switch (_dynamicSchemeVariant){
      case DynamicSchemeVariant.tonalSpot: return S.of(context).dynamicSchemeVariantTonalSpotKey;
      case DynamicSchemeVariant.fidelity: return S.of(context).dynamicSchemeVariantFidelityKey;
      case DynamicSchemeVariant.monochrome : return S.of(context).dynamicSchemeVariantMonochromeKey;
      case DynamicSchemeVariant.neutral : return S.of(context).dynamicSchemeVariantNeutralKey;
      case DynamicSchemeVariant.vibrant : return S.of(context).dynamicSchemeVariantVibrantKey;
      case DynamicSchemeVariant.expressive : return S.of(context).dynamicSchemeVariantExpressiveKey;
      case DynamicSchemeVariant.content : return S.of(context).dynamicSchemeVariantContentKey;
      case DynamicSchemeVariant.rainbow : return S.of(context).dynamicSchemeVariantRainbowKey;
      case DynamicSchemeVariant.fruitSalad : return S.of(context).dynamicSchemeVariantFruitSaladKey;
      default:
        return S.of(context).dynamicSchemeVariantFidelityKey;
    }

  }

  String getDynamicSchemeVariantDescription(BuildContext context){
    switch (_dynamicSchemeVariant){
      case DynamicSchemeVariant.tonalSpot: return S.of(context).dynamicSchemeVariantTonalSpotDescription;
      case DynamicSchemeVariant.fidelity: return S.of(context).dynamicSchemeVariantFidelityDescription;
      case DynamicSchemeVariant.monochrome : return S.of(context).dynamicSchemeVariantMonochromeDescription;
      case DynamicSchemeVariant.neutral : return S.of(context).dynamicSchemeVariantNeutralDescription;
      case DynamicSchemeVariant.vibrant : return S.of(context).dynamicSchemeVariantVibrantDescription;
      case DynamicSchemeVariant.expressive : return S.of(context).dynamicSchemeVariantExpressiveDescription;
      case DynamicSchemeVariant.content : return S.of(context).dynamicSchemeVariantContentDescription;
      case DynamicSchemeVariant.rainbow : return S.of(context).dynamicSchemeVariantRainbowDescription;
      case DynamicSchemeVariant.fruitSalad : return S.of(context).dynamicSchemeVariantFruitSaladDescription;
      default:
        return S.of(context).dynamicSchemeVariantFidelityDescription;
    }

  }

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

  setDynamicSchemeVariant(DynamicSchemeVariant dynamicSchemeVariant){
    _dynamicSchemeVariant = dynamicSchemeVariant;
    notifyListeners();
  }

  DynamicSchemeVariant get dynamicSchemeVariant => _dynamicSchemeVariant;

  Color get themeColor => Color(_themeColor);

  MaterialColor get themeMaterialColor => themeColor.toMaterialColor();

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