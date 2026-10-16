import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

import '../entity/post_signature.dart';
import '../generated/l10n.dart';
import '../provider/UserPreferenceNotifierProvider.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import '../utility/PostTextFieldUtils.dart';
import '../utility/UserPreferencesUtils.dart';
import '../utility/post_signature_service.dart';

class SelectSignatureStylePage extends StatefulWidget {
  const SelectSignatureStylePage({super.key});

  @override
  State<SelectSignatureStylePage> createState() => SelectSignatureStyleState();
}

class SelectSignatureStyleState extends State<SelectSignatureStylePage> {
  PostSignature signature = const PostSignature();
  final controller = TextEditingController();
  String preview = '';
  bool loading = true;
  int _previewRequest = 0;

  @override
  void initState() {
    super.initState();
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    final value = await UserPreferencesUtils.getSignaturePreference();
    if (!mounted) return;
    setState(() {
      signature = value;
      controller.text = value.customText;
      loading = false;
    });
    context.read<UserPreferenceNotifierProvider>().signature = value;
    _refreshPreview();
  }

  void _setSignature(PostSignature value) {
    setState(() => signature = value);
    context.read<UserPreferenceNotifierProvider>().signature = value;
    UserPreferencesUtils.putSignaturePreference(value);
    _refreshPreview();
  }

  Future<void> _refreshPreview() async {
    final request = ++_previewRequest;
    final strings = S.of(context);
    try {
      final text = await PostSignatureService.render(
        signature: signature,
        strings: strings,
        loadDeviceName: () => PostTextFieldUtils.getDeviceName(context: context),
        loadVersion: () async => (await PackageInfo.fromPlatform()).version,
      );
      if (!mounted || request != _previewRequest) return;
      setState(() => preview = text);
    } catch (_) {
      if (!mounted || request != _previewRequest) return;
      setState(() => preview = '');
    }
  }

  @override
  void dispose() {
    _previewRequest++;
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    String label(PostSignatureStyle style) => switch (style) {
      PostSignatureStyle.none => strings.noSignature,
      PostSignatureStyle.app => strings.signatureWithDisFly,
      PostSignatureStyle.appAndDevice => strings.signatureAppAndDevice,
      PostSignatureStyle.device => strings.deviceNameSignature,
      PostSignatureStyle.custom => strings.customSignature,
    };
    return PlatformScaffold(
      iosContentPadding: true,
      appBar: PlatformAppBar(title: Text(strings.signatureStyle)),
      body: loading
          ? Center(child: PlatformCircularProgressIndicator())
          : PlatformAdaptiveSettingsList(
              sections: [
                SettingsSection(
                  tiles: [
                    for (final style in PostSignatureStyle.values)
                      SettingsTile.navigation(
                        title: Text(label(style)),
                        trailing: signature.style == style
                            ? Icon(
                                PlatformIcons(context).checkMark,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : null,
                        onPressed: (_) =>
                            _setSignature(signature.withStyle(style)),
                      ),
                  ],
                ),
                if (signature.style == PostSignatureStyle.custom)
                  CustomSettingsSection(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: PlatformTextField(
                        hintText: strings.signatureHint,
                        controller: controller,
                        onChanged: (text) => _setSignature(
                          PostSignature(
                            style: PostSignatureStyle.custom,
                            customText: text,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (signature.includesDevice)
                  CustomSettingsSection(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(strings.signatureDevicePrivacy),
                    ),
                  ),
                if (signature.style != PostSignatureStyle.none)
                  CustomSettingsSection(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.signaturePreview,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(preview),
                        ],
                      ),
                    ),
                  ),
                if (signature.includesApp)
                  CustomSettingsSection(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        strings.acknowledgeAppSignatureAndAdDiminish,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
