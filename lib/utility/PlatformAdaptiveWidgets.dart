import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart' as liquid;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:platform_adaptive_widgets/platform_adaptive_widgets.dart'
    as adaptive;
import 'package:settings_ui/settings_ui.dart' as settings;

export 'package:platform_adaptive_widgets/platform_adaptive_widgets.dart'
    hide
        PlatformApp,
        PlatformAppBar,
        PlatformListTile,
        PlatformScaffold,
        PlatformSlider,
        PlatformSwitch,
        PlatformTabScaffold,
        PlatformTextField,
        PlatformWidget,
        PlatformWidgetBuilder;

typedef PlatformBuilder<T> = T Function(
  BuildContext context,
  TargetPlatform platform,
);

TargetPlatform platform(BuildContext context) =>
    PlatformProvider.of(context)?.platform ??
    (adaptive.isIOS ? TargetPlatform.iOS : TargetPlatform.android);

bool isCupertino(BuildContext context) =>
    platform(context) == TargetPlatform.iOS;

bool isMaterial(BuildContext context) => !isCupertino(context);

/// Whether the selected UI mode can use native iOS 26 Liquid Glass widgets.
///
/// This deliberately checks both the user-selected style and the physical
/// platform. A forced Material UI on iOS must remain Material, while a forced
/// Cupertino UI on Android cannot host native UIKit views.
bool usesLiquidGlass(BuildContext context) =>
    isCupertino(context) && liquid.PlatformInfo.isIOS26OrHigher();

/// Flutter-rendered frosted surfaces are safe on every physical iOS version.
/// Native iOS 26 controls still use [usesLiquidGlass] so unavailable UIKit
/// APIs are never invoked on older systems or Android's forced Cupertino mode.
bool usesAppleTranslucentSurface(BuildContext context) =>
    isCupertino(context) && liquid.PlatformInfo.isIOS;

/// Whether the current subtree is already hosted by a Flutter-rendered glass
/// surface. Descendants can use lightweight tints instead of stacking another
/// backdrop blur, which avoids muddy contrast and unnecessary GPU work.
bool isInsidePlatformLiquidGlassContainer(BuildContext context) =>
    _PlatformGlassContainerScope.contains(context);

String? _liquidGlassSymbolForWidget(Widget? widget) {
  if (widget is Icon) return _liquidGlassSymbolForIcon(widget.icon);
  if (widget is Badge) return _liquidGlassSymbolForWidget(widget.child);
  return null;
}

Icon? _iconForWidget(Widget? widget) {
  if (widget is Icon) return widget;
  if (widget is Badge) return _iconForWidget(widget.child);
  return null;
}

String? _liquidGlassSymbolForIcon(IconData? icon) {
  if (icon == null) return null;

  if (icon == CupertinoIcons.add || icon == Icons.add) return 'plus';
  if (icon == CupertinoIcons.add_circled || icon == Icons.add_circle) {
    return 'plus.circle';
  }
  if (icon == Icons.add_circle_outline) return 'plus.circle';
  if (icon == CupertinoIcons.back || icon == Icons.arrow_back) {
    return 'chevron.left';
  }
  if (icon == CupertinoIcons.check_mark || icon == Icons.check) {
    return 'checkmark';
  }
  if (icon == CupertinoIcons.check_mark_circled_solid ||
      icon == Icons.check_circle) {
    return 'checkmark.circle.fill';
  }
  if (icon == CupertinoIcons.check_mark_circled ||
      icon == Icons.check_circle_outline) {
    return 'checkmark.circle';
  }
  if (icon == CupertinoIcons.clear ||
      icon == CupertinoIcons.clear_circled ||
      icon == Icons.close ||
      icon == Icons.clear) {
    return 'xmark';
  }
  if (icon == CupertinoIcons.chat_bubble_fill || icon == Icons.message) {
    return 'message.fill';
  }
  if (icon == CupertinoIcons.chat_bubble || icon == Icons.message_outlined) {
    return 'message';
  }
  if (icon == CupertinoIcons.delete_left_fill ||
      icon == Icons.delete ||
      icon == Icons.delete_forever) {
    return 'trash';
  }
  if (icon == CupertinoIcons.download_circle ||
      icon == Icons.save ||
      icon == Icons.save_outlined) {
    return 'square.and.arrow.down';
  }
  if (icon == CupertinoIcons.ellipsis || icon == Icons.more_vert) {
    return 'ellipsis';
  }
  if (icon == Icons.more_horiz) return 'ellipsis';
  if (icon == CupertinoIcons.heart || icon == Icons.favorite_border) {
    return 'heart';
  }
  if (icon == CupertinoIcons.heart_fill || icon == Icons.favorite) {
    return 'heart.fill';
  }
  if (icon == CupertinoIcons.line_horizontal_3 || icon == Icons.menu) {
    return 'line.3.horizontal';
  }
  if (icon == CupertinoIcons.bell_fill ||
      icon == CupertinoIcons.bell_circle_fill ||
      icon == Icons.notifications) {
    return 'bell.fill';
  }
  if (icon == CupertinoIcons.bell_circle ||
      icon == Icons.notifications_outlined) {
    return 'bell';
  }
  if (icon == CupertinoIcons.person_crop_circle ||
      icon == Icons.person ||
      icon == Icons.person_outline) {
    return 'person.crop.circle';
  }
  if (icon == CupertinoIcons.arrow_up_circle || icon == Icons.send) {
    return 'arrow.up.circle';
  }
  if (icon == Icons.emoji_emotions_outlined) return 'face.smiling';
  if (icon == Icons.keyboard_outlined) return 'keyboard';
  if (icon == Icons.format_bold_outlined) return 'bold';
  if (icon == Icons.format_italic_outlined) return 'italic';
  if (icon == Icons.format_quote_outlined) return 'quote.bubble';
  if (icon == Icons.image_outlined || icon == Icons.image) return 'photo';
  if (icon == CupertinoIcons.exclamationmark_circle ||
      icon == Icons.error_outline) {
    return 'exclamationmark.triangle';
  }
  if (icon == CupertinoIcons.share || icon == Icons.share) {
    return 'square.and.arrow.up';
  }
  if (icon == CupertinoIcons.arrow_swap || icon == Icons.account_tree) {
    return 'arrow.left.arrow.right';
  }
  if (icon == CupertinoIcons.up_arrow || icon == Icons.arrow_upward) {
    return 'arrow.up';
  }
  if (icon == CupertinoIcons.down_arrow || icon == Icons.arrow_downward) {
    return 'arrow.down';
  }
  if (icon == CupertinoIcons.today ||
      icon == CupertinoIcons.today_fill ||
      icon == Icons.home ||
      icon == Icons.home_outlined) {
    return icon == CupertinoIcons.today || icon == Icons.home
        ? 'house.fill'
        : 'house';
  }
  if (icon == CupertinoIcons.bubble_left_bubble_right_fill ||
      icon == Icons.forum) {
    return 'bubble.left.and.bubble.right.fill';
  }
  if (icon == CupertinoIcons.bubble_left_bubble_right ||
      icon == Icons.forum_outlined) {
    return 'bubble.left.and.bubble.right';
  }
  if (icon == Icons.dashboard) return 'rectangle.grid.2x2';
  if (icon == CupertinoIcons.square_stack_3d_up_fill ||
      icon == Icons.filter_alt) {
    return 'line.3.horizontal.decrease.circle.fill';
  }
  if (icon == CupertinoIcons.square_stack_3d_up ||
      icon == Icons.filter_alt_outlined) {
    return 'line.3.horizontal.decrease.circle';
  }
  if (icon == CupertinoIcons.settings ||
      icon == CupertinoIcons.settings_solid ||
      icon == Icons.settings ||
      icon == Icons.settings_outlined) {
    return 'gearshape';
  }

  return null;
}

class PlatformSettingsData {
  const PlatformSettingsData();
}

class PlatformProvider extends StatefulWidget {
  final WidgetBuilder builder;
  final TargetPlatform? initialPlatform;
  final PlatformSettingsData? settings;

  const PlatformProvider({
    required this.builder,
    this.initialPlatform,
    this.settings,
    super.key,
  });

  static PlatformProviderState? of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_PlatformProviderScope>()
      ?.state;

  @override
  State<PlatformProvider> createState() => PlatformProviderState();
}

class PlatformProviderState extends State<PlatformProvider> {
  TargetPlatform? platform;

  @override
  void initState() {
    super.initState();
    platform = widget.initialPlatform;
  }

  void changeToAutoDetectPlatform() => setState(() => platform = null);

  void changeToCupertinoPlatform() =>
      setState(() => platform = TargetPlatform.iOS);

  void changeToMaterialPlatform() =>
      setState(() => platform = TargetPlatform.android);

  @override
  Widget build(BuildContext context) => _PlatformProviderScope(
        state: this,
        child: Builder(builder: widget.builder),
      );
}

class _PlatformProviderScope extends InheritedWidget {
  final PlatformProviderState state;

  const _PlatformProviderScope({required this.state, required super.child});

  @override
  bool updateShouldNotify(_PlatformProviderScope oldWidget) =>
      state.platform != oldWidget.state.platform;
}

class PlatformTheme extends StatelessWidget {
  final WidgetBuilder builder;
  final ThemeData? materialLightTheme;
  final ThemeData? materialDarkTheme;
  final CupertinoThemeData? cupertinoLightTheme;
  final CupertinoThemeData? cupertinoDarkTheme;
  final ThemeMode? themeMode;
  final void Function(ThemeMode? mode)? onThemeModeChanged;

  const PlatformTheme({
    required this.builder,
    this.materialLightTheme,
    this.materialDarkTheme,
    this.cupertinoLightTheme,
    this.cupertinoDarkTheme,
    this.themeMode,
    this.onThemeModeChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) => _PlatformThemeScope(
        materialLightTheme: materialLightTheme,
        materialDarkTheme: materialDarkTheme,
        cupertinoLightTheme: cupertinoLightTheme,
        cupertinoDarkTheme: cupertinoDarkTheme,
        themeMode: themeMode,
        child: Builder(builder: builder),
      );
}

class _PlatformThemeScope extends InheritedWidget {
  final ThemeData? materialLightTheme;
  final ThemeData? materialDarkTheme;
  final CupertinoThemeData? cupertinoLightTheme;
  final CupertinoThemeData? cupertinoDarkTheme;
  final ThemeMode? themeMode;

  const _PlatformThemeScope({
    required this.materialLightTheme,
    required this.materialDarkTheme,
    required this.cupertinoLightTheme,
    required this.cupertinoDarkTheme,
    required this.themeMode,
    required super.child,
  });

  static _PlatformThemeScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_PlatformThemeScope>();

