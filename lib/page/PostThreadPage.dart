import 'package:dio/dio.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/screen/SmileyListScreen.dart';
import 'package:discuz_flutter/utility/AppPlatformIcons.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:discuz_flutter/widget/CaptchaWidget.dart';
import 'package:discuz_flutter/widget/PostTextField.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:provider/provider.dart';

import '../JsonResult/DisplayForumResult.dart';
import '../dao/DraftDao.dart';
import '../dao/ImageAttachmentDao.dart';
import '../database/AppDatabase.dart';
import '../entity/Discuz.dart';
import '../entity/Draft.dart';
import '../entity/ImageAttachment.dart';
import '../entity/Smiley.dart';
import '../entity/User.dart';
import '../generated/l10n.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../screen/ExtraFuncInThreadScreen.dart';
import '../utility/NetworkUtils.dart';
import '../utility/PostTextFieldUtils.dart';
import '../utility/UserPreferencesUtils.dart';

class PostThreadPage extends StatelessWidget {
  int fid;
  int tid;
  Discuz discuz;
  Draft? draft;

  PostThreadPage(this.discuz, this.fid, this.tid, {this.draft});

  @override
  Widget build(BuildContext context) {
    return PostThreadStatefulWidget(this.discuz, this.fid, this.tid,
        draft: draft);
  }
}

class PostThreadStatefulWidget extends StatefulWidget {
  int fid;
  Discuz discuz;
  int tid;
  Draft? draft;

  PostThreadStatefulWidget(this.discuz, this.fid, this.tid, {this.draft});

  @override
  PostThreadState createState() {
    return PostThreadState(this.discuz, this.fid, this.tid, draft: draft);
  }
}

class PostThreadState extends State<PostThreadStatefulWidget> {
  Discuz discuz;
  int fid;
  int tid;
  TextEditingController _controller = TextEditingController();
  TextEditingController _titleEditingController = TextEditingController();
  CaptchaController captchaController =
      CaptchaController(new CaptchaFields("", "post", ""));
  FocusNode focusNode = FocusNode();
  List<String> insertedAidList = [];
  Draft? draft;
  // dropdown menu status
  String? selectedTypeId;

  PostThreadState(this.discuz, this.fid, this.tid, {this.draft});

  @override
  void initState() {
    super.initState();
    _loadForumInfo();
    // add backup option
    backupDraftIfPossible();
  }

