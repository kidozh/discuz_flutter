import 'dart:ui' show ImageFilter;

import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/ThemeNotifierProvider.dart';
import 'package:discuz_flutter/utility/CustomizeColor.dart';
import 'package:discuz_flutter/utility/NtcColorLocalization.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const _localizedFlexSchemeNamesZh = <String, String>{
  'material': '质感设计标准',
  'materialHc': '质感设计高对比度',
  'blue': '经典蓝',
  'indigo': '靛青',
  'hippieBlue': '嬉皮蓝',
  'aquaBlue': '水蓝',
  'brandBlue': '品牌蓝',
  'deepBlue': '深海蓝',
  'sakura': '樱花',
  'mandyRed': '曼迪红',
  'red': '经典红',
  'redWine': '酒红',
  'purpleBrown': '紫棕',
  'green': '经典绿',
  'money': '金融绿',
  'jungle': '丛林',
  'greyLaw': '律政灰',
  'wasabi': '山葵',
  'gold': '金色',
  'mango': '芒果',
  'amber': '琥珀',
  'vesuviusBurn': '维苏威橙',
  'deepPurple': '深紫',
  'ebonyClay': '乌木灰',
  'barossa': '巴罗萨酒红',
  'shark': '鲨鱼灰',
  'bigStone': '巨石蓝',
  'damask': '大马士革红',
  'bahamaBlue': '巴哈马蓝',
  'mallardGreen': '野鸭绿',
  'espresso': '浓缩咖啡',
  'outerSpace': '太空灰',
  'blueWhale': '蓝鲸',
  'sanJuanBlue': '圣胡安蓝',
  'rosewood': '紫檀红',
  'blumineBlue': '墨蓝',
  'flutterDash': 'Flutter Dash',
  'materialBaseline': 'Material 3 基准',
  'verdunHemlock': '凡尔登绿',
  'dellGenoa': '热那亚绿',
  'redM3': 'Material 3 红',
  'pinkM3': 'Material 3 粉',
  'purpleM3': 'Material 3 紫',
  'indigoM3': 'Material 3 靛青',
  'blueM3': 'Material 3 蓝',
  'cyanM3': 'Material 3 青',
  'tealM3': 'Material 3 蓝绿',
  'greenM3': 'Material 3 绿',
  'limeM3': 'Material 3 青柠',
  'yellowM3': 'Material 3 黄',
  'orangeM3': 'Material 3 橙',
  'deepOrangeM3': 'Material 3 深橙',
  'blackWhite': '黑白',
  'greys': '灰阶',
  'sepia': '复古棕',
  'shadBlue': 'Shadcn 蓝',
  'shadGray': 'Shadcn 灰',
  'shadGreen': 'Shadcn 绿',
  'shadNeutral': 'Shadcn 中性',
  'shadOrange': 'Shadcn 橙',
  'shadRed': 'Shadcn 红',
  'shadRose': 'Shadcn 玫瑰',
  'shadSlate': 'Shadcn 石板灰',
  'shadStone': 'Shadcn 岩石灰',
  'shadViolet': 'Shadcn 紫罗兰',
  'shadYellow': 'Shadcn 黄',
  'shadZinc': 'Shadcn 锌灰',
};

String localizedFlexSchemeName(BuildContext context, FlexScheme scheme) {
  if (Localizations.localeOf(context).languageCode == 'zh') {
    return _localizedFlexSchemeNamesZh[scheme.name] ?? scheme.data.name;
  }
  return scheme.data.name;
}

String localizedCustomColorName(BuildContext context, Color color) {
  final opaqueColor = color.withValues(alpha: 1);
  final ntcName = ColorTools.nameThatColor(opaqueColor);
  if (Localizations.localeOf(context).languageCode != 'zh') return ntcName;

  final localizedName = ntcColorNamesZh[ntcName] ?? ntcName;
  if (_hasRecognizableChineseColorCue(localizedName)) return localizedName;
  return '$localizedName（${_approximateChineseColorFamily(opaqueColor)}）';
}