  @override
  bool updateShouldNotify(_PlatformThemeScope oldWidget) =>
      materialLightTheme != oldWidget.materialLightTheme ||
      materialDarkTheme != oldWidget.materialDarkTheme ||
      cupertinoLightTheme != oldWidget.cupertinoLightTheme ||
      cupertinoDarkTheme != oldWidget.cupertinoDarkTheme ||
      themeMode != oldWidget.themeMode;
}

class PlatformApp extends StatelessWidget {
  final Key? widgetKey;
  final GlobalKey<NavigatorState>? navigatorKey;
  final Widget? home;
  final Map<String, WidgetBuilder> routes;
  final String? initialRoute;
  final RouteFactory? onGenerateRoute;
  final RouteFactory? onUnknownRoute;
  final List<NavigatorObserver> navigatorObservers;
  final TransitionBuilder? builder;
  final String title;
  final GenerateAppTitle? onGenerateTitle;
  final Color? color;
  final Locale? locale;
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;
  final LocaleListResolutionCallback? localeListResolutionCallback;
  final LocaleResolutionCallback? localeResolutionCallback;
  final Iterable<Locale> supportedLocales;
  final bool showPerformanceOverlay;
  final bool checkerboardRasterCacheImages;
  final bool checkerboardOffscreenLayers;
  final bool showSemanticsDebugger;
  final bool debugShowCheckedModeBanner;

  const PlatformApp({
    this.widgetKey,
    this.navigatorKey,
    this.home,
    this.routes = const {},
    this.initialRoute,
    this.onGenerateRoute,
    this.onUnknownRoute,
    this.navigatorObservers = const [],
    this.builder,
    this.title = '',
    this.onGenerateTitle,
    this.color,
    this.locale,
    this.localizationsDelegates,
    this.localeListResolutionCallback,
    this.localeResolutionCallback,
    this.supportedLocales = const [Locale('en', 'US')],
    this.showPerformanceOverlay = false,
    this.checkerboardRasterCacheImages = false,
    this.checkerboardOffscreenLayers = false,
    this.showSemanticsDebugger = false,
    this.debugShowCheckedModeBanner = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final themes = _PlatformThemeScope.maybeOf(context);
    if (isCupertino(context)) {
      final brightness = MediaQuery.platformBrightnessOf(context);
      final useDark = switch (themes?.themeMode) {
        ThemeMode.dark => true,
        ThemeMode.light => false,
        _ => brightness == Brightness.dark,
      };
      return CupertinoApp(
        key: widgetKey,
        navigatorKey: navigatorKey,
        home: home,
        routes: routes,
        initialRoute: initialRoute,
        onGenerateRoute: onGenerateRoute,
        onUnknownRoute: onUnknownRoute,
        navigatorObservers: navigatorObservers,
        builder: (context, child) {
          final builtChild =
              builder?.call(context, child) ?? child ?? const SizedBox.shrink();
          final materialTheme =
              useDark ? themes?.materialDarkTheme : themes?.materialLightTheme;
          Widget themedChild = builtChild;
          if (materialTheme != null) {
            // CupertinoApp does not insert a Material Theme. Shared widgets
            // use Theme.of for their colors, so bridge the active Material
            // theme here instead of letting them fall back to light colors.
            themedChild = Theme(data: materialTheme, child: themedChild);
          }
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              platformBrightness: useDark ? Brightness.dark : Brightness.light,
            ),
            child: themedChild,
          );
        },
        title: title,
        onGenerateTitle: onGenerateTitle,
        color: color,
        locale: locale,
        localizationsDelegates: localizationsDelegates,
        localeListResolutionCallback: localeListResolutionCallback,
        localeResolutionCallback: localeResolutionCallback,
        supportedLocales: supportedLocales,
        showPerformanceOverlay: showPerformanceOverlay,
        checkerboardRasterCacheImages: checkerboardRasterCacheImages,
        checkerboardOffscreenLayers: checkerboardOffscreenLayers,
        showSemanticsDebugger: showSemanticsDebugger,
        debugShowCheckedModeBanner: debugShowCheckedModeBanner,
        theme:
            useDark ? themes?.cupertinoDarkTheme : themes?.cupertinoLightTheme,
      );
    }
    return MaterialApp(
      key: widgetKey,
      navigatorKey: navigatorKey,
      home: home,
      routes: routes,
      initialRoute: initialRoute,
      onGenerateRoute: onGenerateRoute,
      onUnknownRoute: onUnknownRoute,
      navigatorObservers: navigatorObservers,
      builder: builder,
      title: title,
      onGenerateTitle: onGenerateTitle,
      color: color,
      locale: locale,
      localizationsDelegates: localizationsDelegates,
      localeListResolutionCallback: localeListResolutionCallback,
      localeResolutionCallback: localeResolutionCallback,
      supportedLocales: supportedLocales,
      showPerformanceOverlay: showPerformanceOverlay,
      checkerboardRasterCacheImages: checkerboardRasterCacheImages,
      checkerboardOffscreenLayers: checkerboardOffscreenLayers,
      showSemanticsDebugger: showSemanticsDebugger,
      debugShowCheckedModeBanner: debugShowCheckedModeBanner,
      theme: themes?.materialLightTheme,
      darkTheme: themes?.materialDarkTheme,
      themeMode: themes?.themeMode,
    );
  }
}

abstract class PlatformWidgetBase<I extends Widget, A extends Widget>
    extends StatelessWidget {
  const PlatformWidgetBase({super.key});

  I createCupertinoWidget(BuildContext context);

  A createMaterialWidget(BuildContext context);

  @override
  Widget build(BuildContext context) => isCupertino(context)
      ? createCupertinoWidget(context)
      : createMaterialWidget(context);
}

class PlatformWidget extends StatelessWidget {
  final PlatformBuilder<Widget> material;
  final PlatformBuilder<Widget> cupertino;

  const PlatformWidget({
    required this.material,
    required this.cupertino,
    super.key,
  });

  @override
  Widget build(BuildContext context) => isCupertino(context)
      ? cupertino(context, platform(context))
      : material(context, platform(context));
}

class PlatformWidgetBuilder extends StatelessWidget {
  final Widget? child;
  final Widget Function(BuildContext, Widget?, TargetPlatform) material;
  final Widget Function(BuildContext, Widget?, TargetPlatform) cupertino;

  const PlatformWidgetBuilder({
    this.child,
    required this.material,
    required this.cupertino,
    super.key,
  });

  @override
  Widget build(BuildContext context) => isCupertino(context)
      ? cupertino(context, child, platform(context))
      : material(context, child, platform(context));
}

class PlatformAppBar {
  final Key? widgetKey;
  final Widget? title;
  final String? liquidGlassTitle;
  final String? liquidGlassSubtitle;
  final Color? backgroundColor;
  final Color? liquidGlassTintColor;
  final Widget? leading;
  final List<Widget>? trailingActions;
  final bool? automaticallyImplyLeading;
  final PreferredSizeWidget? bottom;
  final PlatformBuilder<adaptive.MaterialAppBarData>? material;
  final PlatformBuilder<adaptive.CupertinoNavigationBarData>? cupertino;
  final bool liquidGlassUseNativeToolbar;

  const PlatformAppBar({
    this.widgetKey,
    this.title,
    this.liquidGlassTitle,
    this.liquidGlassSubtitle,
    this.backgroundColor,
    this.liquidGlassTintColor,
    this.leading,
    this.trailingActions,
    this.automaticallyImplyLeading,
    this.bottom,
    this.material,
    this.cupertino,
    this.liquidGlassUseNativeToolbar = true,
  });

  liquid.AdaptiveAppBar? createLiquidGlassAppBar(
    BuildContext context, {
    bool suppressAutomaticLeading = false,
  }) {
    if (bottom != null) return null;

    final actions = _createLiquidGlassActions(context);
    if (actions == null) return null;

    final canPop = Navigator.maybeOf(context)?.canPop() ?? false;
    final effectiveLeading = leading ??
        (!suppressAutomaticLeading &&
                automaticallyImplyLeading != false &&
                canPop
            ? const PlatformBackButton()
            : (suppressAutomaticLeading || automaticallyImplyLeading == false
                ? const SizedBox.shrink()
                : null));

    return liquid.AdaptiveAppBar(
      title: liquidGlassTitle,
      subtitle: liquidGlassSubtitle,
      titleWidget: liquidGlassTitle == null ? title : null,
      leading: effectiveLeading,
      actions: actions,
      tintColor: liquidGlassTintColor ??
          Theme.of(context).iconTheme.color ??
          CupertinoColors.label.resolveFrom(context),
      useNativeToolbar: liquidGlassUseNativeToolbar,
    );
  }

  List<liquid.AdaptiveAppBarAction>? _createLiquidGlassActions(
      BuildContext context) {
    final widgets = trailingActions;
    if (widgets == null || widgets.isEmpty) return const [];

    final actions = <liquid.AdaptiveAppBarAction>[];
    for (final widget in widgets) {
      final action = _liquidGlassActionForWidget(context, widget);
      if (action == null) return null;
      actions.add(action);
    }
    return actions;
  }

  liquid.AdaptiveAppBarAction? _liquidGlassActionForWidget(
      BuildContext context, Widget widget) {
    if (widget is PlatformIconButton && widget.onPressed != null) {
      final iconWidget = widget.cupertinoIcon ?? widget.icon;
      final symbol =
          widget.liquidGlassSymbol ?? _liquidGlassSymbolForWidget(iconWidget);
      if (symbol == null) return null;
      return liquid.AdaptiveAppBarAction(
        iosSymbol: symbol,
        iconWidget: iconWidget,
        tintColor: _iconForWidget(iconWidget)?.color,
        onPressed: widget.onPressed!,
        spacerAfter: widget.liquidGlassFlexibleSpaceAfter
            ? liquid.ToolbarSpacerType.flexible
            : liquid.ToolbarSpacerType.none,
      );
    }

    if (widget is IconButton && widget.onPressed != null) {
      final symbol = _liquidGlassSymbolForWidget(widget.icon);
      if (symbol == null) return null;
      return liquid.AdaptiveAppBarAction(
        iosSymbol: symbol,
        iconWidget: widget.icon,
        tintColor: _iconForWidget(widget.icon)?.color,
        onPressed: widget.onPressed!,
      );
    }

    if (widget is PlatformTextButton &&
        widget.onPressed != null &&
        widget.child is Text) {
      final label = (widget.child! as Text).data;
      if (label == null) return null;
      return liquid.AdaptiveAppBarAction(
        title: label,
        onPressed: widget.onPressed!,
      );
    }

    if (widget is PlatformPopupMenu) {
      return liquid.AdaptiveAppBarAction(
        iosSymbol: widget.liquidGlassSymbol,
        iconWidget: widget.icon,
        tintColor: _iconForWidget(widget.icon)?.color,
        onPressed: () => widget.show(context),
      );
    }

    return null;
  }

  PreferredSizeWidget createMaterialWidget(BuildContext context) {
    final target = platform(context);
    final materialData = material?.call(context, target);
    return AppBar(
      key: widgetKey,
      title: title,
      backgroundColor: backgroundColor,
      leading: leading,
      bottom: bottom,
      automaticallyImplyLeading: automaticallyImplyLeading ?? true,
      actions: materialData?.actions ?? trailingActions,
      centerTitle: materialData?.centerTitle,
      elevation: materialData?.elevation,
      flexibleSpace: materialData?.flexibleSpace,
      foregroundColor: materialData?.foregroundColor,
      iconTheme: materialData?.iconTheme,
      scrolledUnderElevation: materialData?.scrolledUnderElevation,
      surfaceTintColor: materialData?.surfaceTintColor,
      titleTextStyle: materialData?.titleTextStyle,
      toolbarHeight: materialData?.toolbarHeight,
    );
  }

