import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:discuz_flutter/JsonResult/CheckResult.dart';
import 'package:discuz_flutter/JsonResult/SupportDiscuzListResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/client/UtilityServiceApiClient.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:discuz_flutter/widget/ErrorCard.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:form_validator/form_validator.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../entity/DiscuzError.dart';
import '../utility/AppPlatformIcons.dart';
import '../utility/URLUtils.dart';

class AddDiscuzPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
        iosContentBottomPadding: true,
        iosContentPadding: true,
        appBar: PlatformAppBar(
          title: Text(S.of(context).addDiscuzTitle),
        ),
        body: AddDiscuzForumFieldStatefulWidget());
  }
}

class AddDiscuzForumFieldStatefulWidget extends StatefulWidget {
  AddDiscuzForumFieldStatefulWidget({Key? key}) : super(key: key);
  @override
  _AddDiscuzFormFieldState createState() {
    return _AddDiscuzFormFieldState();
  }
}

class _AddDiscuzFormFieldState
    extends State<AddDiscuzForumFieldStatefulWidget> {
  final _formKey = GlobalKey<FormState>();
  CheckResult? _checkResult;
  DiscuzError? error = null;
  bool _isLoading = false;
  final TextEditingController _urlController =
      new TextEditingController(text: "https://");
  SupportDiscuzListResult supportDiscuzListResult = SupportDiscuzListResult();

  bool _reportDiscuzResultToAnalytics = true;

  @override
  void initState() {
    super.initState();
    _loadSuggestionDiscuzList();
  }

  Future<void> _loadSuggestionDiscuzList() async {
    // load cache first
    String cacheString =
        await UserPreferencesUtils.getSupportDiscuzListResultCacheJson();

    try {
      Map<String, dynamic> cacheJson = jsonDecode(cacheString);
      SupportDiscuzListResult _supportDiscuzListResult =
          SupportDiscuzListResult.fromJson(cacheJson);
      setState(() {
        supportDiscuzListResult = _supportDiscuzListResult;
      });
    } catch (e, s) {}

    final dio = Dio();
    final client =
        UtilityServiceApiClient(dio, baseUrl: 'https://discuzhub.kidozh.com');
    client.getAllSuggestedDiscuzList().then((string) {
      Map<String, dynamic> supportDiscuzListResultJson = jsonDecode(string);
      try {
        SupportDiscuzListResult _supportDiscuzListResult =
            SupportDiscuzListResult.fromJson(supportDiscuzListResultJson);
        setState(() {
          supportDiscuzListResult = _supportDiscuzListResult;
        });
        // then cache it
        UserPreferencesUtils.putSupportDiscuzListResultCacheJson(string);
      } catch (e, s) {}
    });
  }

  Future<void> _saveDiscuzInDb(Discuz discuz) async {
    final dao = await AppDatabase.getDiscuzDao();
    int insertId = await dao.insertDiscuz(discuz);
    if (dao.getDiscuzByIndex(insertId) != null) {
      discuz = dao.getDiscuzByIndex(insertId)!;
    }

    Provider.of<DiscuzAndUserNotifier>(context, listen: false)
        .setDiscuz(discuz);
    Provider.of<DiscuzAndUserNotifier>(context, listen: false).setUser(null);
    // pop the activity
    if (_reportDiscuzResultToAnalytics) {
      log("Send Discuz report to Google analytics");
      await FirebaseAnalytics.instance.logEvent(
        name: "discuz_add",
        parameters: {
          "url": discuz.host,
          "sitename": discuz.siteName,
          "full_result": discuz.toString()
        },
      );
      await FirebaseAnalytics.instance
          .logSelectContent(contentType: "discuz", itemId: discuz.host);
    }

    EasyLoading.showToast(S.of(context).addDiscuzSuccessfully(discuz.siteName));
    Navigator.pop(context);
  }

  void _checkApiAvailable() {
    String discuzUrl = _urlController.text;
    log("Recv url " + discuzUrl);
    // check the availability
    final dio = Dio();
    final client = MobileApiClient(dio, baseUrl: discuzUrl);
    setState(() {
      _isLoading = true;
    });
    client.getCheckResultInString().then((value) {
      setState(() {
        _isLoading = false;
      });
      log(value.toString());
      // convert string to json
      Map<String, dynamic> checkResultJson = jsonDecode(value);
      CheckResult checkResult = CheckResult.fromJson(checkResultJson);
      log(checkResult.toString());
      setState(() {
        _checkResult = _checkResult;
        error = null;
      });
      _saveDiscuzInDb(checkResult.toDiscuz(discuzUrl));
    }).catchError((onError) {
      VibrationUtils.vibrateErrorIfPossible();
      setState(() {
        _isLoading = false;
      });
      if (onError is DioException) {
        //log("GET ADD discuz error ${onError}");
        DioException dioError = onError;
        error = DiscuzError(dioError.type.name,
            dioError.message == null ? S.of(context).error : dioError.message!,
            dioError: dioError);
      } else {
        //log("GET ADD discuz error NOT in DIO ${onError}");
        setState(() {
          error = DiscuzError("", onError.toString());
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 32),
      child: SingleChildScrollView(
          child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // input fields
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: isCupertino(context)
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).disabledColor.withOpacity(0.1))
                  : null,
              child: PlatformTextFormField(
                controller: _urlController,
                onFieldSubmitted: (text) {
                  if (_formKey.currentState!.validate()) {
                    EasyLoading.showToast(
                        S.of(context).connectServerWhenAdding);
                    _checkApiAvailable();
                  } else {
                    EasyLoading.showError(S.of(context).incorrectDiscuzAddress);
                  }
                },
                hintText: S.of(context).discuzServerAddressHint,
                material: (context, platform) {
                  return MaterialTextFormFieldData(
                    decoration: InputDecoration(
                      labelText: S.of(context).discuzServerAddress,
                      hintText: S.of(context).discuzServerAddressHint,
                      helperText: S.of(context).discuzServerAddressHelperText,
                      //prefixIcon: Icon(Icons.web),
                    ),
                  );
                },
                cupertino: (context, platform) {
                  return CupertinoTextFormFieldData(
                      //prefix: Text(S.of(context).discuzServerAddress),
                      decoration: BoxDecoration());
                },
                validator: ValidationBuilder().required().url().build(),
              ),
            ),

            if (error != null)
              Column(
                children: [
                  ErrorCard(
                    error!,
                    () {
                      _checkApiAvailable();
                    },
                    largeSize: false,
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                ],
              ),
            // SizedBox(height: 32.0,),

            Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: Row(children: [
                  Expanded(
                      child: RichText(
                    text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium,
                        text:
                            S.of(context).reportDiscuzApiInformationToAnalytics,
                        children: [
                          TextSpan(
                              text: " " +
                                  S.of(context).rememberPasswordInAppDetail,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  VibrationUtils.vibrateWithClickIfPossible();
                                  _showReportToAnalyticsDialog();
                                })
                        ]),
                  )),
                  SizedBox(
                    width: 8,
                  ),
                  PlatformSwitch(
                      value: _reportDiscuzResultToAnalytics,
                      activeColor: Theme.of(context).colorScheme.primary,
                      onChanged: (value) {
                        VibrationUtils.vibrateWithClickIfPossible();
                        setState(() {
                          _reportDiscuzResultToAnalytics = value;
                        });
                      })
                ])),

            SizedBox(
              width: double.infinity,
              child: PlatformElevatedButton(
                child: _isLoading
                    ? PlatformCircularProgressIndicator()
                    : Text(S.of(context).continueAdding),
                onPressed: _isLoading
                    ? null
                    : () {
                        VibrationUtils.vibrateWithClickIfPossible();
                        if (_formKey.currentState!.validate()) {
                          EasyLoading.showToast(
                              S.of(context).connectServerWhenAdding);
                          _checkApiAvailable();
                        } else {
                          EasyLoading.showError(
                              S.of(context).incorrectDiscuzAddress);
                        }
                      },
              ),
            ),
            SizedBox(
              height: 32,
            ),

            // the following things
            Container(
              margin: EdgeInsets.symmetric(horizontal: 0),
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Theme.of(context).disabledColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 8.0, bottom: 16.0),
                    child: RichText(
                      text: TextSpan(
                          style: Theme.of(context).textTheme.titleMedium,
                          text: S.of(context).addDiscuzSuggestionTitle,
                          children: [
                            TextSpan(
                                text: " " +
                                    S.of(context).addDiscuzSuggestionAnnotation,
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    VibrationUtils.vibrateWithClickIfPossible();
                                    _showSuggestionAnnotationDialog();
                                  }),
                            TextSpan(text:"\n"),
                            WidgetSpan(
                                child: Padding(
                                  padding: EdgeInsets.only(right: 4),
                                  child: Icon(
                                    Icons.verified,
                                    color: Colors.green,
                                    size: FontSize.medium.value * 1.2,
                                  ),
                                )),
                            TextSpan(
                                text:S.of(context).addDiscuzSuggestionVerifiedDiscuz,
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: FontSize.medium.value,
                                )
                            ),
                          ]),
                    ),
                  ),
                  ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: supportDiscuzListResult.list.length,
                      itemBuilder: (context, index) => Column(
                            children: [
                              PlatformListTile(
                                title: RichText(
                                    text: TextSpan(
                                        text: supportDiscuzListResult
                                            .list[index].name,
                                        style:
                                            DefaultTextStyle.of(context).style..copyWith(
                                              fontWeight: FontWeight.bold
                                            ),
                                        children: [
                                      if (supportDiscuzListResult
                                          .list[index].beian.isNotEmpty)
                                        WidgetSpan(
                                            child: Padding(
                                          padding: EdgeInsets.only(left: 4),
                                          child: Icon(
                                            Icons.verified,
                                            color: Colors.green,
                                            size: 16,
                                          ),
                                        ))
                                    ])),
                                subtitle: Text(
                                    supportDiscuzListResult.list[index].desc,
                                    maxLines: 3,
                                ),
                                leading: SizedBox(
                                  width: 64,
                                  height: 48,
                                  child: CachedNetworkImage(
                                      imageUrl: supportDiscuzListResult
                                              .list[index].icon.isEmpty
                                          ? supportDiscuzListResult
                                                  .list[index].url +
                                              "/static/image/common/logo.png"
                                          : supportDiscuzListResult
                                              .list[index].icon,
                                      fit: BoxFit.fitWidth,
                                      progressIndicatorBuilder: (context, url,
                                              downloadProgress) =>
                                          CircularProgressIndicator(
                                              value: downloadProgress.progress),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primaryContainer,
                                              borderRadius:
                                                  BorderRadius.circular(40),
                                            ),
                                            child: Icon(
                                              PlatformIcons(context).addCircled,
                                              size: 16,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimaryContainer,
                                            ),
                                          )),
                                ),
                                onTap: () {
                                  VibrationUtils.vibrateWithClickIfPossible();
                                  _urlController.text =
                                      supportDiscuzListResult.list[index].url;
                                  _checkApiAvailable();
                                },
                              ),
                              if (isCupertino(context) &&
                                  index !=
                                      supportDiscuzListResult.list.length - 1)
                                Divider()
                            ],
                          )),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: Text(S.of(context).addDiscuzSuggestionStatement,
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.fontSize)),
                  )
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }

  Future<void> _showReportToAnalyticsDialog() async {
    showPlatformModalSheet(
        context: context,
        builder: (context) => Container(
              color: Theme.of(context).colorScheme.surface,
              padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      AppPlatformIcons(context).reportInformationToUsSolid,
                      color: Theme.of(context).colorScheme.primary,
                      size: 48,
                    ),
                  ),
                  Text(S.of(context).reportDiscuzApiInformationToAnalyticsTitle,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.titleMedium?.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      )),
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                      S
                          .of(context)
                          .reportDiscuzApiInformationToAnalyticsDescription,
                      style: TextStyle(
                          color:
                              Theme.of(context).textTheme.displayLarge?.color,
                          fontWeight: FontWeight.normal)),
                  SizedBox(
                    height: 32,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: PlatformElevatedButton(
                      child: Text(S.of(context).viewPrivacyPolicy),
                      onPressed: () {
                        VibrationUtils.vibrateWithClickIfPossible();
                        URLUtils.launchURL(
                            "https://discuzhub.kidozh.com/privacy_policy/");
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                ],
              ),
            ));
  }

  Future<void> _showSuggestionAnnotationDialog() async {
    showPlatformModalSheet(
        context: context,
        builder: (context) => Container(
              color: Theme.of(context).colorScheme.surface,
              padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      AppPlatformIcons(context).recommendDiscuzToUsSolid,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 48,
                    ),
                  ),
                  Text(S.of(context).addDiscuzSuggestionDialogTitle,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.titleMedium?.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      )),
                  SizedBox(
                    height: 16,
                  ),
                  Text(S.of(context).addDiscuzSuggestionDialogDescription,
                      style: TextStyle(
                          color:
                              Theme.of(context).textTheme.displayLarge?.color,
                          fontWeight: FontWeight.normal)),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 16),
                    child: ListTile(
                      title: Text(S.of(context).addDiscuzSuggestionStatement,
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                            fontWeight: FontWeight.normal,
                            fontSize: FontSize.medium.value,
                          )),
                      leading: Icon(PlatformIcons(context).info,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer),
                    ),
                  ),
                  SizedBox(
                    height: 32,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: PlatformElevatedButton(
                      child: Text(
                          S.of(context).addDiscuzSuggestionDialogButtonTitle),
                      onPressed: () async {
                        VibrationUtils.vibrateWithClickIfPossible();
                        // URLUtils.launchURL("mailto:kidozh@gmail.com");
                        await launchUrl(Uri.parse("mailto:kidozh@gmail.com"));
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                ],
              ),
            ));
  }
}
