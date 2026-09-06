import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/app_visual_style.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
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
  "blueGrey": Colors.blueGrey,
  "lightGreen": Colors.lightGreen,
  "lime": Colors.lime,
  "yellow": Colors.yellow,
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

class ThemeNotifierProvider with ChangeNotifier {
  ThemeNotifierProvider({String platformName = ''})
      : _platformName = AppVisualStyle.fromPreference(platformName).preference;

  FlexScheme _themeColor = FlexScheme.blueWhale;
  Color? _customThemeColor;

  DynamicSchemeVariant _dynamicSchemeVariant = DynamicSchemeVariant.fidelity;

  String getDynamicSchemeVariantName(BuildContext context) {
    switch (_dynamicSchemeVariant) {
      case DynamicSchemeVariant.tonalSpot:
        return S.of(context).dynamicSchemeVariantTonalSpotKey;
      case DynamicSchemeVariant.fidelity:
        return S.of(context).dynamicSchemeVariantFidelityKey;
      case DynamicSchemeVariant.monochrome:
        return S.of(context).dynamicSchemeVariantMonochromeKey;
      case DynamicSchemeVariant.neutral:
        return S.of(context).dynamicSchemeVariantNeutralKey;
      case DynamicSchemeVariant.vibrant:
        return S.of(context).dynamicSchemeVariantVibrantKey;
      case DynamicSchemeVariant.expressive:
        return S.of(context).dynamicSchemeVariantExpressiveKey;
      case DynamicSchemeVariant.content:
        return S.of(context).dynamicSchemeVariantContentKey;
      case DynamicSchemeVariant.rainbow:
        return S.of(context).dynamicSchemeVariantRainbowKey;
      case DynamicSchemeVariant.fruitSalad:
        return S.of(context).dynamicSchemeVariantFruitSaladKey;
      default:
        return S.of(context).dynamicSchemeVariantFidelityKey;
    }
  }

  String getDynamicSchemeVariantDescription(BuildContext context) {
    switch (_dynamicSchemeVariant) {
      case DynamicSchemeVariant.tonalSpot:
        return S.of(context).dynamicSchemeVariantTonalSpotDescription;
      case DynamicSchemeVariant.fidelity:
        return S.of(context).dynamicSchemeVariantFidelityDescription;
      case DynamicSchemeVariant.monochrome:
        return S.of(context).dynamicSchemeVariantMonochromeDescription;
      case DynamicSchemeVariant.neutral:
        return S.of(context).dynamicSchemeVariantNeutralDescription;
      case DynamicSchemeVariant.vibrant:
        return S.of(context).dynamicSchemeVariantVibrantDescription;
      case DynamicSchemeVariant.expressive:
        return S.of(context).dynamicSchemeVariantExpressiveDescription;
      case DynamicSchemeVariant.content:
        return S.of(context).dynamicSchemeVariantContentDescription;
      case DynamicSchemeVariant.rainbow:
        return S.of(context).dynamicSchemeVariantRainbowDescription;
      case DynamicSchemeVariant.fruitSalad:
        return S.of(context).dynamicSchemeVariantFruitSaladDescription;
      default:
        return S.of(context).dynamicSchemeVariantFidelityDescription;
    }
  }

  String _platformName;

  //String get themeColorName => ColorTools.nameThatColor(Color(_themeColor));

  FlexScheme get themeColor => _themeColor;
  Color? get customThemeColor => _customThemeColor;
  bool get usesCustomThemeColor => _customThemeColor != null;

  Brightness? _brightnessPreference;

  bool _useMaterial3 = true;

  get useMaterial3 => _useMaterial3;

  set userMaterial3(bool value) {
    this._useMaterial3 = value;
    notifyListeners();
  }

  setBrightness(Brightness? brightness) {
    _brightnessPreference = brightness;
    notifyListeners();
  }

  Brightness? get brightness => _brightnessPreference;

  //Brightness? get brightness => null;

  setTheme(FlexScheme themeColorValue) {
    _themeColor = themeColorValue;
    _customThemeColor = null;
    notifyListeners();
  }

  setCustomThemeColor(Color color) {
    _customThemeColor = color;
    notifyListeners();
  }

  String get platformName => _platformName;

  AppVisualStyle get visualStyle =>
      AppVisualStyle.fromPreference(_platformName);

  setPlatformName(String platformName) {
    _platformName = AppVisualStyle.fromPreference(platformName).preference;
    notifyListeners();
  }

  setDynamicSchemeVariant(DynamicSchemeVariant dynamicSchemeVariant) {
    _dynamicSchemeVariant = dynamicSchemeVariant;
    notifyListeners();
  }

  DynamicSchemeVariant get dynamicSchemeVariant => _dynamicSchemeVariant;

  String getPlatformLocaleName(BuildContext context) {
    return switch (visualStyle) {
      AppVisualStyle.system => S.of(context).followSystem,
      AppVisualStyle.liquidGlass => S.of(context).liquidGlassStyle,
      AppVisualStyle.cupertino => S.of(context).cupertinoStyle,
      AppVisualStyle.material => S.of(context).materialDesign,
    };
  }

  String getBrightnessName(BuildContext context) {
    if (brightness == null) {
      return S.of(context).followSystem;
    } else if (brightness == Brightness.light) {
      return S.of(context).brightnessLight;
    } else if (brightness == Brightness.dark) {
      return S.of(context).brightnessDark;
    } else {
      return S.of(context).followSystem;
    }
  }

  setMaterial3(bool material3Property) {
    this._useMaterial3 = material3Property;
    notifyListeners();
  }
}