  ObstructingPreferredSizeWidget createCupertinoWidget(BuildContext context) {
    final data = cupertino?.call(context, platform(context));
    final canPop = Navigator.maybeOf(context)?.canPop() ?? false;
    final useGlassBackButton = usesLiquidGlass(context) &&
        leading == null &&
        automaticallyImplyLeading != false &&
        canPop;
    final actions = trailingActions;
    final trailing = actions == null || actions.isEmpty
        ? null
        : actions.length == 1
            ? actions.first
            : usesLiquidGlass(context)
                ? PlatformLiquidGlassToolbarGroup(children: actions)
                : Row(mainAxisSize: MainAxisSize.min, children: actions);
    return CupertinoNavigationBar(
      key: widgetKey,
      middle: title,
      backgroundColor: backgroundColor,
      leading: useGlassBackButton ? const PlatformBackButton() : leading,
      bottom: bottom,
      automaticallyImplyLeading:
          useGlassBackButton ? false : automaticallyImplyLeading ?? true,
      previousPageTitle: data?.previousPageTitle,
      trailing: data?.trailing ?? trailing,
      transitionBetweenRoutes: data?.transitionBetweenRoutes ?? true,
    );
  }
}

class PlatformScaffold extends StatelessWidget {
  final Key? widgetKey;
  final Widget? body;
  final Color? backgroundColor;
  final PlatformAppBar? appBar;
  final PlatformBottomNavigationBar? bottomNavigationBar;
  final bool iosContentPadding;
  final bool iosContentBottomPadding;

  const PlatformScaffold({
    this.widgetKey,
    this.body,
    this.backgroundColor,
    this.appBar,
    this.bottomNavigationBar,
    this.iosContentPadding = false,
    this.iosContentBottomPadding = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = body ?? const SizedBox.shrink();
    if (isCupertino(context) &&
        (iosContentPadding || iosContentBottomPadding)) {
      content = SafeArea(
        top: iosContentPadding,
        bottom: iosContentBottomPadding,
        child: content,
      );
    }
    if (usesLiquidGlass(context)) {
      var liquidAppBar = appBar?.createLiquidGlassAppBar(
        context,
        suppressAutomaticLeading: bottomNavigationBar != null,
      );
      if (liquidAppBar == null &&
          appBar != null &&
          bottomNavigationBar != null) {
        liquidAppBar = liquid.AdaptiveAppBar(
          useNativeToolbar: false,
          cupertinoNavigationBar: appBar!.createCupertinoWidget(context),
        );
      }
      if (appBar == null || liquidAppBar != null) {
        if (backgroundColor != null) {
          content = ColoredBox(color: backgroundColor!, child: content);
        }
        // adaptive_platform_ui otherwise creates one copy of [body] for each
        // native tab destination. This body already owns its IndexedStack, so
        // mark it as a navigation shell and keep a single stateful instance.
        if (bottomNavigationBar != null) {
          content = _PlatformStatefulNavigationShell(child: content);
        }
        final scaffold = liquid.AdaptiveScaffold(
          key: widgetKey,
          appBar: liquidAppBar,
          bottomNavigationBar:
              bottomNavigationBar?.createLiquidGlassBottomNavigationBar(),
          minimizeBehavior:
              bottomNavigationBar?.liquidGlassMinimizeOnScroll == false
                  ? liquid.TabBarMinimizeBehavior.never
                  : liquid.TabBarMinimizeBehavior.automatic,
          body: content,
          useHeroBackButton: bottomNavigationBar == null &&
              appBar?.automaticallyImplyLeading != false,
        );
        final tabTint = bottomNavigationBar?.liquidGlassSelectedItemColor ??
            bottomNavigationBar?.selectedItemColor;
        return tabTint == null
            ? scaffold
            : CupertinoTheme(
                data: CupertinoTheme.of(context).copyWith(
                  primaryColor: tabTint,
                ),
                child: scaffold,
              );
      }
    }
    if (isCupertino(context)) {
      return CupertinoPageScaffold(
        key: widgetKey,
        navigationBar: appBar?.createCupertinoWidget(context),
        backgroundColor: backgroundColor,
        child: content,
      );
    }
    return Scaffold(
      key: widgetKey,
      appBar: appBar?.createMaterialWidget(context),
      backgroundColor: backgroundColor,
      body: content,
    );
  }
}

/// Name intentionally contains `StatefulNavigationShell`: it is the marker
/// adaptive_platform_ui uses to recognize a body that manages tab state itself.
class _PlatformStatefulNavigationShell extends StatelessWidget {
  final Widget child;

  const _PlatformStatefulNavigationShell({required this.child});

  @override
  Widget build(BuildContext context) => child;
}

class PlatformBottomNavigationBar {
  final List<BottomNavigationBarItem> items;
  final List<String>? liquidGlassSymbols;
  final List<String>? liquidGlassSelectedSymbols;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final Color? liquidGlassSelectedItemColor;
  final Color? liquidGlassUnselectedItemColor;
  final bool liquidGlassMinimizeOnScroll;

  const PlatformBottomNavigationBar({
    required this.items,
    this.liquidGlassSymbols,
    this.liquidGlassSelectedSymbols,
    required this.selectedIndex,
    required this.onTap,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.liquidGlassSelectedItemColor,
    this.liquidGlassUnselectedItemColor,
    this.liquidGlassMinimizeOnScroll = true,
  })  : assert(liquidGlassSymbols == null ||
            liquidGlassSymbols.length == items.length),
        assert(liquidGlassSelectedSymbols == null ||
            liquidGlassSelectedSymbols.length == items.length);

  liquid.AdaptiveBottomNavigationBar createLiquidGlassBottomNavigationBar() {
    return liquid.AdaptiveBottomNavigationBar(
      selectedIndex: selectedIndex,
      onTap: onTap,
      useNativeBottomBar: true,
      selectedItemColor: liquidGlassSelectedItemColor,
      unselectedItemColor: liquidGlassUnselectedItemColor,
      items: [
        for (var index = 0; index < items.length; index++)
          liquid.AdaptiveNavigationDestination(
            icon: liquidGlassSymbols?[index] ??
                _liquidGlassSymbolForWidget(items[index].icon) ??
                items[index].icon,
            selectedIcon: liquidGlassSelectedSymbols?[index] ??
                _liquidGlassSymbolForWidget(items[index].activeIcon) ??
                items[index].activeIcon,
            label: items[index].label ?? '',
          ),
      ],
    );
  }
}

class PlatformElevatedButton extends StatelessWidget {
  final Key? widgetKey;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry? alignment;
  final Color? color;

