
import 'package:dio/dio.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/screen/LoadingScreen.dart';
import 'package:discuz_flutter/screen/SmileyListScreen.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:discuz_flutter/widget/PostTextField.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
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
import '../utility/UserPreferencesUtils.dart';

class PostThreadPage extends StatelessWidget{
  int fid;
  int tid;
  Discuz discuz;
  Draft? draft;

  PostThreadPage(this.discuz,this.fid, this.tid,{this.draft});

  @override
  Widget build(BuildContext context) {
    return PostThreadStatefulWidget(this.discuz,this.fid, this.tid, draft:draft);
  }

}

class PostThreadStatefulWidget extends StatefulWidget{
  int fid;
  Discuz discuz;
  int tid;
  Draft? draft;

  PostThreadStatefulWidget(this.discuz,this.fid, this.tid, {this.draft});

  @override
  PostThreadState createState() {
    return PostThreadState(this.discuz,this.fid, this.tid, draft: draft);
  }

}

class PostThreadState extends State<PostThreadStatefulWidget>{
  Discuz discuz;
  int fid;
  int tid;
  TextEditingController _controller = TextEditingController();
  TextEditingController _titleEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();
  List<String> insertedAidList = [];
  Draft? draft;
  // dropdown menu status
  String? selectedTypeId;

  PostThreadState(this.discuz,this.fid, this.tid,{this.draft});

  @override
  void initState() {
    super.initState();
    _loadForumInfo();
    // add backup option
    backupDraftIfPossible();
  }

  @override
  Widget build(BuildContext context) {
    if(_displayForumResult == null){
      return LoadingScreen(loadingText: S.of(context).loadingForumInformation,);
    }


    return PlatformScaffold(
      iosContentBottomPadding: true,
      iosContentPadding: true,
      appBar: PlatformAppBar(
        title: Text(S.of(context).pushThreadTitle),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 4),
        child: Column(
          children: [
            // for the button groups
            Row(
              children: [
                if(getOptionalDropdownMenuItem().isNotEmpty)
                  DropdownButton<String>(items: getOptionalDropdownMenuItem(),
                      onChanged: (item){
                        if(item != null){
                          setState((){
                            selectedTypeId = item;
                          });

                        }
                  },
                    value: selectedTypeId,
                  ),
                Expanded(
                    child: TextFormField(
                      controller: _titleEditingController,
                      expands: false,
                      decoration: InputDecoration(
                          hintText: S.of(context).pushThreadTitle
                      ),
                    )
                )

              ],
            ),
            Expanded(
                child: Padding(
                  padding: EdgeInsets.all(4.0),
                  child: PostTextField(
                    discuz, _controller,
                    focusNode: focusNode,
                    expanded: true,
                  ),
                )
            ),
            Row(
              children: [
                PlatformIconButton(
                  icon: Icon(Icons.format_bold_outlined),
                  onPressed: (){
                    VibrationUtils.vibrateWithClickIfPossible();
                    String insertedText = "[b][/b]";
                    insertString(insertedText);
                  },
                ),
                PlatformIconButton(
                  icon: Icon(Icons.format_italic_outlined),
                  onPressed: (){
                    VibrationUtils.vibrateWithClickIfPossible();
                    String insertedText = "[i][/i]";
                    insertString(insertedText);
                  },
                ),
                PlatformIconButton(
                  icon: Icon(Icons.format_quote_outlined),
                  onPressed: (){
                    VibrationUtils.vibrateWithClickIfPossible();
                    String insertedText = "[quote][/quote]";
                    insertString(insertedText);
                  },
                ),

                PlatformIconButton(
                  icon: Icon(Icons.emoji_emotions_outlined),
                  onPressed: (){
                    VibrationUtils.vibrateWithClickIfPossible();
                    // popup a smiley dialog
                    showPlatformModalSheet(context: context, builder: (context) => SmileyListScreen((p0) {insertSmiley(p0);}));
                  },
                ),
                PlatformIconButton(
                  icon: Icon(Icons.image_outlined),
                  onPressed: (){
                    VibrationUtils.vibrateWithClickIfPossible();
                    showPlatformModalSheet(context: context, builder: (context) =>
                        ExtraFuncInThreadScreen(
                          discuz,
                          tid,
                          fid,
                          onReplyWithImage: (aid, path) async {
                            // fill with text first
                            // refresh the layout
                            // insertedAidList.clear();
                            if (aid.isNotEmpty) {
                              String insertedAidString = "[attachimg]${aid}[/attachimg]";
                              insertString(insertedAidString);
                              // add aid to list
                              insertedAidList.add(aid);
                              // add to historical attachment
                              bool savedInDatabase = await UserPreferencesUtils.getRecordHistoryEnabled();
                              if (savedInDatabase) {
                                // save it to database
                                ImageAttachmentDao imageAttachmentDao = await AppDatabase.getImageAttachmentDao();
                                ImageAttachment? imageAttachment = imageAttachmentDao.findImageAttachmentByDiscuzAndAid(discuz, aid);
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
                        )
                    );
                  },
                ),
                PlatformIconButton(
                  icon: Icon(Icons.settings_backup_restore),
                ),
              ],

            ),
          ],
        ),
      ),
    );
  }

  DisplayForumResult? _displayForumResult = null;

  Future<void> _loadForumInfo() async{
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

  List<DropdownMenuItem<String>> getOptionalDropdownMenuItem(){
    List<DropdownMenuItem<String>> dropdownMenuItemList = [];
    if(_displayForumResult?.discuzIndexVariables.threadType == null){
      return dropdownMenuItemList;
    }
    else{
      bool typeRequired = _displayForumResult!.discuzIndexVariables.threadType!.typeRequired();

      // traverse it
      for(var entry in _displayForumResult!.discuzIndexVariables.threadType!.idNameMap.entries){
        dropdownMenuItemList.add(DropdownMenuItem<String>(child: Text(entry.value.toString()), value: entry.key,));
      }
    }

    return dropdownMenuItemList;
  }

  void backupDraftIfPossible(){
    if(draft == null){
      // shall create a new one
      _titleEditingController.addListener(() {
        backupDraft();
      });

      _controller.addListener(() {
        backupDraft();
      });
    }
  }



  Future<void> backupDraft() async{
    // start to collect edittext
    String title = _titleEditingController.text;
    String content = _titleEditingController.text;

    if(draft == null){
      draft = Draft(title, content, fid, selectedTypeId == null? "": selectedTypeId!, DateTime.now(), discuz);
    }
    // start to save it
    DraftDao draftDao = await AppDatabase.getDraftDao();
    draft = await draftDao.insertDraftAndReturnInsertObj(draft!);
  }

}