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
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/PictureBedUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../entity/ImageAttachment.dart';

typedef StringToVoidFunc = void Function(String, String);

class ExtraFuncInThreadScreen extends StatefulWidget {
  int tid = 0;
  int fid = 0;
  StringToVoidFunc onReplyWithImage;
  StringToVoidFunc? onReplyWithHostedImage;
  Discuz discuz;
  bool? showHistoricalAttachment;

  ExtraFuncInThreadScreen(
    this.discuz,
    this.tid,
    this.fid, {
    required this.onReplyWithImage,
    this.onReplyWithHostedImage,
    this.showHistoricalAttachment,
    super.key,
  });

  @override
  ExtraFuncInThreadState createState() {
    return ExtraFuncInThreadState(
      this.discuz,
      this.tid,
      this.fid,
      this.onReplyWithImage,
      this.onReplyWithHostedImage,
      this.showHistoricalAttachment,
    );
  }
}

class ExtraFuncInThreadState extends State<ExtraFuncInThreadScreen> {
  final ImagePicker _picker = ImagePicker();

  CheckPostResult _checkPostResult = CheckPostResult();
  DiscuzError? _discuzError;
  bool _permissionLoaded = false;
  bool _uploading = false;
  bool? showHistoricalAttachment;

  int tid = 0;
  int fid = 0;
  StringToVoidFunc onReplyWithImage;
  StringToVoidFunc? onReplyWithHostedImage;
  List<ImageAttachment> imageAttachmentList = [];
  Discuz discuz;
  Map<ChevertoPictureBed, String> chevertoPictureBedTokens = {};

  ExtraFuncInThreadState(
    this.discuz,
    this.tid,
    this.fid,
    this.onReplyWithImage,
    this.onReplyWithHostedImage,
    this.showHistoricalAttachment,
  );

  void pickImageFromGallery() => _triggerMediaAction(0);

  void takePicture() => _triggerMediaAction(1);

  void _triggerMediaAction(int index) {
    if (_discuzError != null) {
      EasyLoading.showError(_discuzError!.content);
      return;
    }
    if (!_permissionLoaded) {
      EasyLoading.showInfo(S.of(context).preparingPage);
      return;
    }
    final actions = extraFuncListWidget();
    if (index >= actions.length) return;
    final action = actions[index];
    if (action is ExtraFuncBlockButton) action.onPressed();
  }

  @override
  void initState() {
    super.initState();
    _loadCheckPostInfo();
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
      return Container(
        height: MediaQuery.of(context).size.height * 0.25,
        child: PlatformListTile(
          leading: Icon(PlatformIcons(context).errorOutline, color: Colors.red),
          title: Text(_discuzError!.content),
        ),
      );
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
                crossAxisCount: 4,
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
    String quota(int? value, {bool bytes = false}) => value == null
        ? s.uploadQuotaUnknown
        : value < 0
        ? s.uploadUnlimited
        : bytes
        ? '${(value / 1024 / 1024).toStringAsFixed(1)} MB'
        : '$value';
    final types = permission.allowUpload.limits.entries
        .where((e) => e.value != 0)
        .map(
          (e) => e.value > 0
              ? '${e.key} ≤${(e.value / 1024 / 1024).toStringAsFixed(1)} MB'
              : e.key,
        )
        .join(', ');
    return '${s.uploadQuotaLabel}: ${quota(permission.attachRemain.size, bytes: true)} / ${quota(permission.attachRemain.count)}\n${s.uploadTypesLabel}: ${types.isEmpty ? '—' : types}';
  }

