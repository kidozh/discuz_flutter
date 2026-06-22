import 'package:dio/dio.dart';
import 'package:discuz_flutter/JsonResult/ChevertoUploadResult.dart';
import 'package:discuz_flutter/client/CheveretoApiClient.dart';
import 'package:discuz_flutter/utility/PictureBedUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:settings_ui/settings_ui.dart';

import '../generated/l10n.dart';
import '../utility/URLUtils.dart';
import '../utility/VibrationUtils.dart';

class ConfigureChevertoPage extends StatefulWidget {
  final ChevertoPictureBed chevertoPictureBed;

  const ConfigureChevertoPage(this.chevertoPictureBed, {super.key});

  @override
  State<StatefulWidget> createState() {
    return ConfigureChevertoState();
  }
}

class ConfigureChevertoState extends State<ConfigureChevertoPage> {
  static const String _testImageBase64 =
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/p9sAAAAASUVORK5CYII=';

  TextEditingController controller = TextEditingController();
  bool _isTesting = false;

  ChevertoPictureBed get chevertoPictureBed => widget.chevertoPictureBed;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // query for the state
    _loadToken();
    loadUrlInfo();
  }

  void _loadToken() async {
    String token =
        await PictureBedUtils.getChevertoApiToken(chevertoPictureBed);
    controller.text = token;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  String termsOfUseUrl = "";
  String privacyPolicyUrl = "";

  void loadUrlInfo() {
    switch (chevertoPictureBed) {
      case ChevertoPictureBed.imgbb:
        {
          termsOfUseUrl = "https://imgbb.com/tos";
          privacyPolicyUrl = "https://imgbb.com/privacy";
        }
      case ChevertoPictureBed.imgloc:
        {
          termsOfUseUrl = "https://imgloc.com/page/tos";
          privacyPolicyUrl = "https://imgloc.com/page/privacy";
        }
    }
  }

  String getChevertoTitle() {
    switch (chevertoPictureBed) {
      case ChevertoPictureBed.imgbb:
        return S.of(context).pictureBedImgBB;
      case ChevertoPictureBed.imgloc:
        return S.of(context).pictureBedImgloc;
    }
  }

  Future<void> _testAndSaveToken() async {
    VibrationUtils.vibrateWithClickIfPossible();
    final localizations = S.of(context);
    final emptyTokenText = localizations.pictureBedApiKeyEmpty;
    final testingTokenText = localizations.pictureBedTestingApi;
    final savedAfterTestText = localizations.pictureBedTestPassedAndSaved;
    final testingTokenFailedText = localizations.pictureBedTestFailed;
    final token = controller.text.trim();
    if (token.isEmpty) {
      EasyLoading.showError(emptyTokenText);
      return;
    }

    setState(() {
      _isTesting = true;
    });
    EasyLoading.show(status: testingTokenText);

    try {
      final dio = Dio();
      final client = CheveretoApiClient(
        dio,
        baseUrl:
            PictureBedUtils.getChevertoApiUploadBaseUrl(chevertoPictureBed),
      );
      final result = await client.uploadImageToCheveretoByBase64(
        token,
        _testImageBase64,
        sourceFieldName: PictureBedUtils.getChevertoUploadSourceFieldName(
            chevertoPictureBed),
      );

      if (!result.isSuccess || (result.imageUrl ?? '').isEmpty) {
        EasyLoading.showError(result.errorMessage ?? testingTokenFailedText);
        return;
      }

      await _tryDeleteTestImage(dio, result);
      await PictureBedUtils.setChevertoApiToken(chevertoPictureBed, token);
      EasyLoading.showSuccess(savedAfterTestText);
    } on DioException catch (error) {
      EasyLoading.showError(_formatDioError(error));
    } catch (error) {
      EasyLoading.showError(error.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isTesting = false;
        });
      }
    }
  }

  Future<void> _tryDeleteTestImage(
      Dio dio, ChevertoUploadResult uploadResult) async {
    final deleteUrl = uploadResult.image?.deleteUrl;
    if (deleteUrl == null || deleteUrl.isEmpty) {
      return;
    }

    try {
      await dio.get<dynamic>(
        deleteUrl,
        options: Options(validateStatus: (_) => true),
      );
    } catch (_) {
      // Cleaning up the test upload is best-effort and should not block saving.
    }
  }

  String _formatDioError(DioException error) {
    final responseData = error.response?.data;
    if (responseData != null) {
      return responseData.toString();
    }
    return error.message ?? error.type.name;
  }

  Widget _buildApiKeyGuide(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: theme.disabledColor.withValues(alpha: 0.08),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).cheveretoApiSetupGuideTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            S.of(context).cheveretoApiSetupGuide,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.disabledColor,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(getChevertoTitle()),
      ),
      body: SafeArea(
        child: SettingsList(
          sections: [
            CustomSettingsSection(
                child: Padding(
                    padding: isCupertino(context)
                        ? EdgeInsets.symmetric(vertical: 4, horizontal: 16)
                        : EdgeInsets.zero,
                    child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        decoration: isCupertino(context)
                            ? BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Theme.of(context)
                                    .disabledColor
                                    .withValues(alpha: 0.1))
                            : null,
                        child: Padding(
                          padding: isCupertino(context)
                              ? EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 6)
                              : EdgeInsets.zero,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              PlatformTextFormField(
                                controller: controller,
                                hintText: S.of(context).cheveretoApiKey,
                                material: (context, platform) {
                                  return MaterialTextFormFieldData(
                                    decoration: InputDecoration(
                                        labelText:
                                            S.of(context).cheveretoApiKey,
                                        prefixIcon: Icon(Icons.vpn_key),
                                        labelStyle: TextStyle(
                                            color: Theme.of(context)
                                                .disabledColor)),
                                  );
                                },
                                cupertino: (context, platform) {
                                  return CupertinoTextFormFieldData(
                                      prefix: Text(
                                          S.of(context).cheveretoApiKey,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .disabledColor)),
                                      decoration: BoxDecoration());
                                },
                              ),
                              Text(
                                S.of(context).cheveretoApiDescription,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        color: Theme.of(context).disabledColor),
                              ),
                              const SizedBox(height: 12),
                              _buildApiKeyGuide(context),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: PlatformElevatedButton(
                                  onPressed:
                                      _isTesting ? null : _testAndSaveToken,
                                  child: _isTesting
                                      ? SizedBox(
                                          width: 18,
                                          height: 18,
                                          child:
                                              PlatformCircularProgressIndicator(),
                                        )
                                      : Text(
                                          S.of(context).pictureBedTestAndSave),
                                ),
                              ),
                            ],
                          ),
                        )))),
            SettingsSection(
                title: Text(S.of(context).legalInformation),
                tiles: [
                  SettingsTile.navigation(
                    title: Text(S.of(context).termsOfService),
                    onPressed: (context) {
                      VibrationUtils.vibrateWithClickIfPossible();
                      URLUtils.launchURL(termsOfUseUrl);
                    },
                  ),
                  SettingsTile.navigation(
                    title: Text(S.of(context).privacyPolicy),
                    onPressed: (context) {
                      VibrationUtils.vibrateWithClickIfPossible();
                      URLUtils.launchURL(privacyPolicyUrl);
                    },
                  )
                ]),
          ],
        ),
      ),
    );
  }
}
