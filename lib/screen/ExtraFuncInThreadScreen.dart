import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:discuz_flutter/JsonResult/CheckPostResult.dart';
import 'package:discuz_flutter/client/CheveretoApiClient.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/dao/ImageAttachmentDao.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/DiscuzError.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/forum_attachment_upload.dart';
import 'package:discuz_flutter/utility/forum_error.dart';
import 'package:discuz_flutter/utility/forum_image_upload_utils.dart';
import 'package:discuz_flutter/utility/PictureBedUtils.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../entity/ImageAttachment.dart';
import '../client/ForumInteractionClient.dart';
import '../widget/ErrorCard.dart';
import '../utility/forum_composer_capabilities.dart';

typedef ForumImageUpload = ({String response, File file});

typedef StringToVoidFunc = void Function(String, String);
typedef SaveDraftAttachment = Future<void> Function(
  String name,
  Stream<List<int>> bytes,
  bool image,
);

class ExtraFuncInThreadScreen extends StatefulWidget {
  int tid = 0;
  int fid = 0;
  StringToVoidFunc onReplyWithImage;
  final StringToVoidFunc onAttachFile;
  final SaveDraftAttachment? saveDraftAttachment;
  StringToVoidFunc? onReplyWithHostedImage;
  Discuz discuz;
  bool? showHistoricalAttachment;

  ExtraFuncInThreadScreen(
    this.discuz,
    this.tid,
    this.fid, {
    required this.onReplyWithImage,
    required this.onAttachFile,
    this.saveDraftAttachment,
    this.onReplyWithHostedImage,
    this.showHistoricalAttachment,
    super.key,
  });

  @override
  ExtraFuncInThreadState createState() => ExtraFuncInThreadState();
}

class ExtraFuncInThreadState extends State<ExtraFuncInThreadScreen> {
  final ImagePicker _picker = ImagePicker();

  CheckPostResult _checkPostResult = CheckPostResult();
  DiscuzError? _discuzError;
  bool _permissionLoaded = false;
  bool _uploading = false;
  bool? get showHistoricalAttachment => widget.showHistoricalAttachment;

  int get tid => widget.tid;
  int get fid => widget.fid;
  StringToVoidFunc get onReplyWithImage => widget.onReplyWithImage;
  StringToVoidFunc? get onReplyWithHostedImage => widget.onReplyWithHostedImage;
  List<ImageAttachment> imageAttachmentList = [];
  Discuz get discuz => widget.discuz;
  Map<ChevertoPictureBed, String> chevertoPictureBedTokens = {};

  void pickImageFromGallery() => _triggerMediaAction(ImageSource.gallery);

  void takePicture() => _triggerMediaAction(ImageSource.camera);

  Future<void> pickFile() async {
    if (_uploading) return;
    final s = S.of(context);
    final account = context.read<DiscuzAndUserNotifier>();
    final user = account.userFor(discuz);
    if (user == null) {
      EasyLoading.showError(s.forumSignInRequired);
      return;
    }
    final session = account.sessionIdentity;
    bool isCurrent() => mounted && identical(session, account.sessionIdentity);
    _uploading = true;
    var showingProgress = false;
    String? error;
    DiscuzError? failure;
    try {
      final file = await FilePicker.pickFile();
      if (file == null || !isCurrent()) return;
      if (widget.saveDraftAttachment case final save?) {
        await save(file.name, file.readAsByteStream(), false);
        return;
      }
      showingProgress = true;
      await EasyLoading.show(
        status: s.uploadingAttachment,
        maskType: EasyLoadingMaskType.clear,
      );
      if (!isCurrent()) return;
      final bytes = await file.length();
      if (!isCurrent()) return;
      if (bytes == null || bytes <= 0) {
        error = s.attachmentFileUnreadable;
        return;
      }

      final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
      if (!isCurrent()) return;
      final client = MobileApiClient(dio, baseUrl: discuz.baseURL);
      final result = await client.checkPost(fid, tid > 0 ? tid : null);
      if (!isCurrent()) return;
      final permission = result.variables.allowPerm;
      final canPost = tid > 0 ? permission.allowReply : permission.allowPost;
      failure = forumResponseError(s, result);
      if (failure != null) return;
      if (result.variables.member_uid != user.uid || canPost == null) {
        error = s.postPermissionUnknown;
        return;
      }
      if (!canPost) {
        error = tid > 0 ? s.replyPermissionDenied : s.postPermissionDenied;
        return;
      }
      setState(() => _checkPostResult = result);
      final restriction = permission.validateUpload(file.name, bytes);
      if (restriction != null) {
        error = _restrictionMessage(restriction);
        return;
      }

      final response = await client.uploadAttachment(
        fid,
        user.uid,
        permission.uploadHash,
        MultipartFile.fromStream(
          file.readAsByteStream,
          bytes,
          filename: Uri.encodeComponent(file.name),
        ),
      );
      if (!isCurrent()) return;
      final upload = ForumUploadResult.parse(response);
      _loadCheckPostInfo();
      if (upload.aid case final aid?) {
        widget.onAttachFile('$aid', file.name);
      } else {
        failure = _uploadFailure(s, response, upload.errorCode);
      }
    } catch (error) {
      failure = forumRequestError(s, error, fallback: s.attachmentUploadFailed);
    } finally {
      if (showingProgress) await EasyLoading.dismiss();
      _uploading = false;
      if (isCurrent()) {
        if (failure != null) {
          await showForumActionError(context, failure);
        } else if (error != null) {
          EasyLoading.showError(error);
        }
      }
    }
  }