  const PlatformElevatedButton({
    this.widgetKey,
    this.onPressed,
    this.onLongPress,
    this.child,
    this.padding,
    this.alignment,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Widget button;
    if (usesLiquidGlass(context) &&
        onLongPress == null &&
        (alignment == null || alignment == Alignment.center)) {
      final effectivePadding =
          padding ?? const EdgeInsets.symmetric(horizontal: 18, vertical: 10);
      final foregroundColor = Theme.of(context).colorScheme.onPrimary;
      button = liquid.AdaptiveButton.child(
        key: widgetKey,
        onPressed: onPressed,
        color: color,
        padding: EdgeInsets.zero,
        enabled: onPressed != null,
        style: liquid.AdaptiveButtonStyle.prominentGlass,
        child: Padding(
          padding: effectivePadding,
          child: DefaultTextStyle.merge(
            style: TextStyle(color: foregroundColor),
            child: IconTheme.merge(
              data: IconThemeData(color: foregroundColor),
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        ),
      );
    } else {
      button = isCupertino(context)
          ? CupertinoButton.filled(
              key: widgetKey,
              onPressed: onPressed,
              onLongPress: onLongPress,
              color: color,
              padding: padding,
              alignment: alignment ?? Alignment.center,
              child: child ?? const SizedBox.shrink(),
            )
          : ElevatedButton(
              key: widgetKey,
              onPressed: onPressed,
              onLongPress: onLongPress,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                padding: padding,
                alignment: alignment,
                minimumSize: const Size(44, 44),
              ),
              child: child ?? const SizedBox.shrink(),
            );
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      child: button,
    );
  }
}

class PlatformTextButton extends StatelessWidget {
  final Key? widgetKey;
  final VoidCallback? onPressed;
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry? alignment;
  final Color? color;

  const PlatformTextButton({
    this.widgetKey,
    this.onPressed,
    this.child,
    this.padding,
    this.alignment,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Widget button;
    if (usesLiquidGlass(context) &&
        (alignment == null || alignment == Alignment.center)) {
      final effectivePadding =
          padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
      final colors = Theme.of(context).colorScheme;
      final foregroundColor = color == null ? colors.primary : colors.onPrimary;
      button = liquid.AdaptiveButton.child(
        key: widgetKey,
        onPressed: onPressed,
        color: color,
        padding: EdgeInsets.zero,
        enabled: onPressed != null,
        style: color == null
            ? liquid.AdaptiveButtonStyle.glass
            : liquid.AdaptiveButtonStyle.prominentGlass,
        child: Padding(
          padding: effectivePadding,
          child: DefaultTextStyle.merge(
            style: TextStyle(color: foregroundColor),
            child: IconTheme.merge(
              data: IconThemeData(color: foregroundColor),
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        ),
      );
    } else {
      button = isCupertino(context)
          ? CupertinoButton(
              key: widgetKey,
              onPressed: onPressed,
              color: color,
              padding: padding,
              alignment: alignment ?? Alignment.center,
              child: child ?? const SizedBox.shrink(),
            )
          : TextButton(
              key: widgetKey,
              onPressed: onPressed,
              style: TextButton.styleFrom(
                backgroundColor: color,
                padding: padding,
                alignment: alignment,
                minimumSize: const Size(44, 44),
              ),
              child: child ?? const SizedBox.shrink(),
            );
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      child: button,
    );
  }
}

/// Adaptive alternative to Material [ChoiceChip]. Selected filters use a
/// prominent glass treatment on iOS 26 while every option keeps a 44pt target.
class PlatformChoiceChip extends StatelessWidget {
  final Widget label;
  final Widget? avatar;
  final bool selected;
  final ValueChanged<bool>? onSelected;

  const PlatformChoiceChip({
    required this.label,
    required this.selected,
    this.avatar,
    this.onSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (usesLiquidGlass(context)) {
      final colors = Theme.of(context).colorScheme;
      final foregroundColor = selected ? colors.onPrimary : colors.onSurface;
      // Native glass buttons advertise the full incoming width. IntrinsicWidth
      // keeps each option compact so a Wrap can arrange them like chips.
      return IntrinsicWidth(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          child: liquid.AdaptiveButton.child(
            onPressed: onSelected == null ? null : () => onSelected!(!selected),
            padding: EdgeInsets.zero,
            enabled: onSelected != null,
            color: selected ? Theme.of(context).colorScheme.primary : null,
            style: selected
                ? liquid.AdaptiveButtonStyle.prominentGlass
                : liquid.AdaptiveButtonStyle.glass,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: DefaultTextStyle.merge(
                style: TextStyle(color: foregroundColor),
                child: IconTheme.merge(
                  data: IconThemeData(color: foregroundColor, size: 18),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (avatar != null) ...[
                        avatar!,
                        const SizedBox(width: 6),
                      ],
                      label,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    if (isCupertino(context)) {
      return ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          color: selected
              ? CupertinoTheme.of(context).primaryColor
              : CupertinoColors.tertiarySystemFill.resolveFrom(context),
          onPressed: onSelected == null ? null : () => onSelected!(!selected),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (avatar != null) ...[
                IconTheme.merge(
                  data: const IconThemeData(size: 18),
                  child: avatar!,
                ),
                const SizedBox(width: 6),
              ],
              label,
            ],
          ),
        ),
      );
    }
    return ChoiceChip(
      label: label,
      avatar: avatar,
      selected: selected,
      onSelected: onSelected,
    );
  }
}

class CupertinoIconButtonData {
  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? padding;

  const CupertinoIconButtonData({this.alignment, this.padding});
}

class _PlatformLiquidGlassToolbarGroupScope extends InheritedWidget {
  const _PlatformLiquidGlassToolbarGroupScope({required super.child});

  static bool contains(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<
          _PlatformLiquidGlassToolbarGroupScope>() !=
      null;

  @override
  bool updateShouldNotify(_PlatformLiquidGlassToolbarGroupScope oldWidget) =>
      false;
}

/// Combines adjacent toolbar actions into one Apple-style Liquid Glass capsule.
class PlatformLiquidGlassToolbarGroup extends StatelessWidget {
  final List<Widget> children;

  const PlatformLiquidGlassToolbarGroup({
    required this.children,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (!usesAppleTranslucentSurface(context) || children.length < 2) {
      return Row(mainAxisSize: MainAxisSize.min, children: children);
    }
    final light = Theme.of(context).brightness == Brightness.light;
    const radius = BorderRadius.all(Radius.circular(22));
    return Container(
      height: 44,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: light ? 0.12 : 0.32),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: light ? 0.76 : 0.20),
                  Colors.white.withValues(alpha: light ? 0.42 : 0.09),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: light ? 0.72 : 0.24),
                width: 0.7,
              ),
            ),
            child: _PlatformLiquidGlassToolbarGroupScope(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var index = 0; index < children.length; index++) ...[
                    if (index > 0)
                      Container(
                        width: 0.5,
                        height: 18,
                        color: CupertinoColors.separator
                            .resolveFrom(context)
                            .withValues(alpha: 0.34),
                      ),
                    children[index],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PlatformIconButton extends StatelessWidget {
  final Key? widgetKey;
  final Widget? icon;
  final Widget? materialIcon;
  final Widget? cupertinoIcon;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final Color? color;
  final Color? disabledColor;
  final EdgeInsetsGeometry? padding;
  final String? liquidGlassSymbol;
  final double liquidGlassButtonSize;
  final double liquidGlassIconSize;
  final bool liquidGlassFlexibleSpaceAfter;
  final PlatformBuilder<CupertinoIconButtonData>? cupertino;

  const PlatformIconButton({
    this.widgetKey,
    this.icon,
    this.materialIcon,
    this.cupertinoIcon,
    this.onPressed,
    this.onLongPress,
    this.color,
    this.disabledColor,
    this.padding,
    this.liquidGlassSymbol,
    this.liquidGlassButtonSize = 44,
    this.liquidGlassIconSize = 18,
    this.liquidGlassFlexibleSpaceAfter = false,
    this.cupertino,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (isCupertino(context)) {
      final data = cupertino?.call(context, platform(context));
      if (usesLiquidGlass(context) && onLongPress == null) {
        final grouped = _PlatformLiquidGlassToolbarGroupScope.contains(context);
        final iconWidget = cupertinoIcon ?? icon;
        final symbol =
            liquidGlassSymbol ?? _liquidGlassSymbolForWidget(iconWidget);
        final iconData = _iconForWidget(iconWidget);
        Widget button;
        if (symbol != null && iconWidget is! Badge) {
          button = liquid.AdaptiveButton.sfSymbol(
            key: widgetKey,
            onPressed: onPressed,
            sfSymbol: liquid.SFSymbol(
              symbol,
              size: liquidGlassIconSize,
              color:
                  iconData?.color ?? CupertinoColors.label.resolveFrom(context),
            ),
            color: color,
            padding: data?.padding ?? padding,
            minSize: Size.square(liquidGlassButtonSize),
            enabled: onPressed != null,
            style: grouped
                ? liquid.AdaptiveButtonStyle.plain
                : liquid.AdaptiveButtonStyle.glass,
            useSmoothRectangleBorder: false,
          );
        } else {
          button = liquid.AdaptiveButton.child(
            key: widgetKey,
            onPressed: onPressed,
            color: color,
            padding: data?.padding ?? padding,
            minSize: Size.square(liquidGlassButtonSize),
            enabled: onPressed != null,
            style: grouped
                ? liquid.AdaptiveButtonStyle.plain
                : liquid.AdaptiveButtonStyle.glass,
            useSmoothRectangleBorder: false,
            child: IconTheme.merge(
              data: IconThemeData(size: liquidGlassIconSize),
              child: iconWidget ?? const SizedBox.shrink(),
            ),
          );
        }
        final semanticLabel = iconData?.semanticLabel;
        if (semanticLabel != null) {
          button = Semantics(
            label: semanticLabel,
            button: true,
            excludeSemantics: true,
            child: button,
          );
        }
        final alignment = data?.alignment;
        if (alignment != null && alignment != Alignment.center) {
          return Align(
            alignment: alignment,
            widthFactor: 1,
            heightFactor: 1,
            child: button,
          );
        }
        return button;
      }
      Widget button = CupertinoButton(
        key: widgetKey,
        padding: data?.padding ?? padding,
        alignment: data?.alignment ?? Alignment.center,
        color: color,
        disabledColor: disabledColor ?? CupertinoColors.quaternarySystemFill,
        onPressed: onPressed,
        onLongPress: onLongPress,
        child: cupertinoIcon ?? icon ?? const SizedBox.shrink(),
      );
      final semanticLabel =
          _iconForWidget(cupertinoIcon ?? icon)?.semanticLabel;
      if (semanticLabel != null) {
        button = Semantics(
          label: semanticLabel,
          button: true,
          excludeSemantics: true,
          child: button,
        );
      }
      return button;
    }
    return IconButton(
      key: widgetKey,
      padding: padding ?? const EdgeInsets.all(8),
      color: color,
      disabledColor: disabledColor,
      onPressed: onPressed,
      onLongPress: onLongPress,
      tooltip: _iconForWidget(materialIcon ?? icon)?.semanticLabel,
      icon: materialIcon ?? icon ?? const SizedBox.shrink(),
    );
  }
}

class PlatformBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const PlatformBackButton({this.onPressed, super.key});

  @override
  Widget build(BuildContext context) => PlatformIconButton(
        liquidGlassSymbol: 'chevron.left',
        liquidGlassButtonSize: 44,
        liquidGlassIconSize: 18,
        onPressed: onPressed ?? () => Navigator.maybePop(context),
        materialIcon: const Icon(Icons.arrow_back),
        cupertinoIcon: Icon(
          CupertinoIcons.back,
          semanticLabel: CupertinoLocalizations.of(context).backButtonLabel,
        ),
      );
}

class PlatformCircularProgressIndicator extends StatelessWidget {
  final Key? widgetKey;
  final PlatformBuilder<adaptive.MaterialProgressIndicatorData>? material;
  final PlatformBuilder<adaptive.CupertinoProgressIndicatorData>? cupertino;

  const PlatformCircularProgressIndicator({
    this.widgetKey,
    this.material,
    this.cupertino,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final target = platform(context);
    if (isCupertino(context)) {
      final data = cupertino?.call(context, target);
      return CupertinoActivityIndicator(
        key: widgetKey,
        color: data?.color,
        animating: data?.animating ?? true,
        radius: data?.radius ?? 10,
      );
    }
    final data = material?.call(context, target);
    return CircularProgressIndicator(
      key: widgetKey,
      color: data?.color,
      value: data?.value,
      backgroundColor: data?.backgroundColor,
      strokeWidth: data?.strokeWidth ?? 4,
      valueColor: data?.valueColor,
      semanticsLabel: data?.semanticsLabel,
      semanticsValue: data?.semanticsValue,
    );
  }
}

class PlatformTextField extends StatelessWidget {
  final Key? widgetKey;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final TextStyle? style;
  final TextAlign textAlign;
  final bool autofocus;
  final bool obscureText;
  final bool autocorrect;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onEditingComplete;
  final GestureTapCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final bool readOnly;
  final bool? showCursor;
  final bool expands;
  final String? hintText;

  const PlatformTextField({
    this.widgetKey,
    this.controller,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.textAlign = TextAlign.start,
    this.autofocus = false,
    this.obscureText = false,
    this.autocorrect = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.onTap,
    this.inputFormatters,
    this.enabled = true,
    this.readOnly = false,
    this.showCursor,
    this.expands = false,
    this.hintText,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (isCupertino(context)) {
      final textField = CupertinoTextField(
        key: widgetKey,
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        textCapitalization: textCapitalization,
        style: style,
        textAlign: textAlign,
        autofocus: autofocus,
        obscureText: obscureText,
        autocorrect: autocorrect,
        maxLines: maxLines,
        minLines: minLines,
        maxLength: maxLength,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        onEditingComplete: onEditingComplete,
        onTap: onTap,
        inputFormatters: inputFormatters,
        enabled: enabled,
        readOnly: readOnly,
        showCursor: showCursor,
        expands: expands,
        placeholder: hintText,
        decoration: usesAppleTranslucentSurface(context)
            ? null
            : BoxDecoration(
                color: const CupertinoDynamicColor.withBrightness(
                  color: CupertinoColors.white,
                  darkColor: CupertinoColors.black,
                ),
                border: Border.all(
                  color: const CupertinoDynamicColor.withBrightness(
                    color: Color(0x33000000),
                    darkColor: Color(0x33FFFFFF),
                  ),
                  width: 0,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(5)),
              ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      );
      if (usesLiquidGlass(context)) {
        return PlatformLiquidGlassSurface(
          borderRadius: BorderRadius.circular(18),
          child: textField,
        );
      }
      return usesAppleTranslucentSurface(context)
          ? PlatformLiquidGlassCard(
              borderRadius: BorderRadius.circular(18),
              child: textField,
            )
          : textField;
    }
    return TextField(
      key: widgetKey,
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      style: style,
      textAlign: textAlign,
      autofocus: autofocus,
      obscureText: obscureText,
      autocorrect: autocorrect,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onEditingComplete: onEditingComplete,
      onTap: onTap,
      inputFormatters: inputFormatters,
      enabled: enabled,
      readOnly: readOnly,
      showCursor: showCursor,
      expands: expands,
      decoration: InputDecoration(hintText: hintText),
    );
  }
}

/// A native frosted surface on iOS 26, with no visual change on other modes.
class PlatformLiquidGlassSurface extends StatelessWidget {
  final Widget child;
  final BorderRadius? borderRadius;

  const PlatformLiquidGlassSurface({
    required this.child,
    this.borderRadius,
    super.key,
  });

  @override
  Widget build(BuildContext context) => usesLiquidGlass(context)
      ? liquid.AdaptiveBlurView(
          borderRadius: borderRadius,
          blurStyle: liquid.BlurStyle.systemThinMaterial,
          child: child,
        )
      : child;
}

/// Gives translucent surfaces real content to refract while keeping the
/// page itself quiet enough for long reading sessions.
class PlatformLiquidGlassPageBackdrop extends StatelessWidget {
  final Widget child;

  const PlatformLiquidGlassPageBackdrop({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    if (!usesAppleTranslucentSurface(context)) return child;

    final colors = Theme.of(context).colorScheme;
    final background = CupertinoColors.systemGroupedBackground.resolveFrom(
      context,
    );
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.alphaBlend(
                  colors.primary.withValues(alpha: 0.13),
                  background,
                ),
                background,
                Color.alphaBlend(
                  colors.secondary.withValues(alpha: 0.11),
                  background,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: -92,
          right: -72,
          child: IgnorePointer(
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    colors.primary.withValues(alpha: 0.26),
                    colors.primary.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: -96,
          bottom: 72,
          child: IgnorePointer(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    colors.secondary.withValues(alpha: 0.22),
                    colors.secondary.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// A lightweight scrolling card that visually matches Liquid Glass without
/// embedding a native UIKit view for every list item.
class PlatformLiquidGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final BorderRadius borderRadius;
  final bool selected;
  final Color? tintColor;

  const PlatformLiquidGlassCard({
    required this.child,
    this.margin,
    this.padding,
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
    this.selected = false,
    this.tintColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final primary = Theme.of(context).colorScheme.primary;
    final light = brightness == Brightness.light;
    final tint = tintColor ?? (selected ? primary : null);
    final baseColor = tint != null
        ? tint.withValues(alpha: light ? 0.24 : 0.30)
        : Colors.white.withValues(alpha: light ? 0.44 : 0.10);
    final highlight = tint != null
        ? Color.alphaBlend(
            Colors.white.withValues(alpha: light ? 0.34 : 0.12),
            tint.withValues(alpha: light ? 0.34 : 0.40),
          )
        : Colors.white.withValues(alpha: light ? 0.70 : 0.18);
    final borderColor = selected
        ? primary.withValues(alpha: light ? 0.46 : 0.58)
        : light
            ? Color.alphaBlend(
                primary.withValues(alpha: 0.10),
                Colors.black.withValues(alpha: 0.08),
              )
            : Colors.white.withValues(alpha: 0.20);

    Widget content = _PlatformGlassContainerScope(
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: child,
      ),
    );
    if (!usesAppleTranslucentSurface(context)) {
      return Container(
        margin: margin,
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primaryContainer
              : CupertinoColors.secondarySystemGroupedBackground
                  .resolveFrom(context),
          borderRadius: borderRadius,
        ),
        child: content,
      );
    }

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: light ? 0.13 : 0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [highlight, baseColor],
              ),
              borderRadius: borderRadius,
              border: Border.all(color: borderColor, width: 0.8),
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}

class _PlatformGlassContainerScope extends InheritedWidget {
  const _PlatformGlassContainerScope({required super.child});

  static bool contains(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<_PlatformGlassContainerScope>() !=
      null;

  @override
  bool updateShouldNotify(_PlatformGlassContainerScope oldWidget) => false;
}

/// Keeps legacy `settings_ui` pages visually consistent with the adaptive
/// navigation layer while they are migrated to [PlatformListTile]. On iOS 26
/// the list background stays transparent and grouped sections use a restrained
/// translucent material, preserving contrast without turning every row into a
/// separate glass surface.
class PlatformAdaptiveSettingsList extends StatelessWidget {
  final List<settings.AbstractSettingsSection> sections;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? contentPadding;

  const PlatformAdaptiveSettingsList({
    required this.sections,
    this.shrinkWrap = false,
    this.physics,
    this.contentPadding,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (!usesAppleTranslucentSurface(context)) {
      return settings.SettingsList(
        sections: sections,
        shrinkWrap: shrinkWrap,
        physics: physics,
        contentPadding: contentPadding,
        applicationType: settings.ApplicationType.both,
        platform: isCupertino(context)
            ? settings.DevicePlatform.iOS
            : settings.DevicePlatform.android,
      );
    }

    return ListView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: contentPadding ??
          const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      itemCount: sections.length,
      itemBuilder: (context, index) =>
          _PlatformAdaptiveSettingsSection(section: sections[index]),
    );
  }
}

class _PlatformAdaptiveSettingsSection extends StatelessWidget {
  final settings.AbstractSettingsSection section;

  const _PlatformAdaptiveSettingsSection({required this.section});

  @override
  Widget build(BuildContext context) {
    if (section is! settings.SettingsSection) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: section,
      );
    }

    final settingsSection = section as settings.SettingsSection;
    return Padding(
      padding: settingsSection.margin ?? const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (settingsSection.title != null)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(12, 6, 12, 6),
              child: DefaultTextStyle.merge(
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                child: settingsSection.title!,
              ),
            ),
          PlatformLiquidGlassCard(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            borderRadius: BorderRadius.circular(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var index = 0;
                    index < settingsSection.tiles.length;
                    index++) ...[
                  _PlatformAdaptiveSettingsTile(
                    tile: settingsSection.tiles[index],
                  ),
                  if (index < settingsSection.tiles.length - 1 &&
                      !usesLiquidGlass(context))
                    Divider(
                      height: 1,
                      indent: _settingsTileHasLeading(
                              settingsSection.tiles[index + 1])
                          ? 54
                          : 14,
                      endIndent: 12,
                      color: CupertinoColors.separator
                          .resolveFrom(context)
                          .withValues(alpha: 0.34),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

bool _settingsTileHasLeading(settings.AbstractSettingsTile tile) =>
    tile is settings.SettingsTile && tile.leading != null;

class _PlatformAdaptiveSettingsTile extends StatelessWidget {
  final settings.AbstractSettingsTile tile;

  const _PlatformAdaptiveSettingsTile({required this.tile});

  @override
  Widget build(BuildContext context) {
    if (tile is settings.CustomSettingsTile) {
      return (tile as settings.CustomSettingsTile).child;
    }
    if (tile is! settings.SettingsTile) return tile;

    final settingsTile = tile as settings.SettingsTile;
    final enabled = settingsTile.enabled;
    final colors = Theme.of(context).colorScheme;
    final secondaryColor = enabled
        ? colors.onSurfaceVariant
        : colors.onSurfaceVariant.withValues(alpha: 0.42);

    Widget? trailing;
    if (settingsTile.trailing != null) {
      trailing = settingsTile.trailing;
    } else if (settingsTile.tileType == settings.SettingsTileType.switchTile) {
      trailing = PlatformSwitch(
        value: settingsTile.initialValue ?? false,
        activeColor: settingsTile.activeSwitchColor ?? colors.primary,
        onChanged: enabled && settingsTile.onToggle != null
            ? (value) => settingsTile.onToggle!(value)
            : null,
      );
    } else if (settingsTile.tileType ==
        settings.SettingsTileType.navigationTile) {
      trailing = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (settingsTile.value != null)
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 170),
              child: DefaultTextStyle.merge(
                style: TextStyle(color: secondaryColor, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                child: settingsTile.value!,
              ),
            ),
          if (settingsTile.value != null) const SizedBox(width: 6),
          Icon(
            CupertinoIcons.chevron_forward,
            size: 16,
            color: secondaryColor,
          ),
        ],
      );
    } else if (settingsTile.value != null) {
      trailing = ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 180),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: secondaryColor, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          child: settingsTile.value!,
        ),
      );
    }

    VoidCallback? onTap;
    if (enabled) {
      if (settingsTile.tileType == settings.SettingsTileType.switchTile &&
          settingsTile.onToggle != null) {
        onTap =
            () => settingsTile.onToggle!(!(settingsTile.initialValue ?? false));
      } else if (settingsTile.onPressed != null) {
        onTap = () => settingsTile.onPressed!(context);
      }
    }

    return Opacity(
      opacity: enabled ? 1 : 0.48,
      child: PlatformListTile(
        contentPadding: const EdgeInsetsDirectional.fromSTEB(14, 7, 12, 7),
        leading: settingsTile.leading == null
            ? null
            : IconTheme.merge(
                data: IconThemeData(
                  color: enabled ? colors.primary : secondaryColor,
                  size: 20,
                ),
                child: settingsTile.leading!,
              ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DefaultTextStyle.merge(
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.12,
              ),
              child: settingsTile.title,
            ),
            if (settingsTile.description != null) ...[
              const SizedBox(height: 3),
              DefaultTextStyle.merge(
                style: TextStyle(
                  color: secondaryColor,
                  fontSize: 13,
                  height: 1.18,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                child: settingsTile.description!,
              ),
            ],
          ],
        ),
        trailing: trailing,
        enabled: enabled,
        onTap: onTap,
      ),
    );
  }
}

/// A Card-compatible facade that keeps Material behavior and turns iOS cards
/// into lightweight Liquid Glass surfaces.
class PlatformCard extends StatelessWidget {
  final Color? color;
  final Color? surfaceTintColor;
  final double? elevation;
  final ShapeBorder? shape;
  final bool borderOnForeground;
  final EdgeInsetsGeometry? margin;
  final Clip? clipBehavior;
  final bool semanticContainer;
  final Widget? child;
  final EdgeInsetsGeometry? padding;

  const PlatformCard({
    required this.child,
    this.color,
    this.surfaceTintColor,
    this.elevation,
    this.shape,
    this.borderOnForeground = true,
    this.margin,
    this.clipBehavior,
    this.semanticContainer = true,
    this.padding,
    super.key,
  });

  BorderRadius _borderRadius() {
    final cardShape = shape;
    if (cardShape is RoundedRectangleBorder) {
      final radius = cardShape.borderRadius;
      if (radius is BorderRadius) return radius;
    }
    return BorderRadius.circular(18);
  }

  @override
  Widget build(BuildContext context) {
    if (isMaterial(context)) {
      return Card(
        color: color,
        surfaceTintColor: surfaceTintColor,
        elevation: elevation,
        shape: shape,
        borderOnForeground: borderOnForeground,
        margin: margin,
        clipBehavior: clipBehavior,
        semanticContainer: semanticContainer,
        child: padding == null
            ? child
            : Padding(
                padding: padding!,
                child: child ?? const SizedBox.shrink(),
              ),
      );
    }

    return PlatformLiquidGlassCard(
      margin: margin,
      padding: padding,
      borderRadius: _borderRadius(),
      tintColor: color,
      child: clipBehavior == null || clipBehavior == Clip.none
          ? child ?? const SizedBox.shrink()
          : ClipRRect(
              borderRadius: _borderRadius(),
              clipBehavior: clipBehavior!,
              child: child ?? const SizedBox.shrink(),
            ),
    );
  }
}

class PlatformLiquidGlassAvatar extends StatelessWidget {
  final double size;
  final Widget child;

  const PlatformLiquidGlassAvatar({
    required this.size,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (!usesAppleTranslucentSurface(context)) {
      return ClipOval(child: SizedBox.square(dimension: size, child: child));
    }
    final light = Theme.of(context).brightness == Brightness.light;
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: light ? 0.92 : 0.42),
            Colors.white.withValues(alpha: light ? 0.28 : 0.10),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: light ? 0.80 : 0.30),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: light ? 0.16 : 0.38),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipOval(child: child),
    );
  }
}

class MaterialTextFormFieldData {
  final InputDecoration? decoration;

  const MaterialTextFormFieldData({this.decoration});
}

class CupertinoTextFormFieldData {
  final Widget? prefix;
  final BoxDecoration? decoration;

  const CupertinoTextFormFieldData({this.prefix, this.decoration});
}

class PlatformTextFormField extends StatelessWidget {
  final Key? widgetKey;
  final TextEditingController? controller;
  final String? initialValue;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final TextStyle? style;
  final TextAlign? textAlign;
  final bool? autofocus;
  final bool? readOnly;
  final bool? showCursor;
  final String obscuringCharacter;
  final bool? obscureText;
  final bool? autocorrect;
  final bool? enableSuggestions;
  final int? maxLines;
  final int? minLines;
  final bool? expands;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final GestureTapCallback? onTap;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final bool? enabled;
  final Iterable<String>? autofillHints;
  final AutovalidateMode? autovalidateMode;
  final String? hintText;
  final PlatformBuilder<MaterialTextFormFieldData>? material;
  final PlatformBuilder<CupertinoTextFormFieldData>? cupertino;

  const PlatformTextFormField({
    this.widgetKey,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.textAlign,
    this.autofocus,
    this.readOnly,
    this.showCursor,
    this.obscuringCharacter = '•',
    this.obscureText,
    this.autocorrect,
    this.enableSuggestions,
    this.maxLines = 1,
    this.minLines,
    this.expands,
    this.maxLength,
    this.onChanged,
    this.onTap,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.onSaved,
    this.validator,
    this.inputFormatters,
    this.enabled,
    this.autofillHints,
    this.autovalidateMode,
    this.hintText,
    this.material,
    this.cupertino,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final target = platform(context);
    if (isCupertino(context)) {
      final data = cupertino?.call(context, target);
      return CupertinoTextFormFieldRow(
        key: widgetKey,
        controller: controller,
        initialValue: initialValue,
        focusNode: focusNode,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        textCapitalization: textCapitalization,
        style: style,
        textAlign: textAlign ?? TextAlign.start,
        autofocus: autofocus ?? false,
        readOnly: readOnly ?? false,
        showCursor: showCursor,
        obscuringCharacter: obscuringCharacter,
        obscureText: obscureText ?? false,
        autocorrect: autocorrect ?? true,
        enableSuggestions: enableSuggestions ?? true,
        maxLines: maxLines,
        minLines: minLines,
        expands: expands ?? false,
        maxLength: maxLength,
        onChanged: onChanged,
        onTap: onTap,
        onEditingComplete: onEditingComplete,
        onFieldSubmitted: onFieldSubmitted,
        onSaved: onSaved,
        validator: validator,
        inputFormatters: inputFormatters,
        enabled: enabled,
        autofillHints: autofillHints,
        autovalidateMode: autovalidateMode ?? AutovalidateMode.disabled,
        placeholder: hintText,
        prefix: data?.prefix,
        decoration: data?.decoration,
      );
    }
    final data = material?.call(context, target);
    return TextFormField(
      key: widgetKey,
      controller: controller,
      initialValue: initialValue,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      style: style,
      textAlign: textAlign ?? TextAlign.start,
      autofocus: autofocus ?? false,
      readOnly: readOnly ?? false,
      showCursor: showCursor,
      obscuringCharacter: obscuringCharacter,
      obscureText: obscureText ?? false,
      autocorrect: autocorrect ?? true,
      enableSuggestions: enableSuggestions ?? true,
      maxLines: maxLines,
      minLines: minLines,
      expands: expands ?? false,
      maxLength: maxLength,
      onChanged: onChanged,
      onTap: onTap,
      onEditingComplete: onEditingComplete,
      onFieldSubmitted: onFieldSubmitted,
      onSaved: onSaved,
      validator: validator,
      inputFormatters: inputFormatters,
      enabled: enabled,
      autofillHints: autofillHints,
      autovalidateMode: autovalidateMode,
      decoration: (data?.decoration ?? const InputDecoration()).copyWith(
        hintText: hintText ?? data?.decoration?.hintText,
      ),
    );
  }
}

class PlatformListTile extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final FutureOr<void> Function()? onTap;
  final GestureLongPressCallback? onLongPress;
  final bool isThreeLine;
  final bool? dense;
  final bool enabled;
  final bool selected;
  final EdgeInsetsGeometry? contentPadding;
  final Color? selectedColor;
  final Color? iconColor;
  final Color? textColor;
  final Color? tileColor;
  final Color? selectedTileColor;
  final ShapeBorder? shape;

  const PlatformListTile({
    required this.title,
    this.leading,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.isThreeLine = false,
    this.dense,
    this.enabled = true,
    this.selected = false,
    this.contentPadding,
    this.selectedColor,
    this.iconColor,
    this.textColor,
    this.tileColor,
    this.selectedTileColor,
    this.shape,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (isMaterial(context)) {
      return ListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        onTap: enabled ? onTap : null,
        onLongPress: enabled ? onLongPress : null,
        isThreeLine: isThreeLine,
        dense: dense,
        enabled: enabled,
        selected: selected,
        contentPadding: contentPadding,
        selectedColor: selectedColor,
        iconColor: iconColor,
        textColor: textColor,
        tileColor: tileColor,
        selectedTileColor: selectedTileColor,
        shape: shape,
      );
    }

    final foreground = selected ? selectedColor : textColor;
    final cupertinoSubtitle = subtitle == null || !isThreeLine
        ? subtitle
        : Builder(
            builder: (subtitleContext) {
              final inherited = DefaultTextStyle.of(subtitleContext);
              return DefaultTextStyle(
                style: inherited.style,
                textAlign: inherited.textAlign,
                softWrap: true,
                overflow: TextOverflow.visible,
                maxLines: null,
                textWidthBasis: inherited.textWidthBasis,
                textHeightBehavior: inherited.textHeightBehavior,
                child: subtitle!,
              );
            },
          );
    Widget tile = CupertinoListTile(
      padding: contentPadding,
      leading: leading,
      title: DefaultTextStyle.merge(
        style: foreground == null ? null : TextStyle(color: foreground),
        child: title,
      ),
      subtitle: cupertinoSubtitle,
      trailing: trailing,
      backgroundColor: Colors.transparent,
      backgroundColorActivated: Colors.transparent,
      onTap: enabled && onTap != null ? () => onTap!() : null,
    );
    if (iconColor != null) {
      tile =
          IconTheme.merge(data: IconThemeData(color: iconColor), child: tile);
    }
    if (enabled && onLongPress != null) {
      tile = GestureDetector(onLongPress: onLongPress, child: tile);
    }
    if (!usesAppleTranslucentSurface(context) ||
        _PlatformGlassContainerScope.contains(context)) {
      return tile;
    }
    return PlatformLiquidGlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      selected: selected,
      tintColor: selected ? selectedTileColor : tileColor,
      child: tile,
    );
  }
}

class PlatformSwitch extends StatelessWidget {
  final Key? widgetKey;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;

  const PlatformSwitch({
    required this.value,
    required this.onChanged,
    this.widgetKey,
    this.activeColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (usesLiquidGlass(context)) {
      return liquid.AdaptiveSwitch(
        key: widgetKey,
        value: value,
        onChanged: onChanged,
        activeColor: activeColor,
      );
    }
    return isCupertino(context)
        ? CupertinoSwitch(
            key: widgetKey,
            value: value,
            onChanged: onChanged,
            activeTrackColor: activeColor,
          )
        : Switch(
            key: widgetKey,
            value: value,
            onChanged: onChanged,
            activeThumbColor: activeColor,
          );
  }
}

class PlatformSlider extends StatelessWidget {
  final Key? widgetKey;
  final double value;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;
  final Color? activeColor;
  final int? divisions;
  final double min;
  final double max;
  final Color? thumbColor;

  const PlatformSlider({
    required this.value,
    required this.onChanged,
    this.widgetKey,
    this.onChangeStart,
    this.onChangeEnd,
    this.activeColor,
    this.divisions,
    this.min = 0,
    this.max = 1,
    this.thumbColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (usesLiquidGlass(context)) {
      return liquid.AdaptiveSlider(
        key: widgetKey,
        value: value,
        onChanged: onChanged,
        onChangeStart: onChangeStart,
        onChangeEnd: onChangeEnd,
        activeColor: activeColor,
        divisions: divisions,
        min: min,
        max: max,
        thumbColor: thumbColor,
      );
    }
    return isCupertino(context)
        ? CupertinoSlider(
            key: widgetKey,
            value: value,
            onChanged: onChanged,
            onChangeStart: onChangeStart,
            onChangeEnd: onChangeEnd,
            activeColor: activeColor,
            divisions: divisions,
            min: min,
            max: max,
            thumbColor: thumbColor ?? CupertinoColors.white,
          )
        : Slider(
            key: widgetKey,
            value: value,
            onChanged: onChanged,
            onChangeStart: onChangeStart,
            onChangeEnd: onChangeEnd,
            activeColor: activeColor,
            divisions: divisions,
            min: min,
            max: max,
            thumbColor: thumbColor,
          );
  }
}

class PlatformSegmentedControl extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onValueChanged;
  final Color? color;
  final Color? textColor;
  final Color? selectedTextColor;

  const PlatformSegmentedControl({
    required this.labels,
    required this.selectedIndex,
    required this.onValueChanged,
    this.color,
    this.textColor,
    this.selectedTextColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final effectiveTextColor = textColor ?? colors.onSurfaceVariant;
    final effectiveSelectedTextColor = selectedTextColor ??
        (color == null ? colors.onSurface : _contrastColor(context, color!));
    if (usesLiquidGlass(context)) {
      return liquid.AdaptiveSegmentedControl(
        labels: labels,
        selectedIndex: selectedIndex,
        onValueChanged: onValueChanged,
        color: color,
        textColor: effectiveTextColor,
        selectedTextColor: effectiveSelectedTextColor,
        height: 44,
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 44),
      child: CupertinoSlidingSegmentedControl<int>(
        groupValue: selectedIndex,
        thumbColor: color ?? CupertinoColors.systemGrey5,
        onValueChanged: (value) {
          if (value != null) onValueChanged(value);
        },
        children: {
          for (var index = 0; index < labels.length; index++)
            index: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                labels[index],
                style: TextStyle(
                  color: index == selectedIndex
                      ? effectiveSelectedTextColor
                      : effectiveTextColor,
                  fontWeight: index == selectedIndex
                      ? FontWeight.w600
                      : FontWeight.w500,
                ),
              ),
            ),
        },
      ),
    );
  }

  Color _contrastColor(BuildContext context, Color background) {
    final opaqueBackground = Color.alphaBlend(
      background,
      Theme.of(context).colorScheme.surface,
    );
    return ThemeData.estimateBrightnessForColor(opaqueBackground) ==
            Brightness.dark
        ? Colors.white
        : Colors.black.withValues(alpha: 0.87);
  }
}

class PlatformTabScaffold extends StatefulWidget {
  final List<adaptive.TabDestination> tabDestinations;
  final int selectedIndex;
  final ValueChanged<int>? onTabDestinationTap;
  final IndexedWidgetBuilder? tabBodyBuilder;
  final Color? backgroundColor;

  const PlatformTabScaffold({
    required this.tabDestinations,
    this.selectedIndex = 0,
    this.onTabDestinationTap,
    this.tabBodyBuilder,
    this.backgroundColor,
    super.key,
  });

  @override
  State<PlatformTabScaffold> createState() => _PlatformTabScaffoldState();
}

class _PlatformTabScaffoldState extends State<PlatformTabScaffold> {
  late int selectedIndex = widget.selectedIndex;

  void select(int index) {
    setState(() => selectedIndex = index);
    widget.onTabDestinationTap?.call(index);
  }

  Widget bodyAt(BuildContext context, int index) =>
      widget.tabBodyBuilder?.call(context, index) ??
      widget.tabDestinations[index].view ??
      const SizedBox.shrink();

  @override
  Widget build(BuildContext context) {
    if (usesLiquidGlass(context)) {
      Widget body = IndexedStack(
        index: selectedIndex,
        children: [
          for (var index = 0; index < widget.tabDestinations.length; index++)
            bodyAt(context, index),
        ],
      );
      if (widget.backgroundColor != null) {
        body = ColoredBox(color: widget.backgroundColor!, child: body);
      }

      return liquid.AdaptiveScaffold(
        body: _PlatformStatefulNavigationShell(child: body),
        bottomNavigationBar: liquid.AdaptiveBottomNavigationBar(
          selectedIndex: selectedIndex,
          onTap: select,
          useNativeBottomBar: true,
          items: [
            for (final destination in widget.tabDestinations)
              liquid.AdaptiveNavigationDestination(
                icon: _liquidGlassSymbolForWidget(destination.inactiveIcon) ??
                    destination.inactiveIcon,
                selectedIcon: _liquidGlassSymbolForWidget(
                        destination.activeIcon ?? destination.inactiveIcon) ??
                    destination.activeIcon ??
                    destination.inactiveIcon,
                label: destination.label,
              ),
          ],
        ),
      );
    }
    if (isCupertino(context)) {
      return CupertinoTabScaffold(
        backgroundColor: widget.backgroundColor,
        tabBar: CupertinoTabBar(
          currentIndex: selectedIndex,
          onTap: select,
          items: [
            for (final destination in widget.tabDestinations)
              BottomNavigationBarItem(
                icon: destination.inactiveIcon,
                activeIcon: destination.activeIcon,
                label: destination.label,
                tooltip: destination.tooltip,
              ),
          ],
        ),
        tabBuilder: bodyAt,
      );
    }
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: IndexedStack(
        index: selectedIndex,
        children: [
          for (var index = 0; index < widget.tabDestinations.length; index++)
            bodyAt(context, index),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: select,
        destinations: [
          for (final destination in widget.tabDestinations)
            NavigationDestination(
              icon: destination.inactiveIcon,
              selectedIcon: destination.activeIcon,
              label: destination.label,
              tooltip: destination.tooltip,
            ),
        ],
      ),
    );
  }
}

class PlatformAlertDialog extends StatelessWidget {
  final Widget? title;
  final Widget? content;
  final List<Widget>? actions;

  const PlatformAlertDialog(
      {this.title, this.content, this.actions, super.key});

  @override
  Widget build(BuildContext context) {
    if (usesLiquidGlass(context)) {
      final dialogActions = actions ?? const <Widget>[];
      final actionContent = dialogActions.length <= 2
          ? Row(
              children: [
                for (final action in dialogActions) Expanded(child: action),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final action in dialogActions)
                  SizedBox(width: double.infinity, child: action),
              ],
            );
      return Center(
        child: Material(
          type: MaterialType.transparency,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 280,
              maxWidth: math.min(MediaQuery.sizeOf(context).width - 32, 390.0),
              maxHeight: MediaQuery.sizeOf(context).height * 0.82,
            ),
            child: PlatformLiquidGlassCard(
              borderRadius: BorderRadius.circular(30),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (title != null)
                      DefaultTextStyle.merge(
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                        child: title!,
                      ),
                    if (title != null && content != null)
                      const SizedBox(height: 12),
                    if (content != null) content!,
                    if (dialogActions.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Divider(
                        height: 1,
                        color: CupertinoColors.separator.resolveFrom(context),
                      ),
                      const SizedBox(height: 4),
                      actionContent,
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    return isCupertino(context)
        ? CupertinoAlertDialog(
            title: title,
            content: content,
            actions: actions ?? const [],
          )
        : AlertDialog(title: title, content: content, actions: actions);
  }
}

class PlatformDialogAction extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool isDefaultAction;
  final bool isDestructiveAction;

  const PlatformDialogAction({
    required this.child,
    this.onPressed,
    this.isDefaultAction = false,
    this.isDestructiveAction = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (usesLiquidGlass(context)) {
      final foreground = isDestructiveAction
          ? CupertinoColors.systemRed.resolveFrom(context)
          : Theme.of(context).colorScheme.primary;
      return ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: SizedBox(
          width: double.infinity,
          child: CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            onPressed: onPressed,
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: foreground,
                fontWeight: isDefaultAction ? FontWeight.w600 : FontWeight.w400,
              ),
              child: child,
            ),
          ),
        ),
      );
    }
    return isCupertino(context)
        ? CupertinoDialogAction(
            onPressed: onPressed,
            isDefaultAction: isDefaultAction,
            isDestructiveAction: isDestructiveAction,
            child: child,
          )
        : TextButton(onPressed: onPressed, child: child);
  }
}

class PlatformAlertAction {
  final String label;
  final FutureOr<void> Function()? onPressed;
  final bool isDefaultAction;
  final bool isDestructiveAction;
  final bool isCancelAction;

  const PlatformAlertAction({
    required this.label,
    this.onPressed,
    this.isDefaultAction = false,
    this.isDestructiveAction = false,
    this.isCancelAction = false,
  });
}

/// Shows the native iOS 26 Liquid Glass alert when the dialog can be expressed
/// as a title, message and actions. Rich widget dialogs continue to use
/// [showPlatformDialog].
Future<void> showPlatformAlert({
  required BuildContext context,
  required String title,
  String? message,
  required List<PlatformAlertAction> actions,
}) async {
  if (usesLiquidGlass(context)) {
    await liquid.AdaptiveAlertDialog.show(
      context: context,
      title: title,
      message: message,
      actions: [
        for (final action in actions)
          liquid.AlertAction(
            title: action.label,
            style: action.isDestructiveAction
                ? liquid.AlertActionStyle.destructive
                : action.isCancelAction
                    ? liquid.AlertActionStyle.cancel
                    : action.isDefaultAction
                        ? liquid.AlertActionStyle.primary
                        : liquid.AlertActionStyle.defaultAction,
            onPressed: () {
              if (action.onPressed != null) {
                unawaited(Future.sync(action.onPressed!));
              }
            },
          ),
      ],
    );
    return;
  }

  await showPlatformDialog<void>(
    context: context,
    builder: (dialogContext) => PlatformAlertDialog(
      title: Text(title),
      content: message == null ? null : Text(message),
      actions: [
        for (final action in actions)
          PlatformDialogAction(
            isDefaultAction: action.isDefaultAction,
            isDestructiveAction: action.isDestructiveAction,
            onPressed: () {
              Navigator.of(dialogContext).pop();
              if (action.onPressed != null) {
                unawaited(Future.sync(action.onPressed!));
              }
            },
            child: Text(
              action.label,
              style: action.isDestructiveAction
                  ? TextStyle(color: Theme.of(dialogContext).colorScheme.error)
                  : null,
            ),
          ),
      ],
    ),
  );
}

Future<T?> showPlatformDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) =>
    isCupertino(context)
        ? showCupertinoDialog<T>(
            context: context,
            builder: builder,
            barrierDismissible: barrierDismissible,
          )
        : showDialog<T>(
            context: context,
            builder: builder,
            barrierDismissible: barrierDismissible,
          );

class MaterialModalSheetData {
  final bool isScrollControlled;

  const MaterialModalSheetData({this.isScrollControlled = false});
}

Future<T?> showPlatformModalSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  MaterialModalSheetData? material,
}) =>
    isCupertino(context)
        ? showCupertinoModalPopup<T>(
            context: context,
            builder: (sheetContext) {
              final colors = Theme.of(sheetContext).colorScheme;
              final sheetContent = CupertinoUserInterfaceLevel(
                data: CupertinoUserInterfaceLevelData.elevated,
                child: DefaultTextStyle.merge(
                  style: TextStyle(color: colors.onSurface),
                  child: IconTheme.merge(
                    data: IconThemeData(color: colors.onSurfaceVariant),
                    child: builder(sheetContext),
                  ),
                ),
              );
              if (!usesLiquidGlass(sheetContext)) {
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: CupertinoPopupSurface(
                    isSurfacePainted: true,
                    child: SafeArea(
                      top: false,
                      child: SizedBox(
                        width: double.infinity,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight:
                                MediaQuery.sizeOf(sheetContext).height * 0.90,
                          ),
                          child: sheetContent,
                        ),
                      ),
                    ),
                  ),
                );
              }
              return SafeArea(
                top: false,
                minimum: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: double.infinity,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight:
                            MediaQuery.sizeOf(sheetContext).height * 0.90,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.18),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Material(
                          type: MaterialType.transparency,
                          child: _PlatformGlassContainerScope(
                            child: PlatformLiquidGlassSurface(
                              borderRadius: BorderRadius.circular(28),
                              child: sheetContent,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          )
        : showModalBottomSheet<T>(
            context: context,
            builder: builder,
            isScrollControlled: material?.isScrollControlled ?? false,
          );

PageRoute<T> platformPageRoute<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  String? iosTitle,
  RouteSettings? settings,
  bool maintainState = true,
  bool fullscreenDialog = false,
}) =>
    isCupertino(context)
        ? CupertinoPageRoute<T>(
            builder: builder,
            title: iosTitle,
            settings: settings,
            maintainState: maintainState,
            fullscreenDialog: fullscreenDialog,
          )
        : MaterialPageRoute<T>(
            builder: builder,
            settings: settings,
            maintainState: maintainState,
            fullscreenDialog: fullscreenDialog,
          );

class MaterialPopupMenuOptionData {
  final TextStyle? textStyle;

  const MaterialPopupMenuOptionData({this.textStyle});
}

class CupertinoPopupMenuOptionData {
  final bool isDestructiveAction;

  const CupertinoPopupMenuOptionData({this.isDestructiveAction = false});
}

class PopupMenuOption {
  final String label;
  final void Function(PopupMenuOption option) onTap;
  final PlatformBuilder<MaterialPopupMenuOptionData>? material;
  final PlatformBuilder<CupertinoPopupMenuOptionData>? cupertino;

  const PopupMenuOption({
    required this.label,
    required this.onTap,
    this.material,
    this.cupertino,
  });
}

class PlatformPopupMenu extends StatelessWidget {
  final Widget icon;
  final List<PopupMenuOption> options;
  final String liquidGlassSymbol;
  final double liquidGlassButtonSize;

  const PlatformPopupMenu({
    required this.icon,
    required this.options,
    this.liquidGlassSymbol = 'ellipsis',
    this.liquidGlassButtonSize = 44,
    super.key,
  });

  Future<void> show(BuildContext context) async {
    final selected = await showPlatformModalSheet<PopupMenuOption>(
      context: context,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: _PlatformGlassContainerScope(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.64,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final option in options)
                        PlatformListTile(
                          title: Text(
                            option.label,
                            style: option.cupertino
                                        ?.call(context, platform(context))
                                        .isDestructiveAction ??
                                    false
                                ? TextStyle(
                                    color: CupertinoColors.systemRed
                                        .resolveFrom(sheetContext),
                                  )
                                : null,
                          ),
                          onTap: () => Navigator.pop(sheetContext, option),
                        ),
                    ],
                  ),
                ),
                PlatformTextButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  child: Text(
                    CupertinoLocalizations.of(sheetContext).cancelButtonLabel,
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ),
    );
    if (selected != null) selected.onTap(selected);
  }

