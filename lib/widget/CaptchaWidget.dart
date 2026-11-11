import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';

class CaptchaWidget extends StatelessWidget {
  Discuz _discuz;
  User? _user;
  String captchaType;
  Dio dio;

  CaptchaWidget(
    this.dio,
    this._discuz,
    this._user,
    this.captchaType, {
    this.captchaController,
    this.checkOnMount = false,
  });

  CaptchaController? captchaController;
  final bool checkOnMount;

  @override
  Widget build(BuildContext context) {
    return CaptchaStatefulWidget(
      dio,
      _discuz,
      captchaType,
      captchaController,
      checkOnMount: checkOnMount,
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
  final bool checkOnMount;
  final Dio dio;

  const CaptchaStatefulWidget(
    this.dio,
    this.discuz,
    this.captchaType,
    this.captchaController, {
    required this.checkOnMount,
    super.key,
  });

  @override
  State<CaptchaStatefulWidget> createState() => CaptchaState();
}

class CaptchaState extends State<CaptchaStatefulWidget> {
  Uint8List? _imageBytes;
  final _textEditingController = TextEditingController();
  bool _loading = false;
  bool _loadFailed = false;
  bool _captchaRequired = false;
  int _request = 0;

  @override
  void initState() {
    super.initState();
    _textEditingController.addListener(_updateVerification);
    widget.captchaController?.addListener(_onCaptchaChanged);
    if (widget.checkOnMount ||
        widget.captchaController?.requiredByServer == true) {
      _loadCaptchaInfo();
    }
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
    final controller = widget.captchaController;
    if (controller?.value != null) return;
    if (controller?.requiredByServer == true) {
      _loadCaptchaInfo();
      return;
    }
    _request++;
    _textEditingController.clear();
    setState(() {
      _imageBytes = null;
      _loading = false;
      _loadFailed = false;
      _captchaRequired = false;
    });
  }

  Future<void> _loadCaptchaInfo() async {
    final request = ++_request;
    bool isCurrent() => mounted && request == _request;
    setState(() {
      _imageBytes = null;
      _loading = true;
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
      if (variables.secHash.isEmpty) {
        _captchaRequired = false;
        _loadFailed = widget.captchaController?.requiredByServer == true;
        return;
      }
      setState(() => _captchaRequired = true);
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
      _imageBytes = image;
    } catch (_) {
      if (isCurrent()) _loadFailed = true;
    } finally {
      if (isCurrent()) setState(() => _loading = false);
    }
  }

  Widget _reloadButton(BuildContext context) => PlatformTextButton(
    onPressed: _loadCaptchaInfo,
    child: Text(S.of(context).reloadCaptcha),
  );

  @override
  Widget build(BuildContext context) {
    final required =
        _captchaRequired || widget.captchaController?.requiredByServer == true;
    if (_loadFailed) {
      return required ? _reloadButton(context) : const SizedBox.shrink();
    }
    final image = _imageBytes;
    if (image == null) {
      if (!_loading || !required) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
        child: Row(
          children: [
            const PlatformCircularProgressIndicator(),
            const SizedBox(width: 8),
            Expanded(child: Text(S.of(context).loadingCaptchaInformation)),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: PlatformTextField(
              controller: _textEditingController,
              hintText: S.of(context).captchaRequired,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            child: Image.memory(
              image,
              errorBuilder: (context, error, stack) => _reloadButton(context),
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

  void reloadCaptcha({required bool requiredByServer}) {
    _requiredByServer = requiredByServer;
    if (value == null) {
      notifyListeners();
    } else {
      value = null;
    }
  }
}