  void _triggerMediaAction(ImageSource source) {
    if (_uploading) return;
    if (_discuzError != null) {
      showForumActionError(context, _discuzError!);
      return;
    }
    if (!_permissionLoaded) {
      EasyLoading.showInfo(S.of(context).preparingPage);
      return;
    }
    _pickAndUpload(source);
  }

  @override
  void initState() {
    super.initState();
    _loadCheckPostInfo(useCache: true);
    _loadAllSavedImageAttachment();
    _loadCheveretoPictureBedTokens();
  }

  void _loadAllSavedImageAttachment() async {
    ImageAttachmentDao imageAttachmentDao =
        await AppDatabase.getImageAttachmentDao();
    if (!mounted) return;
    setState(() {
      imageAttachmentList = imageAttachmentDao.getFavoriteThreadList(discuz);
    });
  }

  void _loadCheveretoPictureBedTokens() async {
    Map<ChevertoPictureBed, String> tokens = {};
    for (final pictureBed in ChevertoPictureBed.values) {
      final token = await PictureBedUtils.getChevertoApiToken(pictureBed);
      if (token.trim().isNotEmpty) {
        tokens[pictureBed] = token.trim();
      }
    }
    if (!mounted) {
      return;
    }
    setState(() {
      chevertoPictureBedTokens = tokens;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_discuzError != null) {
      return ErrorCard(_discuzError!, _loadCheckPostInfo, largeSize: false);
    } else if (!_permissionLoaded) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.25,
        child: PlatformListTile(
          leading: PlatformCircularProgressIndicator(),
          title: Text(S.of(context).preparingPage),
        ),
      );
    } else {
      return Container(
        height: MediaQuery.of(context).size.height * 0.25,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                _quotaSummary(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: showHistoricalAttachment == false ? 3 : 4,
                padding: const EdgeInsets.all(4),
                children: extraFuncListWidget(),
              ),
            ),
          ],
        ),
      );
    }
  }

  String _restrictionMessage(UploadRestriction restriction) {
    final s = S.of(context);
    return switch (restriction) {
      UploadRestriction.type => s.uploadTypeDenied,
      UploadRestriction.count => s.uploadCountExhausted,
      UploadRestriction.dailySize => s.uploadDailySizeExceeded,
      UploadRestriction.fileSize => s.uploadFileSizeExceeded,
    };
  }

  String _quotaSummary() {
    final s = S.of(context);
    final permission = _checkPostResult.variables.allowPerm;
    String quota(int? value, {bool bytes = false}) {
      if (value == null) return s.uploadQuotaUnknown;
      if (value == -1) return s.uploadUnlimited;
      final remaining = value < 0 ? 0 : value;
      return bytes
          ? '${(remaining / 1024 / 1024).toStringAsFixed(1)} MB'
          : '$remaining';
    }

    final types = permission.allowUpload.limits.entries
        .where((e) => e.value == -1 || e.value > 0)
        .map(
          (e) => e.value > 0
              ? '${e.key} ≤${(e.value / 1024 / 1024).toStringAsFixed(1)} MB'
              : e.key,
        )
        .join(', ');
    return '${s.uploadQuotaLabel}: ${quota(permission.attachRemain.size, bytes: true)} / ${quota(permission.attachRemain.count)}\n${s.uploadTypesLabel}: ${types.isEmpty ? '—' : types}';
  }

  Future<void> _pickAndUpload(ImageSource source) async {
    VibrationUtils.vibrateWithClickIfPossible();
    final image = await _picker.pickImage(source: source);
    if (!mounted) return;
    if (image == null) {
      EasyLoading.showToast(S.of(context).noImagePicked);
      return;
    }
    final original = File(image.path);
    var isUploading = false;
    await showPlatformDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, updateDialog) => PlatformAlertDialog(
          title: Text(S.of(dialogContext).uploadImageToServerDialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isUploading)
                PlatformListTile(
                  leading: PlatformCircularProgressIndicator(),
                  title: Text(S.of(dialogContext).uploadingImageToServer),
                ),
              SizedBox(
                height: MediaQuery.sizeOf(dialogContext).height * 0.25,
                child: Image.file(original, fit: BoxFit.contain),
              ),
            ],
          ),
          actions: [
            PlatformDialogAction(
              child: Text(
                widget.saveDraftAttachment == null
                    ? S.of(dialogContext).uploadImageToServerDialogTitle
                    : S.of(dialogContext).addAPhoto,
              ),
              onPressed: isUploading
                  ? null
                  : () async {
                      updateDialog(() => isUploading = true);
                      if (widget.saveDraftAttachment case final save?) {
                        try {
                          await save(image.name, original.openRead(), true);
                          if (dialogContext.mounted)
                            Navigator.of(dialogContext).pop();
                        } catch (error) {
                          if (dialogContext.mounted) {
                            updateDialog(() => isUploading = false);
                            await showForumActionError(
                              dialogContext,
                              forumRequestError(S.of(dialogContext), error),
                            );
                          }
                        }
                        return;
                      }
                      final uploaded = await uploadPhotoToDiscuzServer(
                        dialogContext,
                        original,
                      );
                      if (!mounted || !dialogContext.mounted) return;
                      if (uploaded == null) {
                        updateDialog(() => isUploading = false);
                        return;
                      }
                      final aid = getAidFromDiscuzUploadResponse(
                        dialogContext,
                        uploaded.response,
                      );
                      if (aid.isEmpty) {
                        updateDialog(() => isUploading = false);
                        return;
                      }
                      var path = uploaded.file.path;
                      if (await UserPreferencesUtils.getRecordHistoryEnabled()) {
                        try {
                          final directory =
                              await getApplicationSupportDirectory();
                          final extension = uploaded.file.path.split('.').last;
                          final forumDirectory = Directory(
                            '${directory.path}/discuz-attachments/'
                            '${Uri.encodeComponent(discuz.baseURL)}',
                          );
                          await forumDirectory.create(recursive: true);
                          final cachedFile = await uploaded.file.copy(
                            '${forumDirectory.path}/$aid.$extension',
                          );
                          path = cachedFile.path;
                        } catch (error) {
                          log('Could not cache uploaded image', error: error);
                        }
                      }
                      if (!mounted || !dialogContext.mounted) return;
                      onReplyWithImage(aid, path);
                      Navigator.of(dialogContext).pop();
                    },
            ),
            ...buildCheveretoUploadActions(dialogContext, original),
            PlatformDialogAction(
              child: Text(S.of(dialogContext).cancel),
              onPressed: isUploading
                  ? null
                  : () => Navigator.of(dialogContext).pop(),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> extraFuncListWidget() {
    List<Widget> widgetList = [
      ExtraFuncBlockButton(
        PlatformIcons(context).collectionsSolid,
        S.of(context).addAPhoto,
        onPressed: pickImageFromGallery,
      ),
      ExtraFuncBlockButton(
        PlatformIcons(context).photoCameraSolid,
        S.of(context).takeAPicture,
        onPressed: takePicture,
      ),
      ExtraFuncBlockButton(
        PlatformIcons(context).attachment,
        S.of(context).selectAttachmentFile,
        onPressed: pickFile,
      ),
    ];

    // append all saved image
    if (showHistoricalAttachment == false) {
      return widgetList;
    }
    for (var imageAttachment in imageAttachmentList) {
      widgetList.add(
        InkWell(
          child: Image.file(
            File(imageAttachment.path),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Icon(PlatformIcons(context).unavailableImage),
          ),
          onTap: () async {
            VibrationUtils.vibrateWithClickIfPossible();
            // add to textfields
            onReplyWithImage(imageAttachment.aid, imageAttachment.path);
            // change with
            ImageAttachmentDao imageAttachmentDao =
                await AppDatabase.getImageAttachmentDao();
            ImageAttachment insertedIA = imageAttachment;
            insertedIA.updateAt = DateTime.now();
            imageAttachmentDao.insertImageAttachmentWithKey(
              insertedIA.key,
              insertedIA,
            );
          },
        ),
      );
    }

    return widgetList;
  }

  List<Widget> buildCheveretoUploadActions(
    BuildContext context,
    File photoFile,
  ) {
    if (onReplyWithHostedImage == null || chevertoPictureBedTokens.isEmpty) {
      return [];
    }

    return chevertoPictureBedTokens.keys.map((pictureBed) {
      return PlatformDialogAction(
        child: Text(
          "${S.of(context).uploadRawImageToServer} (${getChevertoPictureBedName(context, pictureBed)})",
        ),
        onPressed: () async {
          await uploadPhotoToCheveretoPictureBed(
            context,
            photoFile,
            pictureBed,
          );
          Navigator.of(context).pop();
        },
      );
    }).toList();
  }

  String getChevertoPictureBedName(
    BuildContext context,
    ChevertoPictureBed pictureBed,
  ) {
    switch (pictureBed) {
      case ChevertoPictureBed.imgbb:
        return S.of(context).pictureBedImgBB;
      case ChevertoPictureBed.imgloc:
        return S.of(context).pictureBedImgloc;
    }
  }

  Future<void> uploadPhotoToCheveretoPictureBed(
    BuildContext context,
    File photoFile,
    ChevertoPictureBed pictureBed,
  ) async {
    String apiToken =
        chevertoPictureBedTokens[pictureBed] ??
        await PictureBedUtils.getChevertoApiToken(pictureBed);
    apiToken = apiToken.trim();
    if (apiToken.isEmpty) {
      EasyLoading.showError(S.of(context).pictureBedNotPrepared);
      return;
    }

    try {
      EasyLoading.showInfo(S.of(context).uploadingImageToServer);
      final client = CheveretoApiClient(
        NetworkUtils.getDio(),
        baseUrl: PictureBedUtils.getChevertoApiUploadBaseUrl(pictureBed),
      );
      final result = await client.uploadImageToCheveretoByBinaryFile(
        apiToken,
        photoFile,
        sourceFieldName: PictureBedUtils.getChevertoUploadSourceFieldName(
          pictureBed,
        ),
      );
      final imageUrl = result.imageUrl;
      if (result.isSuccess && imageUrl != null && imageUrl.isNotEmpty) {
        onReplyWithHostedImage?.call(imageUrl, photoFile.path);
        EasyLoading.showSuccess(S.of(context).uploadImageSuccessfully);
      } else {
        EasyLoading.showError(
          result.errorMessage ?? S.of(context).uploadImageFailed,
        );
      }
    } catch (error) {
      if (!context.mounted) return;
      final strings = S.of(context);
      await showForumActionError(
        context,
        forumRequestError(strings, error, fallback: strings.uploadImageFailed),
      );
    }
  }

  Future<ForumImageUpload?> uploadPhotoToDiscuzServer(
    BuildContext context,
    File photoFile,
  ) async {
    DiscuzAndUserNotifier discuzAndUserNotifier =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false);
    final user = discuzAndUserNotifier.userFor(discuz);
    final session = discuzAndUserNotifier.sessionIdentity;
    bool isCurrent() =>
        mounted && identical(session, discuzAndUserNotifier.sessionIdentity);
    if (user != null) {
      if (_uploading) return null;
      _uploading = true;
      try {
        final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
        if (!isCurrent()) return null;
        final client = MobileApiClient(dio, baseUrl: discuz.baseURL);
        // Refresh quota before each upload; other devices may have consumed it.
        final permission = await client.checkPost(fid, tid > 0 ? tid : null);
        if (!isCurrent()) return null;
        final error = forumResponseError(S.of(context), permission);
        if (error != null) {
          await showForumActionError(context, error);
          return null;
        }
        setState(() => _checkPostResult = permission);
        final prepared = await prepareForumImageUpload(
          photoFile,
          permission.variables.allowPerm,
        );
        if (!isCurrent()) return null;
        if (prepared == null) {
          final restriction = permission.variables.allowPerm.validateUpload(
            photoFile.path,
            await photoFile.length(),
          );
          EasyLoading.showError(
            restriction == null
                ? S.of(context).uploadImageFailed
                : _restrictionMessage(restriction),
          );
          return null;
        }
        final uploadedString = await client.uploadImage(
          user.uid,
          permission.variables.allowPerm.uploadHash,
          prepared,
        );
        if (!isCurrent()) return null;
        _loadCheckPostInfo();
        return (response: uploadedString, file: prepared);
      } catch (error) {
        if (isCurrent() && context.mounted) {
          final strings = S.of(context);
          await showForumActionError(
            context,
            forumRequestError(
              strings,
              error,
              fallback: strings.uploadImageFailed,
            ),
          );
        }
        return null;
      } finally {
        _uploading = false;
      }
    }
    return null;
  }

  String getAidFromDiscuzUploadResponse(BuildContext context, String response) {
    final upload = ForumUploadResult.parse(response);
    if (upload.aid case final aid?) return '$aid';
    showForumActionError(
      context,
      _uploadFailure(S.of(context), response, upload.errorCode),
    );
    return '';
  }

  DiscuzError _uploadFailure(S strings, String response, int? code) {
    final serverError = ForumReply.tryServerError(response);
    if (serverError != null) return forumRequestError(strings, serverError);
    if (ForumReply.isSecurityChallenge(response)) {
      return DiscuzError(
        'forum_security_challenge',
        strings.forumSecurityChallenge,
      );
    }
    return code == null
        ? forumRequestError(strings, const FormatException())
        : DiscuzError(
            'forum_upload_$code',
            forumUploadErrorText(strings, code, strings.attachmentUploadFailed),
          );
  }

  void _loadCheckPostInfo({bool useCache = false}) async {
    DiscuzAndUserNotifier discuzAndUserNotifier =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false);
    final user = discuzAndUserNotifier.userFor(discuz);
    final session = discuzAndUserNotifier.sessionIdentity;
    bool isCurrent() =>
        mounted && identical(session, discuzAndUserNotifier.sessionIdentity);
    if (user == null) {
      if (mounted)
        setState(() {
          _permissionLoaded = true;
          _discuzError = DiscuzError(
            'login_required',
            S.of(context).postPermissionUnknown,
          );
        });
      return;
    }
    try {
      final scope = (site: discuz.siteIdentity, uid: user.uid, fid: fid);
      if (useCache) {
        final cached = await ForumComposerCapabilityCache.read(scope);
        if (!isCurrent()) return;
        if (cached != null) {
          setState(() {
            _checkPostResult = CheckPostResult()
              ..variables.allowPerm = cached.permission;
            _permissionLoaded = true;
            _discuzError = null;
          });
          return;
        }
      }
      final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
      if (!isCurrent()) return;
      final client = MobileApiClient(dio, baseUrl: discuz.baseURL);

      final value = await client.checkPost(fid, tid > 0 ? tid : null);
      if (!isCurrent()) return;
      await ForumComposerCapabilityCache.remember(scope, value);
      if (!isCurrent()) return;
      setState(() {
        _checkPostResult = value;
        _permissionLoaded = true;
        _discuzError = forumResponseError(S.of(context), value);
      });
    } catch (error) {
      if (isCurrent())
        setState(() => _discuzError = forumRequestError(S.of(context), error));
    }
  }
}

class ExtraFuncBlockButton extends StatelessWidget {
  VoidCallback onPressed;
  IconData icons;
  String text;

  ExtraFuncBlockButton(this.icons, this.text, {required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: PlatformCard(
        // comes with wechat style
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icons,
              size: 24,
              color: Theme.of(context).unselectedWidgetColor,
            ),
            SizedBox(height: 6),
            Text(text, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
      onTap: () {
        onPressed();
      },
    );
  }
}