  @override
  Widget build(BuildContext context) {
    if (usesLiquidGlass(context)) {
      final grouped = _PlatformLiquidGlassToolbarGroupScope.contains(context);
      final items = <liquid.AdaptivePopupMenuEntry>[
        for (final option in options)
          liquid.AdaptivePopupMenuItem<PopupMenuOption>(
            label: option.label,
            value: option,
            isDestructive: option.cupertino
                    ?.call(context, platform(context))
                    .isDestructiveAction ??
                false,
          ),
      ];
      return liquid.AdaptivePopupMenuButton.icon<PopupMenuOption>(
        icon: liquidGlassSymbol,
        items: items,
        size: liquidGlassButtonSize,
        tint: _iconForWidget(icon)?.color ??
            CupertinoColors.label.resolveFrom(context),
        buttonStyle: grouped
            ? liquid.PopupButtonStyle.plain
            : liquid.PopupButtonStyle.glass,
        onSelected: (_, entry) => entry.value?.onTap(entry.value!),
      );
    }
    if (isCupertino(context)) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => show(context),
        child: icon,
      );
    }
    return PopupMenuButton<PopupMenuOption>(
      icon: icon,
      onSelected: (option) => option.onTap(option),
      itemBuilder: (context) => [
        for (final option in options)
          PopupMenuItem(
            value: option,
            textStyle:
                option.material?.call(context, platform(context)).textStyle,
            child: Text(option.label),
          ),
      ],
    );
  }
}