const _recognizableChineseColorCues = <String>[
  '红',
  '橙',
  '黄',
  '绿',
  '青',
  '蓝',
  '紫',
  '粉',
  '棕',
  '褐',
  '灰',
  '黑',
  '白',
  '靛',
  '绯',
  '绛',
  '朱',
  '赭',
  '苍',
  '碧',
  '翠',
  '黛',
  '墨色',
  '玫瑰',
  '薰衣草',
  '琥珀',
  '翡翠',
  '象牙',
  '奶油',
  '焦糖',
  '巧克力',
  '咖啡',
  '柠檬',
  '橄榄',
  '樱桃',
  '草莓',
  '珊瑚',
  '栗色',
  '煤色',
  '炭色',
];

bool _hasRecognizableChineseColorCue(String name) =>
    _recognizableChineseColorCues.any(name.contains);

String _approximateChineseColorFamily(Color color) {
  final hsv = HSVColor.fromColor(color);
  final saturation = hsv.saturation;
  final value = hsv.value;

  if (saturation < 0.08) {
    if (value < 0.16) return '黑色';
    if (value < 0.38) return '深灰色';
    if (value < 0.72) return '灰色';
    if (value < 0.92) return '浅灰色';
    return '白色';
  }

  final hue = hsv.hue;
  final family = switch (hue) {
    < 15 || >= 345 => '红',
    < 35 => value < 0.55 ? '棕' : '橙红',
    < 55 => value < 0.55 ? '棕' : '橙',
    < 75 => '黄',
    < 105 => '黄绿',
    < 165 => '绿',
    < 195 => '青绿',
    < 225 => '青蓝',
    < 255 => '蓝',
    < 285 => '蓝紫',
    < 320 => '紫',
    _ => '玫红',
  };

  if (value < 0.32) return '深$family色';
  if (saturation < 0.28) return '$family灰色';
  if (value > 0.88 && saturation < 0.55) return '浅$family色';
  return '$family色';
}

String _colorHex(Color color) => color
    .toARGB32()
    .toRadixString(16)
    .padLeft(8, '0')
    .substring(2)
    .toUpperCase();

List<FlexScheme> _schemesInColorWheelOrder(Iterable<FlexScheme> schemes) {
  final sorted = schemes.toList();
  sorted.sort((first, second) {
    final firstColor = HSVColor.fromColor(first.data.light.primary);
    final secondColor = HSVColor.fromColor(second.data.light.primary);
    final firstIsNeutral = firstColor.saturation < 0.12;
    final secondIsNeutral = secondColor.saturation < 0.12;
    if (firstIsNeutral != secondIsNeutral) return firstIsNeutral ? 1 : -1;
    final hueComparison = firstColor.hue.compareTo(secondColor.hue);
    if (hueComparison != 0) return hueComparison;
    return secondColor.value.compareTo(firstColor.value);
  });
  return sorted;
}

class ChooseThemeColorPage extends StatefulWidget {
  const ChooseThemeColorPage({super.key});

  @override
  State<ChooseThemeColorPage> createState() => _ChooseThemeColorState();
}

class _ChooseThemeColorState extends State<ChooseThemeColorPage> {
  int _brightnessIndex(Brightness? brightness) => switch (brightness) {
        Brightness.light => 0,
        null => 1,
        Brightness.dark => 2,
      };

