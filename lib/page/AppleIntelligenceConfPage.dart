import 'dart:async';
import 'dart:io';

import 'package:discuz_flutter/dao/AiRuleDao.dart';
import 'package:discuz_flutter/provider/UserPreferenceNotifierProvider.dart';
import 'package:discuz_flutter/utility/FoundationModelFrameworkUtils.dart';
import 'package:discuz_flutter/utility/AppPlatformIcons.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:foundation_models_framework/foundation_models_framework.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:provider/provider.dart';

import '../database/AppDatabase.dart';
import '../entity/AiRule.dart';
import '../generated/l10n.dart';
import 'AddAiModelRulePage.dart';

class AppleIntelligenceConfPage extends StatefulWidget {
  @override
  AppleIntelligenceConfState createState() {
    return AppleIntelligenceConfState();
  }
}

class AppleIntelligenceConfState extends State<AppleIntelligenceConfPage> {
  bool appleAiEnabled = false;
  bool aiAvailable = false;
  bool _checkingAvailability = true;
  String systemInfo = "";
  String errorCode = "";
  String errorMessage = "";
  List<AiRule> _rules = [];
  AiRuleDao? _aiRuleDao;

  GuardrailLevel _selectedGuardrailLevel = GuardrailLevel.standard;

  String _getSelectedGuardrailLevelText() {
    switch (_selectedGuardrailLevel) {
      case GuardrailLevel.strict:
        return S.of(context).appleIntelligenceGuardrailLevelStrict;
      case GuardrailLevel.standard:
        return S.of(context).appleIntelligenceGuardrailLevelStandard;
      case GuardrailLevel.permissive:
        return S.of(context).appleIntelligenceGuardrailLevelPermissive;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkAiAvailability();
    _initDatabase();
  }

  void _showGuardrailLevelDialog() {
    showPlatformModalSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 18, 8, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                S.of(context).appleIntelligenceGuardrailLevel,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              for (final option in [
                (
                  GuardrailLevel.permissive,
                  S.of(context).appleIntelligenceGuardrailLevelPermissive,
                ),
                (
                  GuardrailLevel.standard,
                  S.of(context).appleIntelligenceGuardrailLevelStandard,
                ),
                (
                  GuardrailLevel.strict,
                  S.of(context).appleIntelligenceGuardrailLevelStrict,
                ),
              ])
                PlatformListTile(
                  title: Text(option.$2),
                  trailing: option.$1 == _selectedGuardrailLevel
                      ? Icon(
                          CupertinoIcons.check_mark,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    final name = option.$1.name;
                    setState(() => _selectedGuardrailLevel = option.$1);
                    context
                        .read<UserPreferenceNotifierProvider>()
                        .setAppleIntelligenceGuardrail(name);
                    unawaited(
                      UserPreferencesUtils.putAppleIntelligenceGuardrail(name),
                    );
                    Navigator.pop(sheetContext);
                  },
                ),
              PlatformTextButton(
                onPressed: () => Navigator.pop(sheetContext),
                child: Text(S.of(context).cancel),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
        iosContentPadding: true,
        appBar: PlatformAppBar(
          title: Text(S.of(context).appleIntelligence),
          trailingActions: [
            if (appleAiEnabled)
              PlatformIconButton(
                liquidGlassSymbol: 'plus',
                icon: Icon(
                  AppPlatformIcons(context).addAiModelRule,
                  semanticLabel: S.of(context).appleIntelligenceAddRule,
                ),
                onPressed: () async {
                  VibrationUtils.vibrateWithClickIfPossible();
                  await Navigator.push<String>(
                      context,
                      platformPageRoute(
                          context: context,
                          builder: (context) => AddAiModelRulePage(null)));
                },
              )
          ],
        ),
        body: _checkingAvailability
            ? Center(
                child: PlatformLiquidGlassCard(
                  padding: const EdgeInsets.all(22),
                  borderRadius: BorderRadius.circular(24),
                  child: const PlatformCircularProgressIndicator(),
                ),
              )
            : aiAvailable
                ? PlatformAdaptiveSettingsList(
                    sections: [
                      SettingsSection(
                        tiles: [
                          SettingsTile.switchTile(
                            initialValue: aiAvailable ? appleAiEnabled : false,
                            activeSwitchColor:
                                Theme.of(context).colorScheme.primary,
                            onToggle: (value) {
                              setState(() => appleAiEnabled = value);
                              context
                                  .read<UserPreferenceNotifierProvider>()
                                  .setAppleIntelligenceEnabled(value);
                              unawaited(
                                UserPreferencesUtils
                                    .putAppleIntelligenceEnabled(value),
                              );
                            },
                            title: Text(S.of(context).appleIntelligenceEnabled),
                            description: errorMessage.isEmpty
                                ? null
                                : Text(errorMessage),
                          ),
                          if (appleAiEnabled)
                            SettingsTile.navigation(
                              title: Text(S
                                  .of(context)
                                  .appleIntelligenceGuardrailLevel),
                              value: Text(_getSelectedGuardrailLevelText()),
                              onPressed: (context) {
                                VibrationUtils.vibrateWithClickIfPossible();
                                _showGuardrailLevelDialog();
                              },
                            ),
                        ],
                      ),
                      if (appleAiEnabled && _aiRuleDao != null)
                        SettingsSection(
                          title: Text(S.of(context).appleIntelligenceRule),
                          tiles: [
                            SettingsTile.navigation(
                              title: Text(
                                  S.of(context).appleIntelligenceTranslate),
                              onPressed: (context) {
                                AiRule exampleRule = AiRule(
                                    S.of(context).appleIntelligenceTranslate,
                                    S
                                        .of(context)
                                        .appleIntelligenceInstructionExample,
                                    S
                                        .of(context)
                                        .appleIntelligencePromptExample,
                                    DateTime.now());
                                exampleRule.isExample = true;
                                Navigator.push<String>(
                                    context,
                                    platformPageRoute(
                                        context: context,
                                        builder: (context) =>
                                            AddAiModelRulePage(exampleRule)));
                              },
                            ),
                            ..._rules
                                .map((rule) => SettingsTile.navigation(
                                      title: Text(rule.name),
                                      onPressed: (context) {
                                        Navigator.push<String>(
                                            context,
                                            platformPageRoute(
                                                context: context,
                                                builder: (context) =>
                                                    AddAiModelRulePage(rule)));
                                      },
                                    ))
                                .toList(),
                          ],
                        ),
                      CustomSettingsSection(
                          child: PlatformLiquidGlassCard(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 4),
                        padding: const EdgeInsets.all(14),
                        borderRadius: BorderRadius.circular(22),
                        child: Column(
                          children: [
                            RichText(
                              text: TextSpan(children: [
                                WidgetSpan(
                                  child: Icon(
                                    PlatformIcons(context).info,
                                    color: Theme.of(context).disabledColor,
                                    size: 18,
                                  ),
                                ),
                                WidgetSpan(child: SizedBox(width: 2)),
                                TextSpan(
                                  text:
                                      S.of(context).appleIntelligenceUseNotice,
                                  style: TextStyle(
                                      color: Theme.of(context).disabledColor),
                                ),
                                WidgetSpan(
                                    child: InkWell(
                                  child: Text(
                                    " ${S.of(context).appleIntelligenceLearnMoreFromOurPost}",
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                  ),
                                  onTap: () {
                                    VibrationUtils.vibrateWithClickIfPossible();
                                    URLUtils.launchURL(
                                        "https://discuzhub.kidozh.com/zh/doc/intelligence-service/");
                                  },
                                )),
                                WidgetSpan(child: SizedBox(width: 4)),
                                WidgetSpan(
                                    child: InkWell(
                                  child: Text(
                                    " ${S.of(context).appleIntelligenceLearnMore}",
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                  ),
                                  onTap: () {
                                    VibrationUtils.vibrateWithClickIfPossible();
                                    URLUtils.launchURL(
                                        "https://www.apple.com/apple-intelligence/");
                                  },
                                )),
                              ]),
                            ),
                          ],
                        ),
                      ))
                    ],
                  )
                : appleIntelligenceNotSupportedWidget);
  }