  @override
  Widget build(BuildContext context) {
    if (_displayForumResult == null) {
      return Container(
        width: 64,
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: PlatformCircularProgressIndicator(),
            ),
            SizedBox(
              height: 32,
            ),
            Text(S.of(context).loadingForumInformation)
          ],
        ),
      );
    }

    return PlatformScaffold(
      iosContentBottomPadding: true,
      iosContentPadding: true,
      appBar: PlatformAppBar(
        title: Text(S.of(context).pushThreadTitle),
        trailingActions: [
          PlatformIconButton(
            liquidGlassSymbol: 'paperplane',
            icon: Icon(
              AppPlatformIcons(context).postThreadSolid,
              size: 20,
              semanticLabel: S.of(context).pushThreadTitle,
            ),
            onPressed: () async {
              VibrationUtils.vibrateWithClickIfPossible();
              await _launchCaptchaDialog(context);
            },
          )
        ],
      ),
      body: PlatformLiquidGlassPageBackdrop(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_threadTypeEntries.isNotEmpty) ...[
                      Builder(
                        builder: (buttonContext) {
                          final button = PlatformTextButton(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            onPressed: _showThreadTypePicker,
                            child: Row(
                              children: [
                                Icon(
                                  PlatformIcons(context).tagSolid,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _selectedThreadTypeLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  PlatformIcons(context).downArrow,
                                  size: 14,
                                ),
                              ],
                            ),
                          );
                          if (usesAppleTranslucentSurface(buttonContext) &&
                              !usesLiquidGlass(buttonContext)) {
                            return PlatformLiquidGlassCard(
                              borderRadius: BorderRadius.circular(22),
                              child: button,
                            );
                          }
                          return button;
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                    PlatformTextField(
                      controller: _titleEditingController,
                      textInputAction: TextInputAction.next,
                      hintText: S.of(context).pushThreadTitle,
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: Padding(
                padding: EdgeInsets.all(4.0),
                child: PostTextField(
                  discuz,
                  _controller,
                  focusNode: focusNode,
                  expanded: true,
                ),
              )),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: PlatformLiquidGlassToolbarGroup(
                      children: [
                        PlatformIconButton(
                          icon: Icon(Icons.format_bold_outlined),
                          onPressed: () {
                            VibrationUtils.vibrateWithClickIfPossible();
                            String insertedText = "[b][/b]";
                            insertString(insertedText);
                          },
                        ),
                        PlatformIconButton(
                          icon: Icon(Icons.format_italic_outlined),
                          onPressed: () {
                            VibrationUtils.vibrateWithClickIfPossible();
                            String insertedText = "[i][/i]";
                            insertString(insertedText);
                          },
                        ),
                        PlatformIconButton(
                          icon: Icon(Icons.format_quote_outlined),
                          onPressed: () {
                            VibrationUtils.vibrateWithClickIfPossible();
                            String insertedText = "[quote][/quote]";
                            insertString(insertedText);
                          },
                        ),
                        PlatformIconButton(
                          icon: Icon(Icons.emoji_emotions_outlined),
                          onPressed: () {
                            VibrationUtils.vibrateWithClickIfPossible();
                            // popup a smiley dialog
                            showPlatformModalSheet(
                                context: context,
                                builder: (context) => SmileyListScreen((p0) {
                                      insertSmiley(p0);
                                    }));
                          },
                        ),
                        PlatformIconButton(
                          icon: Icon(Icons.image_outlined),
                          onPressed: () {
                            VibrationUtils.vibrateWithClickIfPossible();
                            showPlatformModalSheet(
                                context: context,
                                builder: (context) => ExtraFuncInThreadScreen(
                                      discuz,
                                      tid,
                                      fid,
                                      onReplyWithImage: (aid, path) async {
                                        // fill with text first
                                        // refresh the layout
                                        // insertedAidList.clear();
                                        if (aid.isNotEmpty) {
                                          String insertedAidString =
                                              "[attachimg]${aid}[/attachimg]";
                                          insertString(insertedAidString);
                                          // add aid to list
                                          insertedAidList.add(aid);
                                          // add to historical attachment
                                          bool savedInDatabase =
                                              await UserPreferencesUtils
                                                  .getRecordHistoryEnabled();
                                          if (savedInDatabase) {
                                            // save it to database
                                            ImageAttachmentDao
                                                imageAttachmentDao =
                                                await AppDatabase
                                                    .getImageAttachmentDao();
                                            ImageAttachment? imageAttachment =
                                                imageAttachmentDao
                                                    .findImageAttachmentByDiscuzAndAid(
                                                        discuz, aid);
                                            if (imageAttachment != null) {
                                              imageAttachment.updateAt =
                                                  DateTime.now();
                                              imageAttachmentDao
                                                  .insertImageAttachmentWithKey(
                                                      imageAttachment.key,
                                                      imageAttachment);
                                            } else {
                                              imageAttachmentDao
                                                  .insertImageAttachment(
                                                      ImageAttachment(
                                                          aid, discuz, path));
                                            }
                                          }
                                        } else {}
                                      },
                                      onReplyWithHostedImage: (imageUrl, path) {
                                        if (imageUrl.isNotEmpty) {
                                          insertString("[img]$imageUrl[/img]");
                                        }
                                      },
                                      showHistoricalAttachment: false,
                                    ));
                          },
                        ),
                        // PlatformIconButton(
                        //   icon: Icon(Icons.settings_backup_restore),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  DisplayForumResult? _displayForumResult = null;

  Future<void> _loadForumInfo() async {
    User? user =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
    Dio dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    MobileApiClient client = MobileApiClient(dio, baseUrl: discuz.baseURL);
    // fetch the information soon
    client.displayForumResult(fid.toString(), 0, {}).then((value) {
      setState(() {
        _displayForumResult = value;
      });
    });
  }

  List<MapEntry<String, String>> get _threadTypeEntries =>
      _displayForumResult?.discuzIndexVariables.threadType?.idNameMap.entries
          .map((entry) => MapEntry(entry.key, entry.value.toString()))
          .toList() ??
      const <MapEntry<String, String>>[];

  String get _selectedThreadTypeLabel {
    for (final entry in _threadTypeEntries) {
      if (entry.key == selectedTypeId) return entry.value;
    }
    return S.of(context).forumFilterTypeIdTitle;
  }

  Future<void> _showThreadTypePicker() async {
    final entries = _threadTypeEntries;
    if (entries.isEmpty) return;
    VibrationUtils.vibrateWithClickIfPossible();
    final selected = await showPlatformModalSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.62,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
                child: Text(
                  S.of(context).forumFilterTypeIdTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(bottom: 8),
                  children: [
                    for (final entry in entries)
                      PlatformListTile(
                        contentPadding: const EdgeInsets.fromLTRB(18, 8, 14, 8),
                        title: Text(
                          entry.value,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: selectedTypeId == entry.key
                            ? Icon(
                                PlatformIcons(sheetContext).checkMark,
                                color:
                                    Theme.of(sheetContext).colorScheme.primary,
                                size: 18,
                              )
                            : null,
                        onTap: () => Navigator.pop(sheetContext, entry.key),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (selected != null && mounted) {
      setState(() => selectedTypeId = selected);
    }
  }

  // utilities
  void insertSmiley(Smiley smiley) {
    print("Smiley is pressed ${smiley.code} ${smiley.relativePath}");

    final TextSelection selection = _controller.selection.copyWith();
    final int start = selection.baseOffset;
    int end = selection.extentOffset;

    final TextEditingValue value = _controller.value;

    String smileyCode =
        "${SmileyText.smileyStartFlag}${smiley.toString()}${SmileyText.smileyEndFlag}";
    final text = smileyCode;
    if (selection.isValid) {
      String newText = "";
      if (value.selection.isCollapsed) {
        if (end > 0) {
          newText += value.text.substring(0, end);
        }
        newText += text;
        if (value.text.length > end) {
          newText += value.text.substring(end, value.text.length);
        }
      } else {
        newText = value.text.replaceRange(start, end, text);
        end = start;
      }
      _controller.value = value.copyWith(
          text: newText,
          selection: selection.copyWith(
              baseOffset: end + text.length, extentOffset: end + text.length));
    } else {
      String newText = "";
      newText = _controller.text + text;
      _controller.value = TextEditingValue(
          text: newText,
          selection:
              TextSelection.fromPosition(TextPosition(offset: newText.length)));
    }
  }

  void insertString(String string) {
    final TextSelection selection = _controller.selection.copyWith();
    final int start = selection.baseOffset;
    int end = selection.extentOffset;

    final TextEditingValue value = _controller.value;

    final text = string;
    if (selection.isValid) {
      String newText = "";
      if (value.selection.isCollapsed) {
        if (end > 0) {
          newText += value.text.substring(0, end);
        }
        newText += text;
        if (value.text.length > end) {
          newText += value.text.substring(end, value.text.length);
        }
      } else {
        newText = value.text.replaceRange(start, end, text);
        end = start;
      }
      _controller.value = value.copyWith(
          text: newText,
          selection: selection.copyWith(
              baseOffset: end + text.length, extentOffset: end + text.length));
    } else {
      String newText = "";
      newText = _controller.text + text;
      _controller.value = TextEditingValue(
          text: newText,
          selection:
              TextSelection.fromPosition(TextPosition(offset: newText.length)));
    }
  }

  void backupDraftIfPossible() {
    if (draft == null) {
      // shall create a new one
      _titleEditingController.addListener(() {
        backupDraft();
      });

      _controller.addListener(() {
        backupDraft();
      });
    }
  }

  Future<void> backupDraft() async {
    // start to collect edittext
    String title = _titleEditingController.text;
    String content = _titleEditingController.text;

    if (draft == null) {
      draft = Draft(
          title,
          content,
          fid,
          selectedTypeId == null ? "" : selectedTypeId!,
          DateTime.now(),
          discuz);
    }

    // start to save it
    DraftDao draftDao = await AppDatabase.getDraftDao();
    draft = await draftDao.insertDraftAndReturnInsertObj(draft!);
  }

  Future<void> _launchCaptchaDialog(BuildContext context) async {
    User? user =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
    Dio dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    // MobileApiClient client = MobileApiClient(dio, baseUrl: discuz.baseURL);

    showPlatformDialog(
        context: context,
        builder: (context) {
          return PlatformAlertDialog(
            title: Text(S.of(context).pushThreadTitle),
            content: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CaptchaWidget(
                    dio,
                    discuz,
                    user,
                    "post",
                    captchaController: captchaController,
                    showProgress: true,
                  ),
                ],
              ),
            ),
            actions: [
              PlatformDialogAction(
                child: Text(S.of(context).send),
                onPressed: () {
                  VibrationUtils.vibrateWithClickIfPossible();
                  postThread();
                  Navigator.of(context).pop();
                },
              ),
              PlatformDialogAction(
                child: Text(S.of(context).cancel),
                onPressed: () {
                  VibrationUtils.vibrateWithClickIfPossible();
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  Future<void> postThread() async {
    // prepare client
    User? user =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
    Dio dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    MobileApiClient client = MobileApiClient(dio, baseUrl: discuz.baseURL);

    String title = _titleEditingController.text;
    String content = PostTextFieldUtils.getPostMessage(_controller.text);
    // need to process aid
    List<String> aidList =
        PostTextFieldUtils.getAttachmentAidList(_controller.text);
    Map<String, String> dataMap = {};
    for (var aid in aidList) {
      String key = "attachnew[${aid}][description]";
      dataMap[key] = "";
    }
    print("Get Aids ${aidList} ${dataMap}");

    String typeId = selectedTypeId == null ? "" : selectedTypeId!;
    CaptchaFields? captchaFields = captchaController.value;
    String captchaHash = "";
    String captchaMod = "";
    String verification = "";
    if (captchaFields != null && captchaFields.captchaFormHash.isNotEmpty) {
      captchaHash = captchaFields.captchaFormHash;
      verification = captchaFields.verification;
      captchaMod = "forum::post";
      //captchaMod = "forum::viewthread";
      print(
          "Captcha hash: ${captchaFields.captchaFormHash} verification: ${captchaFields.verification}");
    }

    if (_displayForumResult != null) {
      client
          .postNewThread(
              _displayForumResult!.discuzIndexVariables.formHash,
              fid,
              typeId,
              title,
              content,
              captchaHash,
              captchaMod,
              verification,
              aidList,
              dataMap)
          .then((value) {
        if (value.errorResult?.key == "post_newthread_succeed") {
          EasyLoading.showSuccess(
              "${value.errorResult?.content}(${value.errorResult?.key})");
          Navigator.of(context).pop();
        } else {
          EasyLoading.showError(
              "${value.errorResult?.content}(${value.errorResult?.key})");
        }
      });
    }
  }
}
