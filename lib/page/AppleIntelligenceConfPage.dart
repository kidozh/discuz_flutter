import 'dart:async';
import 'dart:io';

import 'package:discuz_flutter/dao/AiRuleDao.dart';
import 'package:discuz_flutter/utility/AppPlatformIcons.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:foundation_models_framework/foundation_models_framework.dart';
import 'package:settings_ui/settings_ui.dart';

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
    showPlatformDialog(
      context: context,
      builder: (dialogContext) => PlatformAlertDialog(
        title: Text(S.of(context).appleIntelligenceGuardrailLevel),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              PlatformListTile(
                title: Text(
                    S.of(context).appleIntelligenceGuardrailLevelPermissive),
                leading: Radio<GuardrailLevel>.adaptive(
                  value: GuardrailLevel.permissive,
                  groupValue: _selectedGuardrailLevel,
                  onChanged: (GuardrailLevel? value) {
                    if (value != null) {
                      setState(() {
                        _selectedGuardrailLevel = value;
                      });
                    }
                    Navigator.pop(dialogContext);
                  },
                ),
                onTap: () {
                  setState(() {
                    _selectedGuardrailLevel = GuardrailLevel.permissive;
                  });
                  Navigator.pop(dialogContext);
                },
              ),
              PlatformListTile(
                title:
                    Text(S.of(context).appleIntelligenceGuardrailLevelStandard),
                leading: Radio<GuardrailLevel>.adaptive(
                  value: GuardrailLevel.standard,
                  groupValue: _selectedGuardrailLevel,
                  onChanged: (GuardrailLevel? value) {
                    if (value != null) {
                      setState(() {
                        _selectedGuardrailLevel = value;
                      });
                    }
                    Navigator.pop(dialogContext);
                  },
                ),
                onTap: () {
                  setState(() {
                    _selectedGuardrailLevel = GuardrailLevel.standard;
                  });
                  Navigator.pop(dialogContext);
                },
              ),
              PlatformListTile(
                title:
                    Text(S.of(context).appleIntelligenceGuardrailLevelStrict),
                leading: Radio<GuardrailLevel>.adaptive(
                  value: GuardrailLevel.strict,
                  groupValue: _selectedGuardrailLevel,
                  onChanged: (GuardrailLevel? value) {
                    if (value != null) {
                      setState(() {
                        _selectedGuardrailLevel = value;
                      });
                    }
                    Navigator.pop(dialogContext);
                  },
                ),
                onTap: () {
                  setState(() {
                    _selectedGuardrailLevel = GuardrailLevel.strict;
                  });
                  Navigator.pop(dialogContext);
                },
              )
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
            if (aiAvailable)
              PlatformIconButton(
                icon: Icon(AppPlatformIcons(context).addAiModelRule),
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
        body: aiAvailable
            ? SettingsList(
                sections: [
                  SettingsSection(
                    tiles: [
                      SettingsTile.switchTile(
                        initialValue: aiAvailable ? appleAiEnabled : false,
                        activeSwitchColor:
                            Theme.of(context).colorScheme.primary,
                        onToggle: (value) {
                          setState(() {
                            appleAiEnabled = value;
                          });
                        },
                        title: Text(S.of(context).appleIntelligenceEnabled),
                        description:
                            errorMessage.isEmpty ? null : Text(errorMessage),
                      ),
                      if (appleAiEnabled)
                        SettingsTile.navigation(
                          title: Text(
                              S.of(context).appleIntelligenceGuardrailLevel),
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
                          title: Text(S.of(context).appleIntelligenceTranslate),
                          onPressed: (context) {
                            AiRule exampleRule = AiRule(
                                S.of(context).appleIntelligenceTranslate,
                                S
                                    .of(context)
                                    .appleIntelligenceInstructionExample,
                                S.of(context).appleIntelligencePromptExample,
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
                      child: Container(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Column(
                      children: [
                        RichText(
                          text: TextSpan(children: [
                            WidgetSpan(
                              child: Icon(
                                Icons.info_outline,
                                color: Theme.of(context).disabledColor,
                                size: 18,
                              ),
                            ),
                            WidgetSpan(child: SizedBox(width: 2)),
                            TextSpan(
                              text: S.of(context).appleIntelligenceUseNotice,
                              style: TextStyle(
                                  color: Theme.of(context).disabledColor),
                            ),
                            WidgetSpan(
                                child: InkWell(
                              child: Text(
                                " ${S.of(context).appleIntelligenceLearnMoreFromOurPost}",
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary),
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
                                    color:
                                        Theme.of(context).colorScheme.primary),
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
    if (Platform.isIOS || Platform.isMacOS) {
      final foundationModels = FoundationModelsFramework.instance;

      try {
        AvailabilityResponse availabilityResponse =
            await foundationModels.checkAvailability();
        print(
            "Ai response ${availabilityResponse.reasonCode} -> ${availabilityResponse.errorMessage}");
        setState(() {
          aiAvailable = availabilityResponse.isAvailable;
          systemInfo = availabilityResponse.osVersion;
          errorCode = availabilityResponse.reasonCode == null
              ? ""
              : availabilityResponse.reasonCode!;
          errorMessage = availabilityResponse.errorMessage == null
              ? ""
              : availabilityResponse.errorMessage!;
        });
      } catch (e) {
        setState(() {
          errorCode = "-1";
          errorMessage = "${e}";
        });
        print('Error checking availability: $e');
      }
    } else {
      await Future.delayed(const Duration(microseconds: 400));
      setState(() {
        aiAvailable = false;
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

  Widget get appleIntelligenceNotSupportedWidget => Container(
        width: double.infinity,
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer),
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(vertical: 32, horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 16,
              ),
              Icon(
                Icons.security_update_warning,
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