  void _checkAiAvailability() async {
    final storedEnabled =
        await UserPreferencesUtils.getAppleIntelligenceEnabled();
    final storedGuardrail =
        await UserPreferencesUtils.getAppleIntelligenceGuardrail();
    final guardrail =
        FoundationModelFrameworkUtils.guardrailLevelFromName(storedGuardrail);
    if (Platform.isIOS || Platform.isMacOS) {
      try {
        AvailabilityResponse availabilityResponse =
            await FoundationModelFrameworkUtils.checkAvailability();
        print(
            "Ai response ${availabilityResponse.reasonCode} -> ${availabilityResponse.errorMessage}");
        if (!mounted) return;
        final effectiveEnabled =
            storedEnabled && availabilityResponse.isAvailable;
        final preferences = context.read<UserPreferenceNotifierProvider>();
        preferences.setAppleIntelligenceGuardrail(storedGuardrail);
        preferences.setAppleIntelligenceAvailability(
          availabilityResponse.isAvailable,
        );
        preferences.setAppleIntelligenceEnabled(effectiveEnabled);
        setState(() {
          aiAvailable = availabilityResponse.isAvailable;
          appleAiEnabled = effectiveEnabled;
          _selectedGuardrailLevel = guardrail;
          _checkingAvailability = false;
          systemInfo = availabilityResponse.osVersion;
          errorCode = availabilityResponse.reasonCode == null
              ? ""
              : availabilityResponse.reasonCode!;
          errorMessage = availabilityResponse.errorMessage == null
              ? ""
              : availabilityResponse.errorMessage!;
        });
      } catch (e) {
        if (!mounted) return;
        context
            .read<UserPreferenceNotifierProvider>()
            .setAppleIntelligenceAvailability(false);
        setState(() {
          aiAvailable = false;
          appleAiEnabled = false;
          _selectedGuardrailLevel = guardrail;
          _checkingAvailability = false;
          errorCode = "-1";
          errorMessage = "${e}";
        });
        print('Error checking availability: $e');
      }
    } else {
      await Future.delayed(const Duration(microseconds: 400));
      if (!mounted) return;
      context
          .read<UserPreferenceNotifierProvider>()
          .setAppleIntelligenceAvailability(false);
      setState(() {
        aiAvailable = false;
        appleAiEnabled = false;
        _selectedGuardrailLevel = guardrail;
        _checkingAvailability = false;
        errorCode = "-1";
        errorMessage =
            S.of(context).appleIntelligenceNotSupportedInThisPlatform;
      });
    }
  }