class PlatformIcons {
  final BuildContext context;

  const PlatformIcons(this.context);

  IconData pick(IconData material, IconData cupertino) =>
      isMaterial(context) ? material : cupertino;

  IconData get add => pick(Icons.add, CupertinoIcons.add);
  IconData get addCircled => pick(Icons.add_circle, CupertinoIcons.add_circled);
  IconData get attachment => pick(Icons.attachment, CupertinoIcons.paperclip);
  IconData get back => pick(Icons.arrow_back, CupertinoIcons.back);
  IconData get birthday => pick(Icons.cake_outlined, CupertinoIcons.gift);
  IconData get blocked => pick(Icons.block, CupertinoIcons.hand_raised_slash);
  IconData get bold => pick(Icons.format_bold_outlined, CupertinoIcons.bold);
  IconData get bookmark => pick(Icons.bookmark_border, CupertinoIcons.bookmark);
  IconData get bookmarkSolid =>
      pick(Icons.bookmark, CupertinoIcons.bookmark_solid);
  IconData get brightness =>
      pick(Icons.brightness_low, CupertinoIcons.brightness);
  IconData get category =>
      pick(Icons.category_outlined, CupertinoIcons.rectangle_grid_2x2);
  IconData get family => pick(Icons.child_care, CupertinoIcons.person_2);
  IconData get chart => pick(Icons.query_stats, CupertinoIcons.chart_bar);
  IconData get checkMark => pick(Icons.check, CupertinoIcons.check_mark);
  IconData get checkMarkCircled =>
      pick(Icons.check_circle, CupertinoIcons.check_mark_circled);
  IconData get checkMarkCircledOutline =>
      pick(Icons.check_circle_outline, CupertinoIcons.check_mark_circled);
  IconData get checkMarkCircledSolid =>
      pick(Icons.check_circle, CupertinoIcons.check_mark_circled_solid);
  IconData get clearThickCircled =>
      pick(Icons.cancel, CupertinoIcons.clear_thick_circled);
  IconData get closeCircled =>
      pick(Icons.cancel_outlined, CupertinoIcons.xmark_circle);
  IconData get clockSolid =>
      pick(Icons.watch_later, CupertinoIcons.clock_solid);
  IconData get collectionsSolid =>
      pick(Icons.collections, CupertinoIcons.collections_solid);
  IconData get downArrow =>
      pick(Icons.arrow_downward, CupertinoIcons.down_arrow);
  IconData get dashboard =>
      pick(Icons.dashboard, CupertinoIcons.square_grid_2x2);
  IconData get delete => pick(Icons.delete, CupertinoIcons.delete);
  IconData get document =>
      pick(Icons.description_outlined, CupertinoIcons.doc_text);
  IconData get edit => pick(Icons.edit, CupertinoIcons.pencil);
  IconData get ellipsis => pick(Icons.more_vert, CupertinoIcons.ellipsis);
  IconData get error =>
      pick(Icons.error, CupertinoIcons.exclamationmark_circle_fill);
  IconData get errorOutline =>
      pick(Icons.error_outline, CupertinoIcons.exclamationmark_circle);
  IconData get expiredSession =>
      pick(Icons.lock_clock, CupertinoIcons.lock_rotation);
  IconData get failedMessage =>
      pick(Icons.sms_failed_outlined, CupertinoIcons.exclamationmark_bubble);
  IconData get failedSync => pick(
      Icons.sync_problem_outlined, CupertinoIcons.arrow_2_circlepath_circle);
  IconData get flame => pick(Icons.whatshot_rounded, CupertinoIcons.flame_fill);
  IconData get flag => pick(Icons.flag, CupertinoIcons.flag);
  IconData get favoriteOutline =>
      pick(Icons.favorite_border, CupertinoIcons.heart);
  IconData get favoriteSolid => pick(Icons.favorite, CupertinoIcons.heart_fill);
  IconData get folderSolid => pick(Icons.folder, CupertinoIcons.folder_fill);
  IconData get forumOutline =>
      pick(Icons.forum_outlined, CupertinoIcons.chat_bubble_2);
  IconData get formatQuote =>
      pick(Icons.format_quote_outlined, CupertinoIcons.text_quote);
  IconData get forward => pick(Icons.arrow_forward, CupertinoIcons.forward);
  IconData get fullscreen => pick(Icons.fullscreen, CupertinoIcons.fullscreen);
  IconData get globe => pick(Icons.explore_outlined, CupertinoIcons.globe);
  IconData get groupSolid => pick(Icons.group, CupertinoIcons.group_solid);
  IconData get history => pick(Icons.history, CupertinoIcons.clock);
  IconData get historyTimeout =>
      pick(Icons.history_toggle_off_outlined, CupertinoIcons.gobackward);
  IconData get helpOutline =>
      pick(Icons.help_outline, CupertinoIcons.question_circle);
  IconData get info => pick(Icons.info_outline, CupertinoIcons.info);
  IconData get italic =>
      pick(Icons.format_italic_outlined, CupertinoIcons.italic);
  IconData get keyboard =>
      pick(Icons.keyboard_rounded, CupertinoIcons.keyboard);
  IconData get login =>
      pick(Icons.login, CupertinoIcons.person_crop_circle_badge_checkmark);
  IconData get location =>
      pick(Icons.location_city_outlined, CupertinoIcons.building_2_fill);
  IconData get micSolid => pick(Icons.mic, CupertinoIcons.mic_fill);
  IconData get notificationOutline =>
      pick(Icons.notifications_outlined, CupertinoIcons.bell);
  IconData get profileMessage =>
      pick(Icons.message_outlined, CupertinoIcons.chat_bubble);
  IconData get personAddSolid =>
      pick(Icons.person_add, CupertinoIcons.person_add_solid);
  IconData get person =>
      pick(Icons.person_pin, CupertinoIcons.person_crop_circle);
  IconData get photo =>
      pick(Icons.image_outlined, CupertinoIcons.photo_on_rectangle);
  IconData get photoCameraSolid =>
      pick(Icons.photo_camera, CupertinoIcons.camera_fill);
  IconData get playCircleSolid =>
      pick(Icons.play_circle, CupertinoIcons.play_circle_fill);
  IconData get refresh => pick(Icons.refresh, CupertinoIcons.refresh);
  IconData get removeCircledSolid =>
      pick(Icons.remove_circle, CupertinoIcons.minus_circle_fill);
  IconData get settings =>
      pick(Icons.settings_outlined, CupertinoIcons.settings);
  IconData get settingsSolid =>
      pick(Icons.settings, CupertinoIcons.settings_solid);
  IconData get share => pick(Icons.share, CupertinoIcons.share);
  IconData get secure => pick(Icons.lock_outline, CupertinoIcons.lock_shield);
  IconData get shieldWarning =>
      pick(Icons.key_off_outlined, CupertinoIcons.exclamationmark_shield);
  IconData get smiley =>
      pick(Icons.emoji_emotions_outlined, CupertinoIcons.smiley);
  IconData get sort => pick(Icons.sort, CupertinoIcons.sort_down);
  IconData get study => pick(Icons.history_edu, CupertinoIcons.book);
  IconData get tagSolid => pick(Icons.sell, CupertinoIcons.tag_fill);
  IconData get home => pick(Icons.home, CupertinoIcons.house_fill);
  IconData get timeout => pick(Icons.access_time, CupertinoIcons.clock);
  IconData get translate =>
      pick(Icons.translate, CupertinoIcons.textformat_abc);
  IconData get unavailableImage =>
      pick(Icons.image_not_supported, CupertinoIcons.photo_on_rectangle);
  IconData get verified =>
      pick(Icons.check_circle_outline, CupertinoIcons.checkmark_seal);
  IconData get verifiedUser =>
      pick(Icons.verified_user_rounded, CupertinoIcons.checkmark_shield_fill);
  IconData get warning => pick(
      Icons.warning_amber_outlined, CupertinoIcons.exclamationmark_triangle);
  IconData get wifiWarning =>
      pick(Icons.explore_off_outlined, CupertinoIcons.wifi_exclamationmark);
  IconData get work => pick(Icons.work_outline, CupertinoIcons.briefcase);
  IconData get credits =>
      pick(Icons.account_balance, CupertinoIcons.creditcard);
  IconData get cube => pick(Icons.view_in_ar, CupertinoIcons.cube_box);
  IconData get rule => pick(Icons.rule, CupertinoIcons.list_bullet);
  IconData get download =>
      pick(Icons.file_download, CupertinoIcons.arrow_down_to_line);
  IconData get timeSolid =>
      pick(Icons.access_time_filled, CupertinoIcons.time_solid);
  IconData get upArrow => pick(Icons.arrow_upward, CupertinoIcons.up_arrow);
}

extension PlatformIconsExt on BuildContext {
  PlatformIcons get platformIcons => PlatformIcons(this);

  IconData platformIcon({
    required IconData material,
    required IconData cupertino,
  }) =>
      isMaterial(this) ? material : cupertino;
}
