

import 'dart:io';

import 'package:discuz_flutter/JsonResult/CheckPostResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/DiscuzError.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/ViewThreadSliverPage.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/screen/BlankScreen.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:discuz_flutter/widget/ErrorCard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_html/shims/dart_ui.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

typedef StringToVoidFunc = void Function(String);

class ExtraFuncInThreadScreen extends StatefulWidget{

  int tid = 0;
  int fid = 0;
  StringToVoidFunc onReplyWithImage;


  ExtraFuncInThreadScreen(this.tid, this.fid,{required this.onReplyWithImage});

  @override
  ExtraFuncInThreadState createState() {
    return ExtraFuncInThreadState(this.tid, this.fid, this.onReplyWithImage);
  }

}

class ExtraFuncInThreadState extends State<ExtraFuncInThreadScreen>{
  final ImagePicker _picker = ImagePicker();

  CheckPostResult _checkPostResult = CheckPostResult();
  DiscuzError? _discuzError;

  int tid = 0;
  int fid = 0;
  StringToVoidFunc onReplyWithImage;

  ExtraFuncInThreadState(this.tid, this.fid, this.onReplyWithImage);

  @override
  void initState() {
    super.initState();
    _loadCheckPostInfo();
  }

  @override
  Widget build(BuildContext context) {

    if(_discuzError != null){
      return Container(
        height: 100,
        child: ListTile(
          leading: Icon(Icons.error_outline, color: Colors.red,),
          title: Text(_discuzError!.content),
        ),
      );
    }
    else if(_checkPostResult.variables.allowPerm.uploadHash.isEmpty){
      return Container(
        height: 100,
        child: ListTile(
          leading: PlatformCircularProgressIndicator(),
          title: Text(S.of(context).preparingPage),
        )
      );
    }
    else{
      return Container(
        height: 100,
        child: GridView.count(
          crossAxisCount: 4,
          padding: EdgeInsets.all(4.0),
          shrinkWrap: true,
          children: [
            ExtraFuncBlockButton(Icons.add_photo_alternate, S.of(context).addAPhoto, onPressed: () async{
              // recv the photo from gallery
              VibrationUtils.vibrateWithClickIfPossible();
              final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
              // then upload to the server
              if(image != null){
                File file = File(image.path);
                String respString = await uploadPhotoToDiscuzServer(context, file);
                print("Successful upload image string ${respString}");
                String aid = getAidFromDiscuzUploadResponse(context, respString);
                if(aid.isNotEmpty){
                  // send it with aid
                  onReplyWithImage(aid);

                }
              }
              else{
                EasyLoading.showToast(S.of(context).noImagePicked);
              }


            }),
            ExtraFuncBlockButton(Icons.photo_camera, S.of(context).takeAPicture, onPressed: () async{
              final XFile? image = await _picker.pickImage(source: ImageSource.camera);
              if(image != null){
                File file = File(image.path);
                String respString = await uploadPhotoToDiscuzServer(context, file);
                print("Successful upload image string ${respString}");
                String aid = getAidFromDiscuzUploadResponse(context, respString);
                if(aid.isNotEmpty){
                  // send it with aid
                  onReplyWithImage(aid);

                }
              }
              else{
                EasyLoading.showToast(S.of(context).noImagePicked);
              }

            }),
          ],
        ),
      );
    }

  }

  Future<String> uploadPhotoToDiscuzServer(BuildContext context, File photoFile) async{
    DiscuzAndUserNotifier discuzAndUserNotifier = Provider.of<DiscuzAndUserNotifier>(context,listen: false);
    if(discuzAndUserNotifier.discuz == null || discuzAndUserNotifier.user == null || _checkPostResult.variables.allowPerm.uploadHash.isEmpty){
      return "";
    }
    else{
      Discuz discuz = discuzAndUserNotifier.discuz!;
      User user = discuzAndUserNotifier.user!;
      final dio = await NetworkUtils.getDioWithPersistCookieJar(discuzAndUserNotifier.user);
      final client = MobileApiClient(dio, baseUrl: discuz.baseURL);

      String uploadedString = await client.uploadImage(user.uid, _checkPostResult.variables.allowPerm.uploadHash, photoFile);
      return uploadedString;
    }
  }