  void _initDatabase() async {
    AiRuleDao aiRuleDao = await AppDatabase.getAiRuleDao();
    setState(() {
      _aiRuleDao = aiRuleDao;
      _rules = aiRuleDao.getAllAiRuleList();
    });

    _aiRuleDao?.getAllAiRuleListStream().listen((event) {
      setState(() {
        _rules = event;
      });
    });
  }

  Widget get appleIntelligenceNotSupportedWidget => Center(
        child: PlatformLiquidGlassCard(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 32),
          borderRadius: BorderRadius.circular(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 16,
              ),
              Icon(
                PlatformIcons(context).warning,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(
                height: 24,
              ),
              Text(
                S.of(context).appleIntelligenceNotSupported,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontSize: 24),
              ),
              SizedBox(
                height: 12,
              ),
              Text("${errorMessage} (${errorCode})",
                  style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimaryContainer
                          .withAlpha(120),
                      fontSize: 16)),
              SizedBox(
                height: 24,
              ),
              SizedBox(
                width: double.infinity,
                child: PlatformElevatedButton(
                  color: Theme.of(context).colorScheme.primary,
                  child: Text(
                    S.of(context).appleIntelligenceHelp,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                  onPressed: () {
                    VibrationUtils.vibrateWithClickIfPossible();
                    URLUtils.launchURL(
                        "https://discuzhub.kidozh.com/doc/intelligence-service/");
                  },
                ),
              )
            ],
          ),
        ),
      );
}
