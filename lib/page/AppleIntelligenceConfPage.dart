import 'dart:async';
import 'dart:io';

import 'package:discuz_flutter/dao/AiRuleDao.dart';
import 'package:discuz_flutter/provider/UserPreferenceNotifierProvider.dart';
import 'package:discuz_flutter/utility/AppPlatformIcons.dart';
import 'package:discuz_flutter/utility/FoundationModelFrameworkUtils.dart';
import 'package:discuz_flutter/utility/OnDeviceAiService.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foundation_models_framework/foundation_models_framework.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

import '../database/AppDatabase.dart';
import '../entity/AiRule.dart';
import '../generated/l10n.dart';
import 'AddAiModelRulePage.dart';

class AppleIntelligenceConfPage extends StatefulWidget {
  const AppleIntelligenceConfPage({super.key});

  @override
  AppleIntelligenceConfState createState() => AppleIntelligenceConfState();
}

class AppleIntelligenceConfState extends State<AppleIntelligenceConfPage>
    with WidgetsBindingObserver {
  bool appleAiEnabled = false;
  bool _checkingAvailability = true;
  bool _startingDownload = false;
  int? _downloadedBytes;
  int? _totalBytes;
  OnDeviceAiAvailability _availability = const OnDeviceAiAvailability(
    status: OnDeviceAiAvailabilityStatus.unsupportedPlatform,
    reasonCode: 'unsupported_platform',
  );
  List<AiRule> _rules = [];
  AiRuleDao? _aiRuleDao;
  StreamSubscription<List<AiRule>>? _rulesSubscription;
  StreamSubscription<OnDeviceAiDownloadEvent>? _downloadSubscription;

  GuardrailLevel _selectedGuardrailLevel = GuardrailLevel.standard;

  bool get _isApple => OnDeviceAiService.isApplePlatform;
  bool get _isAndroid => Platform.isAndroid;
  bool get _aiAvailable => _availability.isAvailable;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (_isAndroid) {
      _downloadSubscription =
          OnDeviceAiService.downloadEvents.listen(_handleDownloadEvent);
    }
    unawaited(_checkAiAvailability());
    unawaited(_initDatabase());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _downloadSubscription?.cancel();
    _rulesSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_checkAiAvailability(showLoading: false));
    }
  }

  String _localizedAvailabilityMessage(OnDeviceAiAvailability availability) {
    final strings = S.of(context);
    switch (availability.status) {
      case OnDeviceAiAvailabilityStatus.downloadable:
        return strings.onDeviceAiModelDownloadDescription;
      case OnDeviceAiAvailabilityStatus.downloading:
        return strings.onDeviceAiDownloadingModel;
      case OnDeviceAiAvailabilityStatus.needsAICoreUpdate:
        return strings.onDeviceAiAICoreDescription;
      case OnDeviceAiAvailabilityStatus.needsSystemUpdate:
        return strings.onDeviceAiSystemUpdateDescription;
      case OnDeviceAiAvailabilityStatus.notEnoughStorage:
        return strings.onDeviceAiStorageDescription;
      case OnDeviceAiAvailabilityStatus.temporarilyUnavailable:
        return strings.onDeviceAiTemporarilyUnavailableDescription;
      case OnDeviceAiAvailabilityStatus.unsupportedPlatform:
        return strings.appleIntelligenceNotSupportedInThisPlatform;
      case OnDeviceAiAvailabilityStatus.error:
        return availability.reasonCode == 'download_failed'
            ? strings.onDeviceAiDownloadFailed
            : strings.appleIntelligenceAvailabilityCheckFailed;
      case OnDeviceAiAvailabilityStatus.unavailable:
        return switch (availability.reasonCode) {
          'device_not_eligible' =>
            strings.appleIntelligenceUnavailableDeviceNotEligible,
          'apple_intelligence_not_enabled' =>
            strings.appleIntelligenceUnavailableNotEnabled,
          'model_not_ready' =>
            strings.appleIntelligenceUnavailableModelNotReady,
          _ => strings.appleIntelligenceUnavailableUnknown,
        };
      case OnDeviceAiAvailabilityStatus.available:
        return strings.onDeviceAiReadyDescription;
    }
  }

  String _availabilityTitle() {
    final strings = S.of(context);
    return switch (_availability.status) {
      OnDeviceAiAvailabilityStatus.downloadable =>
        strings.onDeviceAiModelDownloadTitle,
      OnDeviceAiAvailabilityStatus.downloading =>
        strings.onDeviceAiDownloadingModel,
      OnDeviceAiAvailabilityStatus.needsAICoreUpdate =>
        strings.onDeviceAiAICoreTitle,
      OnDeviceAiAvailabilityStatus.needsSystemUpdate =>
        strings.onDeviceAiSystemUpdateTitle,
      OnDeviceAiAvailabilityStatus.notEnoughStorage =>
        strings.onDeviceAiStorageTitle,
      OnDeviceAiAvailabilityStatus.temporarilyUnavailable =>
        strings.onDeviceAiTemporarilyUnavailableTitle,
      OnDeviceAiAvailabilityStatus.error =>
        _availability.reasonCode == 'download_failed'
            ? strings.onDeviceAiModelDownloadTitle
            : strings.appleIntelligenceAvailabilityCheckFailed,
      _ => strings.appleIntelligenceNotSupported,
    };
  }

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
                    builder: (context) => AddAiModelRulePage(null),
                  ),
                );
              },
            ),
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
          : _aiAvailable
              ? _buildAvailableSettings()
              : _buildAvailabilityCard(),
    );
  }

  Widget _buildAvailableSettings() {
    final providerDescription = _isAndroid
        ? S.of(context).onDeviceAiProviderAndroid
        : S.of(context).onDeviceAiProviderApple;
    return PlatformAdaptiveSettingsList(
      sections: [
        SettingsSection(
          tiles: [
            SettingsTile.switchTile(
              initialValue: appleAiEnabled,
              activeSwitchColor: Theme.of(context).colorScheme.primary,
              onToggle: (value) {
                setState(() => appleAiEnabled = value);
                context
                    .read<UserPreferenceNotifierProvider>()
                    .setAppleIntelligenceEnabled(value);
                unawaited(
                  UserPreferencesUtils.putAppleIntelligenceEnabled(value),
                );
              },
              title: Text(S.of(context).appleIntelligenceEnabled),
              description: Text(
                '${S.of(context).onDeviceAiReadyDescription}\n'
                '$providerDescription',
              ),
            ),
            if (appleAiEnabled && _isApple)
              SettingsTile.navigation(
                title: Text(S.of(context).appleIntelligenceGuardrailLevel),
                value: Text(_getSelectedGuardrailLevelText()),
                onPressed: (_) {
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
                onPressed: (_) {
                  final exampleRule = AiRule(
                    S.of(context).appleIntelligenceTranslate,
                    S.of(context).appleIntelligenceInstructionExample,
                    S.of(context).appleIntelligencePromptExample,
                    DateTime.now(),
                  )..isExample = true;
                  Navigator.push<String>(
                    context,
                    platformPageRoute(
                      context: context,
                      builder: (context) => AddAiModelRulePage(exampleRule),
                    ),
                  );
                },
              ),
              ..._rules.map(
                (rule) => SettingsTile.navigation(
                  title: Text(rule.name),
                  onPressed: (_) {
                    Navigator.push<String>(
                      context,
                      platformPageRoute(
                        context: context,
                        builder: (context) => AddAiModelRulePage(rule),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        CustomSettingsSection(child: _buildNoticeCard()),
      ],
    );
  }

  Widget _buildNoticeCard() {
    return PlatformLiquidGlassCard(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      padding: const EdgeInsets.all(14),
      borderRadius: BorderRadius.circular(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                PlatformIcons(context).info,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 18,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  S.of(context).appleIntelligenceUseNotice,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 2,
            children: [
              _buildInlineLink(
                label: S.of(context).appleIntelligenceLearnMoreFromOurPost,
                onTap: () => URLUtils.launchURL(
                  'https://discuzhub.kidozh.com/zh/doc/intelligence-service/',
                ),
              ),
              _buildInlineLink(
                label: S.of(context).appleIntelligenceLearnMore,
                onTap: () => URLUtils.launchURL(
                  _isAndroid
                      ? 'https://developers.google.com/ml-kit/genai/prompt/android/get-started'
                      : 'https://www.apple.com/apple-intelligence/',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInlineLink({
    required String label,
    required VoidCallback onTap,
  }) {
    final color = Theme.of(context).colorScheme.primary;
    return Semantics(
      link: true,
      label: label,
      excludeSemantics: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvailabilityCard() {
    final status = _availability.status;
    final isDownloading =
        status == OnDeviceAiAvailabilityStatus.downloading || _startingDownload;
    final progress =
        _downloadedBytes != null && _totalBytes != null && _totalBytes! > 0
            ? (_downloadedBytes! / _totalBytes!).clamp(0.0, 1.0)
            : null;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: PlatformLiquidGlassCard(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 32),
          borderRadius: BorderRadius.circular(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isDownloading
                    ? PlatformIcons(context).download
                    : PlatformIcons(context).warning,
                size: 36,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Text(
                _availabilityTitle(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(
                _localizedAvailabilityMessage(_availability),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              if (isDownloading) ...[
                const SizedBox(height: 22),
                LinearProgressIndicator(value: progress),
                if (_downloadedBytes != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    S.of(context).onDeviceAiDownloadProgress(
                          (_downloadedBytes! / (1024 * 1024))
                              .toStringAsFixed(1),
                        ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: PlatformElevatedButton(
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: _startingDownload ? null : _primaryStatusAction,
                  child: Text(
                    _primaryStatusActionLabel(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              PlatformTextButton(
                onPressed: () => URLUtils.launchURL(
                  'https://discuzhub.kidozh.com/zh/doc/intelligence-service/',
                ),
                child: Text(S.of(context).appleIntelligenceHelp),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _primaryStatusActionLabel() {
    if (_startingDownload ||
        _availability.status == OnDeviceAiAvailabilityStatus.downloading) {
      return S.of(context).onDeviceAiRetry;
    }
    return switch (_availability.status) {
      OnDeviceAiAvailabilityStatus.downloadable =>
        S.of(context).onDeviceAiDownloadModel,
      OnDeviceAiAvailabilityStatus.needsAICoreUpdate =>
        S.of(context).onDeviceAiOpenGooglePlay,
      _ => S.of(context).onDeviceAiRetry,
    };
  }

  void _primaryStatusAction() {
    VibrationUtils.vibrateWithClickIfPossible();
    switch (_availability.status) {
      case OnDeviceAiAvailabilityStatus.downloadable:
        unawaited(_downloadModel());
        return;
      case OnDeviceAiAvailabilityStatus.needsAICoreUpdate:
        unawaited(
          URLUtils.launchURL(
            'https://play.google.com/store/apps/details?id=com.google.android.aicore',
          ),
        );
        return;
      default:
        unawaited(_checkAiAvailability());
        return;
    }
  }

  Future<void> _downloadModel() async {
    setState(() {
      _startingDownload = true;
      _downloadedBytes = null;
      _totalBytes = null;
      _availability = const OnDeviceAiAvailability(
        status: OnDeviceAiAvailabilityStatus.downloading,
        reasonCode: 'model_downloading',
        platform: 'android',
      );
    });
    context
        .read<UserPreferenceNotifierProvider>()
        .setOnDeviceAiAvailability(_availability);
    try {
      await OnDeviceAiService.downloadModel();
    } on OnDeviceAiException catch (error) {
      if (!mounted) return;
      final availability = OnDeviceAiAvailability(
        status: _statusForReasonCode(error.code),
        reasonCode: error.code,
        errorMessage: error.message,
        nativeCode: error.nativeCode,
        platform: 'android',
      );
      _applyAvailability(availability, enabled: false);
    } finally {
      if (mounted) setState(() => _startingDownload = false);
    }
  }

  void _handleDownloadEvent(OnDeviceAiDownloadEvent event) {
    if (!mounted) return;
    switch (event.state) {
      case OnDeviceAiDownloadState.started:
        setState(() {
          _startingDownload = false;
          _totalBytes = event.totalBytes;
        });
        return;
      case OnDeviceAiDownloadState.progress:
        setState(() => _downloadedBytes = event.downloadedBytes);
        return;
      case OnDeviceAiDownloadState.completed:
        setState(() => _startingDownload = false);
        unawaited(_checkAiAvailability(showLoading: false));
        return;
      case OnDeviceAiDownloadState.failed:
        final availability = OnDeviceAiAvailability(
          status: _statusForReasonCode(event.reasonCode),
          reasonCode: event.reasonCode ?? 'download_failed',
          errorMessage: event.errorMessage,
          nativeCode: event.nativeCode,
          platform: 'android',
        );
        _applyAvailability(availability, enabled: false);
        return;
    }
  }

  OnDeviceAiAvailabilityStatus _statusForReasonCode(String? reasonCode) {
    return switch (reasonCode) {
      'aicore_incompatible' => OnDeviceAiAvailabilityStatus.needsAICoreUpdate,
      'needs_system_update' => OnDeviceAiAvailabilityStatus.needsSystemUpdate,
      'not_enough_disk_space' => OnDeviceAiAvailabilityStatus.notEnoughStorage,
      'service_busy' ||
      'battery_quota_exceeded' ||
      'background_use_blocked' =>
        OnDeviceAiAvailabilityStatus.temporarilyUnavailable,
      _ => OnDeviceAiAvailabilityStatus.error,
    };
  }

  Future<void> _checkAiAvailability({bool showLoading = true}) async {
    if (showLoading && mounted) {
      setState(() => _checkingAvailability = true);
    }
    final storedEnabled =
        await UserPreferencesUtils.getAppleIntelligenceEnabled();
    final storedGuardrail =
        await UserPreferencesUtils.getAppleIntelligenceGuardrail();
    final guardrail =
        FoundationModelFrameworkUtils.guardrailLevelFromName(storedGuardrail);
    final availability = await OnDeviceAiService.checkAvailability();
    if (!mounted) return;
    final effectiveEnabled = storedEnabled && availability.isAvailable;
    _selectedGuardrailLevel = guardrail;
    context
        .read<UserPreferenceNotifierProvider>()
        .setAppleIntelligenceGuardrail(storedGuardrail);
    _applyAvailability(availability, enabled: effectiveEnabled);
  }

  void _applyAvailability(
    OnDeviceAiAvailability availability, {
    required bool enabled,
  }) {
    if (!mounted) return;
    final preferences = context.read<UserPreferenceNotifierProvider>();
    preferences.setOnDeviceAiAvailability(availability);
    preferences.setAppleIntelligenceEnabled(enabled);
    setState(() {
      _availability = availability;
      appleAiEnabled = enabled;
      _checkingAvailability = false;
      if (!availability.isDownloading) {
        _startingDownload = false;
      }
    });
  }

  Future<void> _initDatabase() async {
    final aiRuleDao = await AppDatabase.getAiRuleDao();
    if (!mounted) return;
    setState(() {
      _aiRuleDao = aiRuleDao;
      _rules = aiRuleDao.getAllAiRuleList();
    });
    _rulesSubscription = aiRuleDao.getAllAiRuleListStream().listen((rules) {
      if (mounted) setState(() => _rules = rules);
    });
  }
}
