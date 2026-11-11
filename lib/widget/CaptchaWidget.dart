import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:discuz_flutter/JsonResult/CaptchaResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/AppPlatformIcons.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';

class CaptchaWidget extends StatelessWidget {
  Discuz _discuz;
  User? _user;
  String captchaType;
  Dio dio;
  bool? showProgress;

  CaptchaWidget(
    this.dio,
    this._discuz,
    this._user,
    this.captchaType, {
    this.captchaController,
    this.showProgress,
    this.hideUnconfirmedFailure = false,
  });

  CaptchaController? captchaController;
  final bool hideUnconfirmedFailure;

  @override
  Widget build(BuildContext context) {
    return CaptchaStatefulWidget(
      dio,
      _discuz,
      captchaType,
      captchaController,
      showProgress,
      hideUnconfirmedFailure: hideUnconfirmedFailure,
      key: ValueKey((
        dio,
        _discuz.baseURL,
        _user?.uid,
        captchaType,
        captchaController,
      )),
    );
  }
}

class CaptchaStatefulWidget extends StatefulWidget {
  final Discuz discuz;
  final String captchaType;
  final CaptchaController? captchaController;
  final bool? showProgress;
  final bool hideUnconfirmedFailure;
  final Dio dio;

  const CaptchaStatefulWidget(
    this.dio,
    this.discuz,
    this.captchaType,
    this.captchaController,
    this.showProgress, {
    this.hideUnconfirmedFailure = false,
    super.key,
  });

  @override
  State<CaptchaStatefulWidget> createState() => CaptchaState();
}

class CaptchaState extends State<CaptchaStatefulWidget> {
  CaptchaVariable? captchaVariable;
  Uint8List? imageByte;
  final _textEditingController = TextEditingController();
  bool loaded = false;
  bool _loadFailed = false;
  bool _captchaRequired = false;
  int _request = 0;

  @override
  void initState() {
    super.initState();
    _textEditingController.addListener(_updateVerification);
    widget.captchaController?.addListener(_onCaptchaChanged);
    _loadCaptchaInfo();
  }

  @override
  void dispose() {
    widget.captchaController?.removeListener(_onCaptchaChanged);
    _textEditingController.dispose();
    super.dispose();
  }

  void _updateVerification() {
    final controller = widget.captchaController;
    final fields = controller?.value;
    if (fields == null) return;
    controller!.value = CaptchaFields(
      fields.captchaFormHash,
      fields.fieldType,
      _textEditingController.text,
    );
  }

  void _onCaptchaChanged() {
    if (widget.captchaController?.value == null) _loadCaptchaInfo();
  }

  Future<void> _loadCaptchaInfo() async {
    final request = ++_request;
    bool isCurrent() => mounted && request == _request;
    setState(() {
      captchaVariable = null;
      imageByte = null;
      loaded = false;
      _loadFailed = false;
    });
    _textEditingController.clear();
    widget.captchaController?.value = CaptchaFields('', widget.captchaType, '');
    final dio = widget.dio;
    final baseUrl = widget.discuz.getBaseURLWithAfterfix();
    final type = widget.captchaType;
    try {
      final value = await MobileApiClient(
        dio,
        baseUrl: widget.discuz.baseURL,
      ).captchaResult(type);
      if (!isCurrent()) return;
      final variables = value.variables;
      if (value.getErrorString() != null && variables.secHash.isEmpty) {
        throw StateError(value.getErrorString()!);
      }
      _captchaRequired = variables.secHash.isNotEmpty;
      if (variables.secHash.isEmpty) {
        if (widget.captchaController?.requiredByServer == true) {
          setState(() => _loadFailed = true);
        }
        return;
      }
      final uri = Uri.parse('${baseUrl}api/mobile/index.php').replace(
        queryParameters: {
          'module': 'seccode',
          'sechash': variables.secHash,
          'version': '4',
          'type': type,
        },
      );
      final response = await dio.getUri<Uint8List>(
        uri,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Referer': variables.secCodeURL},
        ),
      );
      if (!isCurrent()) return;
      final image = response.data;
      if (image == null || image.isEmpty) {
        throw StateError('Empty captcha image');
      }
      widget.captchaController?.value = CaptchaFields(
        variables.secHash,
        type,
        '',
      );
      setState(() {
        captchaVariable = variables;
        imageByte = image;
      });
    } catch (_) {
      if (isCurrent()) setState(() => _loadFailed = true);
    } finally {
      if (isCurrent()) setState(() => loaded = true);
    }
  }

  Widget _reloadButton(BuildContext context) => PlatformTextButton(
    onPressed: _loadCaptchaInfo,
    child: Text(S.of(context).reloadCaptcha),
  );

  @override
  Widget build(BuildContext context) {
    if (_loadFailed) {
      if (widget.hideUnconfirmedFailure &&
          !_captchaRequired &&
          widget.captchaController?.requiredByServer != true) {
        return const SizedBox.shrink();
      }
      return _reloadButton(context);
    }
    if (captchaVariable == null) {
      // an empty container
      if (widget.showProgress == true) {
        if (loaded == false) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
            child: Row(
              children: [
                PlatformCircularProgressIndicator(),
                Expanded(child: Text(S.of(context).loadingCaptchaInformation)),
              ],
            ),
          );
        } else {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
            child: Row(
              children: [
                Icon(
                  AppPlatformIcons(context).checkCircleSolid,
                  color: Colors.green,
                ),
                Expanded(child: Text(S.of(context).noCaptachaRequired)),
              ],
            ),
          );
        }
      } else {
        return Container(width: 0, height: 0);
      }
    } else {
      return Padding(
        padding: EdgeInsets.all(4.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: PlatformTextField(
                controller: _textEditingController,
                hintText: S.of(context).captchaRequired,
              ),
            ),
            SizedBox(width: 8.0),
            if (imageByte != null)
              GestureDetector(
                child: Image.memory(
                  imageByte!,
                  errorBuilder: (context, error, stack) =>
                      _reloadButton(context),
                ),
                onTap: () {
                  VibrationUtils.vibrateWithClickIfPossible();
                  _loadCaptchaInfo();
                },
              ),
          ],
        ),
      );
    }
  }
}

class CaptchaFields {
  String captchaFormHash = "";
  String fieldType = "";
  String verification = "";

  CaptchaFields(this.captchaFormHash, this.fieldType, this.verification);
}

class CaptchaController extends ValueNotifier<CaptchaFields?> {
  CaptchaController(CaptchaFields value) : super(value);

  bool _requiredByServer = false;
  bool get requiredByServer => _requiredByServer;

  void reloadCaptcha({bool? requiredByServer}) {
    _requiredByServer = requiredByServer ?? _requiredByServer;
    if (value == null) {
      notifyListeners();
    } else {
      value = null;
    }
  }
}
