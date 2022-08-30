
import 'package:discuz_flutter/screen/SmileyListScreen.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:discuz_flutter/widget/PostTextField.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../dao/ImageAttachmentDao.dart';
import '../database/AppDatabase.dart';
import '../entity/Discuz.dart';
import '../entity/ImageAttachment.dart';
import '../entity/Smiley.dart';
import '../generated/l10n.dart';
import '../screen/ExtraFuncInThreadScreen.dart';
import '../utility/UserPreferencesUtils.dart';

class PushThreadPage extends StatelessWidget{
  int fid;
  int tid;
  Discuz discuz;

  PushThreadPage(this.discuz,this.fid, this.tid);

  @override
  Widget build(BuildContext context) {
    return PushThreadStatefulWidget(this.discuz,this.fid, this.tid);
  }

}

class PushThreadStatefulWidget extends StatefulWidget{
  int fid;
  Discuz discuz;
  int tid;

  PushThreadStatefulWidget(this.discuz,this.fid, this.tid);

  @override
  PushThreadState createState() {
    return PushThreadState(this.discuz,this.fid, this.tid);
  }

}

class PushThreadState extends State<PushThreadStatefulWidget>{
  Discuz discuz;
  int fid;
  int tid;
  TextEditingController _controller = TextEditingController();
  FocusNode focusNode = FocusNode();
  List<String> insertedAidList = [];

  PushThreadState(this.discuz,this.fid, this.tid);

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      iosContentBottomPadding: true,
      iosContentPadding: true,
      appBar: PlatformAppBar(
        title: Text(S.of(context).pushThreadTitle),
      ),
      body: Column(
        children: [
          // for the button groups
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
          Expanded(
              child: Padding(
                padding: EdgeInsets.all(4.0),
                child: PostTextField(
                  discuz, _controller,
                  focusNode: focusNode,
                  expanded: true,
                ),
              )
          )
        ],
      ),
    );
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

  void

}