  @override
  Widget build(BuildContext context) {
    final themePreference = context.watch<ThemeNotifierProvider>();
    final schemes = _schemesInColorWheelOrder(
      UserPreferencesUtils.getAvailableThemes(),
    );
    final customColor = themePreference.customThemeColor;
    final customColorName = customColor == null
        ? null
        : localizedCustomColorName(context, customColor);

    return PlatformScaffold(
      iosContentPadding: true,
      appBar: PlatformAppBar(title: Text(S.of(context).chooseThemeTitle)),
      body: PlatformLiquidGlassPageBackdrop(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 32),
          children: [
            PlatformLiquidGlassCard(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
              borderRadius: BorderRadius.circular(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context).interfaceBrightness,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: PlatformSegmentedControl(
                      labels: [
                        S.of(context).brightnessLight,
                        S.of(context).followSystem,
                        S.of(context).brightnessDark,
                      ],
                      selectedIndex:
                          _brightnessIndex(themePreference.brightness),
                      color: Theme.of(context).colorScheme.primaryContainer,
                      textColor: Theme.of(context).colorScheme.onSurfaceVariant,
                      selectedTextColor:
                          Theme.of(context).colorScheme.onPrimaryContainer,
                      onValueChanged: _changeBrightness,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            PlatformLiquidGlassCard(
              borderRadius: BorderRadius.circular(24),
              selected: themePreference.usesCustomThemeColor,
              child: PlatformListTile(
                contentPadding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
                leading: _ColorPreview(
                  color: customColor ?? Theme.of(context).colorScheme.primary,
                ),
                title: Text(S.of(context).customColor),
                subtitle: Text(
                  customColor == null
                      ? S.of(context).selectColorAndShadeTitle
                      : '$customColorName · #${_colorHex(customColor)}',
                ),
                trailing: Icon(PlatformIcons(context).forward),
                onTap: _chooseCustomColor,
              ),
            ),
            const SizedBox(height: 12),
            PlatformLiquidGlassCard(
              borderRadius: BorderRadius.circular(24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    Positioned(
                      right: -38,
                      top: -72,
                      child: _PaletteBloom(
                        color: Theme.of(context).colorScheme.primary,
                        size: 180,
                      ),
                    ),
                    Positioned(
                      left: -54,
                      top: 120,
                      child: _PaletteBloom(
                        color: Theme.of(context).colorScheme.secondary,
                        size: 160,
                      ),
                    ),
                    Positioned(
                      right: -34,
                      bottom: -64,
                      child: _PaletteBloom(
                        color: Theme.of(context).colorScheme.tertiary,
                        size: 170,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              themePreference.usesCustomThemeColor
                                  ? S
                                      .of(context)
                                      .customColorNamed(customColorName!)
                                  : localizedFlexSchemeName(
                                      context,
                                      themePreference.themeColor,
                                    ),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(height: 12),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 88,
                              childAspectRatio: 0.78,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 4,
                            ),
                            itemCount: schemes.length,
                            itemBuilder: (context, index) {
                              final scheme = schemes[index];
                              return FlexSchemeCard(
                                scheme: scheme,
                                selected:
                                    !themePreference.usesCustomThemeColor &&
                                        themePreference.themeColor == scheme,
                                onTap: () => _changeScheme(scheme),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _chooseCustomColor() async {
    final themePreference = context.read<ThemeNotifierProvider>();
    Color draftColor = themePreference.customThemeColor ??
        Theme.of(context).colorScheme.primary;
    final selected = await showPlatformModalSheet<Color>(
      context: context,
      material: const MaterialModalSheetData(isScrollControlled: true),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ColorPicker(
                  color: draftColor,
                  onColorChanged: (color) =>
                      setSheetState(() => draftColor = color),
                  width: 40,
                  height: 40,
                  borderRadius: 20,
                  wheelDiameter: 190,
                  enableTonalPalette: true,
                  heading: Text(
                    S.of(context).selectColorTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subheading: Text(
                    S.of(context).selectColorShadeTitle,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  wheelSubheading: Text(
                    S.of(context).selectColorAndShadeTitle,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  showColorCode: true,
                  // The package's generic name list is English-only. A live,
                  // locale-aware name is rendered below instead.
                  showColorName: false,
                  pickerTypeLabels: {
                    ColorPickerType.primary:
                        S.of(context).primaryColorPickerType,
                    ColorPickerType.accent: S.of(context).accentColorPickerType,
                    ColorPickerType.bw:
                        S.of(context).blackAndWhiteColorPickerType,
                    ColorPickerType.wheel: S.of(context).wheelColorPickerType,
                    ColorPickerType.both: S.of(context).bothColorPickerType,
                  },
                  selectedPickerTypeColor:
                      Theme.of(context).colorScheme.primary,
                  pickersEnabled: const {
                    ColorPickerType.both: false,
                    ColorPickerType.primary: true,
                    ColorPickerType.accent: true,
                    ColorPickerType.bw: true,
                    ColorPickerType.custom: false,
                    ColorPickerType.wheel: true,
                  },
                ),
                const SizedBox(height: 8),
                _CustomColorSummary(color: draftColor),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: PlatformTextButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        child: Text(S.of(context).cancel),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: PlatformElevatedButton(
                        onPressed: () =>
                            Navigator.pop(sheetContext, draftColor),
                        child: Text(S.of(context).ok),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (selected == null || !mounted) return;

    context.read<ThemeNotifierProvider>().setCustomThemeColor(selected);
    await UserPreferencesUtils.putCustomThemeColor(selected);
    if (!mounted) return;
    CustomizeColor.updateAndroidNavigationbar(context);
    VibrationUtils.vibrateSuccessfullyIfPossible();
  }

  Future<void> _changeScheme(FlexScheme scheme) async {
    context.read<ThemeNotifierProvider>().setTheme(scheme);
    await UserPreferencesUtils.putThemeColor(scheme);
    if (!mounted) return;
    CustomizeColor.updateAndroidNavigationbar(context);
    VibrationUtils.vibrateSuccessfullyIfPossible();
  }

  Future<void> _changeBrightness(int index) async {
    final Brightness? brightness = switch (index) {
      0 => Brightness.light,
      2 => Brightness.dark,
      _ => null,
    };
    context.read<ThemeNotifierProvider>().setBrightness(brightness);
    await UserPreferencesUtils.putInterfaceBrightnessPreference(
      switch (brightness) {
        Brightness.light => 'light',
        Brightness.dark => 'dark',
        null => '',
      },
    );
    VibrationUtils.vibrateSuccessfullyIfPossible();
  }
}

class _ColorPreview extends StatelessWidget {
  final Color color;

  const _ColorPreview({required this.color});

  @override
  Widget build(BuildContext context) => Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.72),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.34),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      );
}

class _CustomColorSummary extends StatelessWidget {
  final Color color;

  const _CustomColorSummary({required this.color});

  @override
  Widget build(BuildContext context) {
    final name = localizedCustomColorName(context, color);
    final sourceName = ColorTools.nameThatColor(color.withValues(alpha: 1));
    final showSourceName =
        Localizations.localeOf(context).languageCode == 'zh' &&
            sourceName != name;
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      label: '${S.of(context).customColor}，$name，#${_colorHex(color)}',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withValues(alpha: 0.52),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.52),
            width: 0.7,
          ),
        ),
        child: Row(
          children: [
            _ColorPreview(color: color),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    showSourceName
                        ? '$sourceName · #${_colorHex(color)}'
                        : '#${_colorHex(color)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FlexSchemeCard extends StatelessWidget {
  final FlexScheme scheme;
  final bool selected;
  final VoidCallback onTap;

  const FlexSchemeCard({
    required this.scheme,
    required this.selected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.dark
        ? scheme.data.dark
        : scheme.data.light;
    final displayName = localizedFlexSchemeName(context, scheme);
    final currentColors = Theme.of(context).colorScheme;
    final paletteColors = [
      colors.primary,
      colors.secondary,
      colors.tertiary,
      colors.appBarColor ?? colors.primaryContainer,
      colors.primary,
    ];
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        AnimatedScale(
          scale: selected ? 1.06 : 1,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 60,
            height: 60,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(
                alpha: selected ? 0.74 : 0.22,
              ),
              border: Border.all(
                color: selected
                    ? currentColors.onSurface.withValues(alpha: 0.88)
                    : Colors.white.withValues(alpha: 0.46),
                width: selected ? 2.4 : 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(
                    alpha: selected ? 0.42 : 0.24,
                  ),
                  blurRadius: selected ? 18 : 12,
                  spreadRadius: selected ? 1 : 0,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipOval(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: SweepGradient(colors: paletteColors),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(-0.42, -0.55),
                          radius: 0.82,
                          colors: [
                            Colors.white.withValues(alpha: 0.54),
                            Colors.white.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                    if (selected)
                      Center(
                        child: Container(
                          width: 25,
                          height: 25,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.82),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.72),
                              width: 0.7,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.18),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            CupertinoIcons.check_mark,
                            color: Color(0xD9000000),
                            size: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 7),
        Text(
          displayName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: currentColors.onSurface,
            fontSize: 10.5,
            height: 1.15,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );

    void handleTap() {
      VibrationUtils.vibrateWithClickIfPossible();
      onTap();
    }

    return Semantics(
      button: true,
      selected: selected,
      label: displayName,
      child: Tooltip(
        message: displayName,
        child: PlatformWidget(
          cupertino: (_, __) => CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: handleTap,
            child: content,
          ),
          material: (_, __) => InkResponse(
            radius: 42,
            onTap: handleTap,
            child: content,
          ),
        ),
      ),
    );
  }
}

class _PaletteBloom extends StatelessWidget {
  final Color color;
  final double size;

  const _PaletteBloom({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 34, sigmaY: 34),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: dark ? 0.20 : 0.16),
          ),
        ),
      ),
    );
  }
}