  String getAidFromDiscuzUploadResponse(BuildContext context,String respString){
    // like DISCUZUPLOAD|0|8|1|0
    // or DISCUZUPLOAD|0|9|1|0
    // or DISCUZUPLOAD|0|10|1|0
    // or in keylol DISCUZUPLOAD|0|1475238|1|0
    try{
      int.parse(respString);
      return respString;
    }
    catch(e,s){
      print("response ${respString} is not a integer");
    };

    List<String> splitedVariables = respString.split("|");
    if(splitedVariables.length == 5 && splitedVariables[0] == "DISCUZUPLOAD" && splitedVariables[1] == "0"){
      // a sucessful submit, return the aid
      return splitedVariables[2];
    }
    else if(splitedVariables.length > 1){
      // a further error
      if(splitedVariables[1] != "0"){
        // need to trigger the warning
        switch(splitedVariables[1]){
          case "-1":{
            EasyLoading.showError(S.of(context).uploadImageErrorNegative1);
            return "";
          }
          case "1":{
            EasyLoading.showError(S.of(context).uploadImageError1);
            return "";
          }
          case "2":{
            EasyLoading.showError(S.of(context).uploadImageError2);
            return "";
          }
          case "3":{
            EasyLoading.showError(S.of(context).uploadImageError3);
            return "";
          }
          case "4":{
            EasyLoading.showError(S.of(context).uploadImageError4);
            return "";
          }
          case "5":{
            EasyLoading.showError(S.of(context).uploadImageError5);
            return "";
          }
          case "6":{
            EasyLoading.showError(S.of(context).uploadImageError6);
            return "";
          }
          case "7":{
            EasyLoading.showError(S.of(context).uploadImageError7);
            return "";
          }
          case "8":{
            EasyLoading.showError(S.of(context).uploadImageError8);
            return "";
          }
          case "9":{
            EasyLoading.showError(S.of(context).uploadImageError9);
            return "";
          }
          case "10":{
            EasyLoading.showError(S.of(context).uploadImageError10);
            return "";
          }
          case "11":{
            EasyLoading.showError(S.of(context).uploadImageError11);
            return "";
          }

        }
      }
      
    }
    EasyLoading.showError(S.of(context).uploadImageUnknownError);
    return "";
  }

  void _loadCheckPostInfo() async{

    DiscuzAndUserNotifier discuzAndUserNotifier = Provider.of<DiscuzAndUserNotifier>(context,listen: false);
    print("load check post func by ${discuzAndUserNotifier.discuz} User: ${discuzAndUserNotifier.user}");
    if(discuzAndUserNotifier.discuz == null || discuzAndUserNotifier.user == null){
      return;
    }
    else{
      Discuz discuz = discuzAndUserNotifier.discuz!;
      User user = discuzAndUserNotifier.user!;
      final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
      final client = MobileApiClient(dio, baseUrl: discuz.baseURL);

      client.checkPost(fid, tid).then((value){
        print("Did get the value ${value}");
        setState(() {
          _checkPostResult = value;
        });

      }).catchError((e,s){
        print("${e} ${s}");
        setState(() {
          _discuzError = DiscuzError("network_fail", S.of(context).networkFail);
        });
      });
    }
  }

}

class ExtraFuncBlockButton extends StatelessWidget{
  VoidCallback onPressed;
  IconData icons;
  String text;

  ExtraFuncBlockButton(this.icons,this.text,{required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Card(
        // comes with wechat style
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icons, size: 24,),
            SizedBox(height: 6,),
            Text(text, style: Theme.of(context).textTheme.subtitle1,)
          ],
        ),
      ),
      onTap: (){
        onPressed();
      },
    );
  }



}