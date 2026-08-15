import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:platform_adaptive_widgets/platform_adaptive_widgets.dart'
    as adaptive;

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
      final useDark = themes?.themeMode == ThemeMode.dark ||
          (themes?.themeMode == ThemeMode.system &&
              brightness == Brightness.dark);
      return CupertinoApp(
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
  final Color? backgroundColor;
  final Widget? leading;
  final List<Widget>? trailingActions;
  final bool? automaticallyImplyLeading;
  final PreferredSizeWidget? bottom;
  final PlatformBuilder<adaptive.MaterialAppBarData>? material;
  final PlatformBuilder<adaptive.CupertinoNavigationBarData>? cupertino;

  const PlatformAppBar({
    this.widgetKey,
    this.title,
    this.backgroundColor,
    this.leading,
    this.trailingActions,
    this.automaticallyImplyLeading,
    this.bottom,
    this.material,
    this.cupertino,
  });

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
    final trailing = trailingActions == null || trailingActions!.isEmpty
        ? null
        : Row(mainAxisSize: MainAxisSize.min, children: trailingActions!);
    return CupertinoNavigationBar(
      key: widgetKey,
      middle: title,
      backgroundColor: backgroundColor,
      leading: leading,
      bottom: bottom,
      automaticallyImplyLeading: automaticallyImplyLeading ?? true,
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
  final bool iosContentPadding;
  final bool iosContentBottomPadding;

  const PlatformScaffold({
    this.widgetKey,
    this.body,
    this.backgroundColor,
    this.appBar,
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
  Widget build(BuildContext context) => isCupertino(context)
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
          ),
          child: child ?? const SizedBox.shrink(),
        );
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
  Widget build(BuildContext context) => isCupertino(context)
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
          ),
          child: child ?? const SizedBox.shrink(),
        );
}

class CupertinoIconButtonData {
  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? padding;

  const CupertinoIconButtonData({this.alignment, this.padding});
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
    this.cupertino,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (isCupertino(context)) {
      final data = cupertino?.call(context, platform(context));
      return CupertinoButton(
        key: widgetKey,
        padding: data?.padding ?? padding,
        alignment: data?.alignment ?? Alignment.center,
        color: color,
        disabledColor: disabledColor ?? CupertinoColors.quaternarySystemFill,
        onPressed: onPressed,
        onLongPress: onLongPress,
        child: cupertinoIcon ?? icon ?? const SizedBox.shrink(),
      );
    }
    return IconButton(
      key: widgetKey,
      padding: padding ?? const EdgeInsets.all(8),
      color: color,
      disabledColor: disabledColor,
      onPressed: onPressed,
      onLongPress: onLongPress,
      icon: materialIcon ?? icon ?? const SizedBox.shrink(),
    );
  }
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
  Widget build(BuildContext context) => isCupertino(context)
      ? CupertinoTextField(
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
        )
      : TextField(
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

  const PlatformListTile({
    required this.title,
    this.leading,
    this.subtitle,
    this.trailing,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) => isCupertino(context)
      ? CupertinoListTile(
          leading: leading,
          title: title,
          subtitle: subtitle,
          trailing: trailing,
          onTap: onTap,
        )
      : ListTile(
          leading: leading,
          title: title,
          subtitle: subtitle,
          trailing: trailing,
          onTap: onTap,
        );
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
  Widget build(BuildContext context) => isCupertino(context)
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
          activeColor: activeColor,
        );
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
  Widget build(BuildContext context) => isCupertino(context)
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
  Widget build(BuildContext context) => isCupertino(context)
      ? CupertinoAlertDialog(
          title: title,
          content: content,
          actions: actions ?? const [],
        )
      : AlertDialog(title: title, content: content, actions: actions);
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
  Widget build(BuildContext context) => isCupertino(context)
      ? CupertinoDialogAction(
          onPressed: onPressed,
          isDefaultAction: isDefaultAction,
          isDestructiveAction: isDestructiveAction,
          child: child,
        )
      : TextButton(onPressed: onPressed, child: child);
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
        ? showCupertinoModalPopup<T>(context: context, builder: builder)
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

  const PlatformPopupMenu({
    required this.icon,
    required this.options,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (isCupertino(context)) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () async {
          final selected = await showCupertinoModalPopup<PopupMenuOption>(
            context: context,
            builder: (context) => CupertinoActionSheet(
              actions: [
                for (final option in options)
                  CupertinoActionSheetAction(
                    isDestructiveAction: option.cupertino
                            ?.call(context, platform(context))
                            .isDestructiveAction ??
                        false,
                    onPressed: () => Navigator.pop(context, option),
                    child: Text(option.label),
                  ),
              ],
              cancelButton: CupertinoActionSheetAction(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
          );
          if (selected != null) selected.onTap(selected);
        },
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
  IconData get back => pick(Icons.arrow_back, CupertinoIcons.back);
  IconData get bookmark => pick(Icons.bookmark_border, CupertinoIcons.bookmark);
  IconData get bookmarkSolid =>
      pick(Icons.bookmark, CupertinoIcons.bookmark_solid);
  IconData get brightness =>
      pick(Icons.brightness_low, CupertinoIcons.brightness);
  IconData get checkMark => pick(Icons.check, CupertinoIcons.check_mark);
  IconData get checkMarkCircled =>
      pick(Icons.check_circle, CupertinoIcons.check_mark_circled);
  IconData get checkMarkCircledOutline =>
      pick(Icons.check_circle_outline, CupertinoIcons.check_mark_circled);
  IconData get checkMarkCircledSolid =>
      pick(Icons.check_circle, CupertinoIcons.check_mark_circled_solid);
  IconData get clearThickCircled =>
      pick(Icons.cancel, CupertinoIcons.clear_thick_circled);
  IconData get clockSolid =>
      pick(Icons.watch_later, CupertinoIcons.clock_solid);
  IconData get collectionsSolid =>
      pick(Icons.collections, CupertinoIcons.collections_solid);
  IconData get downArrow =>
      pick(Icons.arrow_downward, CupertinoIcons.down_arrow);
  IconData get edit => pick(Icons.edit, CupertinoIcons.pencil);
  IconData get ellipsis => pick(Icons.more_vert, CupertinoIcons.ellipsis);
  IconData get error =>
      pick(Icons.error, CupertinoIcons.exclamationmark_circle_fill);
  IconData get favoriteOutline =>
      pick(Icons.favorite_border, CupertinoIcons.heart);
  IconData get favoriteSolid => pick(Icons.favorite, CupertinoIcons.heart_fill);
  IconData get folderSolid => pick(Icons.folder, CupertinoIcons.folder_fill);
  IconData get forward => pick(Icons.arrow_forward, CupertinoIcons.forward);
  IconData get groupSolid => pick(Icons.group, CupertinoIcons.group_solid);
  IconData get helpOutline =>
      pick(Icons.help_outline, CupertinoIcons.question_circle);
  IconData get info => pick(Icons.info_outline, CupertinoIcons.info);
  IconData get micSolid => pick(Icons.mic, CupertinoIcons.mic_fill);
  IconData get personAddSolid =>
      pick(Icons.person_add, CupertinoIcons.person_add_solid);
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
  IconData get tagSolid => pick(Icons.sell, CupertinoIcons.tag_fill);
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