  List<Widget> extraFuncListWidget() {
    List<Widget> widgetList = [
      ExtraFuncBlockButton(
        PlatformIcons(context).collectionsSolid,
        S.of(context).addAPhoto,
        onPressed: () async {
          // recv the photo from gallery
          VibrationUtils.vibrateWithClickIfPossible();
          final XFile? image = await _picker.pickImage(
            source: ImageSource.gallery,
          );

          // then upload to the server
          if (image != null) {
            File file = File(image.path);
            // check with the size
            int file_size = await file.length();
            bool file_not_exceeding_size =
                _checkPostResult.variables.allowPerm.validateUpload(
                  file.path,
                  file_size,
                ) ==
                null;
            log(
              "Get file size ${file_size} <-> ${_checkPostResult.variables.allowPerm.attachRemain.size} HASH ${_checkPostResult.variables.allowPerm.uploadHash}",
            );
            // confirm with user
            showPlatformDialog(
              context: context,
              builder: (context) {
                bool isUploadingPicture = false;
                return PlatformAlertDialog(
                  title: Text(S.of(context).uploadImageToServerDialogTitle),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isUploadingPicture)
                        PlatformListTile(
                          leading: PlatformCircularProgressIndicator(),
                          title: Text(S.of(context).uploadingImageToServer),
                        ),
                      if (!file_not_exceeding_size)
                        Container(
                          child: Container(
                            color: Theme.of(context).colorScheme.primary,
                            child: SizedBox(
                              width: double.infinity,
                              child: Text(
                                _restrictionMessage(
                                  _checkPostResult.variables.allowPerm
                                      .validateUpload(file.path, file_size)!,
                                ),
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  fontSize: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.fontSize,
                                ),
                              ),
                            ),
                          ),
                          padding: EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      Image.file(File(file.path)),
                    ],
                  ),
                  actions: [
                    PlatformDialogAction(
                      child: Text(S.of(context).uploadCompressedImageToServer),
                      onPressed: () async {
                        setState(() {
                          isUploadingPicture = true;
                        });
                        EasyLoading.showInfo(
                          S.of(context).uploadingImageToServer,
                        );
                        // compress it first
                        // get a temp directory

                        Directory directory =
                            await getApplicationDocumentsDirectory();
                        final compressionPath =
                            '${directory.path}/discuz-upload-${DateTime.now().microsecondsSinceEpoch}.jpg';
                        // with 90% compression
                        final compressedFile =
                            await FlutterImageCompress.compressAndGetFile(
                              file.path,
                              compressionPath,
                            );
                        if (compressedFile != null) {
                          file = File(compressedFile.path);
                        }

                        String respString = await uploadPhotoToDiscuzServer(
                          context,
                          File(file.path),
                        );
                        setState(() {
                          isUploadingPicture = false;
                        });
                        print("Successful upload image string ${respString}");
                        String aid = getAidFromDiscuzUploadResponse(
                          context,
                          respString,
                        );
                        if (aid.isNotEmpty) {
                          // send it with aid
                          onReplyWithImage(aid, file.path);
                        }
                        Navigator.of(context).pop();
                      },
                    ),
                    if (file_not_exceeding_size)
                      PlatformDialogAction(
                        child: Text(S.of(context).uploadRawImageToServer),
                        onPressed: () async {
                          setState(() {
                            isUploadingPicture = true;
                          });
                          EasyLoading.showInfo(
                            S.of(context).uploadingImageToServer,
                          );
                          String respString = await uploadPhotoToDiscuzServer(
                            context,
                            File(file.path),
                          );
                          setState(() {
                            isUploadingPicture = false;
                          });
                          print("Successful upload image string ${respString}");
                          String aid = getAidFromDiscuzUploadResponse(
                            context,
                            respString,
                          );
                          if (aid.isNotEmpty) {
                            // send it with aid
                            onReplyWithImage(aid, file.path);
                          }
                          Navigator.of(context).pop();
                        },
                      ),
                    ...buildCheveretoUploadActions(context, file),
                    PlatformDialogAction(
                      child: Text(S.of(context).cancel),
                      onPressed: () async {
                        // cancel it
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          } else {
            EasyLoading.showToast(S.of(context).noImagePicked);
          }
        },
      ),
      ExtraFuncBlockButton(
        PlatformIcons(context).photoCameraSolid,
        S.of(context).takeAPicture,
        onPressed: () async {
          final XFile? image = await _picker.pickImage(
            source: ImageSource.camera,
          );
          if (image != null) {
            File file = File(image.path);
            int file_size = await file.length();
            bool file_not_exceeding_size =
                _checkPostResult.variables.allowPerm.validateUpload(
                  file.path,
                  file_size,
                ) ==
                null;

            showPlatformDialog(
              context: context,
              builder: (context) {
                bool isUploadingPicture = false;
                return PlatformAlertDialog(
                  title: Text(S.of(context).uploadImageToServerDialogTitle),
                  content: Column(
                    children: [
                      if (isUploadingPicture)
                        PlatformListTile(
                          leading: PlatformCircularProgressIndicator(),
                          title: Text(S.of(context).uploadingImageToServer),
                        ),
                      Image.file(file),
                    ],
                  ),
                  actions: [
                    PlatformDialogAction(
                      child: Text(S.of(context).uploadCompressedImageToServer),
                      onPressed: () async {
                        setState(() {
                          isUploadingPicture = true;
                        });
                        EasyLoading.showInfo(
                          S.of(context).uploadingImageToServer,
                        );
                        // compress it first
                        // get a temp directory

                        Directory directory =
                            await getApplicationDocumentsDirectory();

                        final compressionPath =
                            '${directory.path}/discuz-upload-${DateTime.now().microsecondsSinceEpoch}.jpg';
                        // with 90% compression
                        final compressedFile =
                            await FlutterImageCompress.compressAndGetFile(
                              file.path,
                              compressionPath,
                            );
                        if (compressedFile != null) {
                          file = File(compressedFile.path);
                        }
                        String respString = await uploadPhotoToDiscuzServer(
                          context,
                          file,
                        );
                        setState(() {
                          isUploadingPicture = false;
                        });
                        print("Successful upload image string ${respString}");
                        String aid = getAidFromDiscuzUploadResponse(
                          context,
                          respString,
                        );
                        if (aid.isNotEmpty) {
                          // send it with aid
                          onReplyWithImage(aid, file.path);
                        }
                        Navigator.of(context).pop();
                      },
                    ),
                    if (file_not_exceeding_size)
                      PlatformDialogAction(
                        child: Text(S.of(context).uploadRawImageToServer),
                        onPressed: () async {
                          setState(() {
                            isUploadingPicture = true;
                          });
                          EasyLoading.showInfo(
                            S.of(context).uploadingImageToServer,
                          );
                          String respString = await uploadPhotoToDiscuzServer(
                            context,
                            file,
                          );
                          setState(() {
                            isUploadingPicture = false;
                          });
                          print("Successful upload image string ${respString}");
                          String aid = getAidFromDiscuzUploadResponse(
                            context,
                            respString,
                          );
                          if (aid.isNotEmpty) {
                            // send it with aid
                            onReplyWithImage(aid, file.path);
                          }
                          Navigator.of(context).pop();
                        },
                      ),
                    ...buildCheveretoUploadActions(context, file),
                    PlatformDialogAction(
                      child: Text(S.of(context).cancel),
                      onPressed: () async {
                        // cancel it
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          } else {
            EasyLoading.showToast(S.of(context).noImagePicked);
          }
        },
      ),
      // comes with inserted attachment
    ];

    // append all saved image
    if (showHistoricalAttachment == false) {
      return widgetList;
    }
    for (var imageAttachment in imageAttachmentList) {
      widgetList.add(
        InkWell(
          child: Image.file(File(imageAttachment.path)),
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
    } on DioException catch (e) {
      EasyLoading.showError(e.message ?? S.of(context).uploadImageFailed);
    } catch (e) {
      EasyLoading.showError(S.of(context).uploadImageFailed);
    }
  }

  Future<String> uploadPhotoToDiscuzServer(
    BuildContext context,
    File photoFile,
  ) async {
    DiscuzAndUserNotifier discuzAndUserNotifier =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false);
    if (discuzAndUserNotifier.discuz == null ||
        discuzAndUserNotifier.user == null ||
        _checkPostResult.variables.allowPerm.uploadHash.isEmpty) {
      return "";
    } else {
      Discuz discuz = discuzAndUserNotifier.discuz!;
      User user = discuzAndUserNotifier.user!;
      final dio = await NetworkUtils.getDioWithPersistCookieJar(
        discuzAndUserNotifier.user,
      );
      final client = MobileApiClient(dio, baseUrl: discuz.baseURL);

      if (_uploading) return '';
      _uploading = true;
      try {
        // Refresh quota before each upload; other devices may have consumed it.
        final permission = await client.checkPost(fid, tid > 0 ? tid : null);
        if (!mounted) return '';
        final error = permission.getErrorString();
        if (error != null) {
          EasyLoading.showError(error);
          return '';
        }
        setState(() => _checkPostResult = permission);
        final restriction = permission.variables.allowPerm.validateUpload(
          photoFile.path,
          await photoFile.length(),
        );
        if (!mounted) return '';
        if (restriction != null) {
          EasyLoading.showError(_restrictionMessage(restriction));
          return '';
        }
        final uploadedString = await client.uploadImage(
          user.uid,
          permission.variables.allowPerm.uploadHash,
          photoFile,
        );
        if (mounted) _loadCheckPostInfo();
        return uploadedString;
      } catch (_) {
        if (mounted) EasyLoading.showError(S.of(context).uploadImageFailed);
        return '';
      } finally {
        _uploading = false;
      }
    }
  }

  String getAidFromDiscuzUploadResponse(
    BuildContext context,
    String respString,
  ) {
    if (respString.isEmpty) return '';
    // like DISCUZUPLOAD|0|8|1|0
    // or DISCUZUPLOAD|0|9|1|0
    // or DISCUZUPLOAD|0|10|1|0
    // or in keylol DISCUZUPLOAD|0|1475238|1|0
    try {
      int code = int.parse(respString);
      switch (code) {
        case -1:
          {
            EasyLoading.showError(S.of(context).uploadImageError1);
            return "";
          }
        case -2:
          {
            EasyLoading.showError(S.of(context).uploadImageError2);
            return "";
          }
        case -3:
          {
            EasyLoading.showError(S.of(context).uploadImageError3);
            return "";
          }
        case -4:
          {
            EasyLoading.showError(S.of(context).uploadImageError4);
            return "";
          }
        case -5:
          {
            EasyLoading.showError(S.of(context).uploadImageError5);
            return "";
          }
        case -6:
          {
            EasyLoading.showError(S.of(context).uploadImageError6);
            return "";
          }
        case -7:
          {
            EasyLoading.showError(S.of(context).uploadImageError7);
            return "";
          }
        case -8:
          {
            EasyLoading.showError(S.of(context).uploadImageError8);
            return "";
          }
        case -9:
          {
            EasyLoading.showError(S.of(context).uploadImageError9);
            return "";
          }
        case -10:
          {
            EasyLoading.showError(S.of(context).uploadImageError10);
            return "";
          }
        case -11:
          {
            EasyLoading.showError(S.of(context).uploadImageError11);
            return "";
          }
      }
      if (code > 0) {
        return respString;
      } else {
        return "";
      }
    } catch (e) {
      print("response ${respString} is not a integer");
    }
    ;

    List<String> splitedVariables = respString.split("|");
    if (splitedVariables.length == 5 &&
        splitedVariables[0] == "DISCUZUPLOAD" &&
        splitedVariables[1] == "0") {
      // a sucessful submit, return the aid
      return splitedVariables[2];
    } else if (splitedVariables.length > 1) {
      // a further error
      if (splitedVariables[1] != "0") {
        // need to trigger the warning
        switch (splitedVariables[1]) {
          case "-1":
            {
              EasyLoading.showError(S.of(context).uploadImageErrorNegative1);
              return "";
            }
          case "1":
            {
              EasyLoading.showError(S.of(context).uploadImageError1);
              return "";
            }
          case "2":
            {
              EasyLoading.showError(S.of(context).uploadImageError2);
              return "";
            }
          case "3":
            {
              EasyLoading.showError(S.of(context).uploadImageError3);
              return "";
            }
          case "4":
            {
              EasyLoading.showError(S.of(context).uploadImageError4);
              return "";
            }
          case "5":
            {
              EasyLoading.showError(S.of(context).uploadImageError5);
              return "";
            }
          case "6":
            {
              EasyLoading.showError(S.of(context).uploadImageError6);
              return "";
            }
          case "7":
            {
              EasyLoading.showError(S.of(context).uploadImageError7);
              return "";
            }
          case "8":
            {
              EasyLoading.showError(S.of(context).uploadImageError8);
              return "";
            }
          case "9":
            {
              EasyLoading.showError(S.of(context).uploadImageError9);
              return "";
            }
          case "10":
            {
              EasyLoading.showError(S.of(context).uploadImageError10);
              return "";
            }
          case "11":
            {
              EasyLoading.showError(S.of(context).uploadImageError11);
              return "";
            }
        }
      }
    }
    EasyLoading.showError(S.of(context).uploadImageUnknownError);
    return "";
  }

  void _loadCheckPostInfo() async {
    DiscuzAndUserNotifier discuzAndUserNotifier =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false);
    print(
      "load check post func by ${discuzAndUserNotifier.discuz} User: ${discuzAndUserNotifier.user}",
    );
    if (discuzAndUserNotifier.discuz == null ||
        discuzAndUserNotifier.user == null) {
      if (mounted)
        setState(() {
          _permissionLoaded = true;
          _discuzError = DiscuzError(
            'login_required',
            S.of(context).postPermissionUnknown,
          );
        });
      return;
    } else {
      Discuz discuz = discuzAndUserNotifier.discuz!;
      User user = discuzAndUserNotifier.user!;
      final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
      final client = MobileApiClient(dio, baseUrl: discuz.baseURL);

      client
          .checkPost(fid, tid > 0 ? tid : null)
          .then((value) {
            if (!mounted) return;
            print("Did get the value ${value}");
            setState(() {
              _checkPostResult = value;
              _permissionLoaded = true;
              _discuzError = value.getErrorString() == null
                  ? null
                  : DiscuzError('checkpost', value.getErrorString()!);
            });
          })
          .catchError((e, s) {
            if (!mounted) return;
            print("${e} ${s}");
            setState(() {
              _discuzError = DiscuzError(
                "network_fail",
                S.of(context).networkFail,
              );
            });
          });
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
