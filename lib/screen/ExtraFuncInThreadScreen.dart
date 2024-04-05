

import 'dart:io';

import 'package:discuz_flutter/JsonResult/CheckPostResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/dao/ImageAttachmentDao.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/DiscuzError.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../entity/ImageAttachment.dart';

typedef StringToVoidFunc = void Function(String, String);

class ExtraFuncInThreadScreen extends StatefulWidget{

  int tid = 0;
  int fid = 0;
  StringToVoidFunc onReplyWithImage;
  Discuz discuz;
  bool? showHistoricalAttachment;


  ExtraFuncInThreadScreen(this.discuz,this.tid, this.fid,{required this.onReplyWithImage, this.showHistoricalAttachment});

  @override
  ExtraFuncInThreadState createState() {
    return ExtraFuncInThreadState(this.discuz,this.tid, this.fid, this.onReplyWithImage, this.showHistoricalAttachment);
  }

}

class ExtraFuncInThreadState extends State<ExtraFuncInThreadScreen>{
  final ImagePicker _picker = ImagePicker();

  CheckPostResult _checkPostResult = CheckPostResult();
  DiscuzError? _discuzError;
  bool? showHistoricalAttachment;

  int tid = 0;
  int fid = 0;
  StringToVoidFunc onReplyWithImage;
  List<ImageAttachment> imageAttachmentList = [];
  Discuz discuz;


  ExtraFuncInThreadState(this.discuz,this.tid, this.fid, this.onReplyWithImage, this.showHistoricalAttachment);

  @override
  void initState() {
    super.initState();
    _loadCheckPostInfo();
    _loadAllSavedImageAttachment();
  }

  void _loadAllSavedImageAttachment() async {
    ImageAttachmentDao imageAttachmentDao = await AppDatabase.getImageAttachmentDao();
    setState((){
      imageAttachmentList = imageAttachmentDao.getFavoriteThreadList(discuz);
    });
  }

  @override
  Widget build(BuildContext context) {

    if(_discuzError != null){
      return Container(
        height: MediaQuery.of(context).size.height*0.25,
        child: ListTile(
          leading: Icon(Icons.error_outline, color: Colors.red,),
          title: Text(_discuzError!.content),
        ),
      );
    }
    else if(_checkPostResult.variables.allowPerm.uploadHash.isEmpty){
      return Container(
        height: MediaQuery.of(context).size.height*0.25,
        child: ListTile(
          leading: PlatformCircularProgressIndicator(),
          title: Text(S.of(context).preparingPage),
        )
      );
    }
    else{
      return Container(
        height: MediaQuery.of(context).size.height*0.25,
        child: GridView.count(
          crossAxisCount: 4,
          padding: EdgeInsets.all(4.0),
          shrinkWrap: true,
          children: extraFuncListWidget(),
        ),
      );
    }



  }
  List<Widget> extraFuncListWidget(){
    List<Widget> widgetList = [
      ExtraFuncBlockButton(PlatformIcons(context).collectionsSolid, S.of(context).addAPhoto, onPressed: () async{
        // recv the photo from gallery
        VibrationUtils.vibrateWithClickIfPossible();
        final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

        // then upload to the server
        if(image != null){
          XFile file = XFile(image.path);
          // confirm with user
          showPlatformDialog(
              context: context,
              builder: (context) {
                bool isUploadingPicture = false;
                return PlatformAlertDialog(
                  title: Text(S.of(context).uploadImageToServerDialogTitle),
                  content: Column(
                    children: [
                      if(isUploadingPicture)
                        ListTile(
                          leading: PlatformCircularProgressIndicator(),
                          title: Text(S.of(context).uploadingImageToServer),
                        ),
                      Image.file(File(file.path)),
                    ],
                  ),
                  actions: [
                    PlatformDialogAction(
                      child: Text(S.of(context).uploadCompressedImageToServer),
                      onPressed: () async{
                        setState(() {
                          isUploadingPicture = true;
                        });
                        EasyLoading.showInfo(S.of(context).uploadingImageToServer);
                        // compress it first
                        // get a temp directory

                        Directory directory = await getApplicationDocumentsDirectory();
                        final compressionPath = directory.path+"/"+file.path.split("/").last;
                        // with 90% compression
                        XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(file.path,
                          compressionPath,
                        );
                        if(compressedFile != null){
                          file = compressedFile;
                        }

                        String respString = await uploadPhotoToDiscuzServer(context, File(file.path));
                        setState(() {
                          isUploadingPicture = false;
                        });
                        print("Successful upload image string ${respString}");
                        String aid = getAidFromDiscuzUploadResponse(context, respString);
                        if(aid.isNotEmpty){
                          // send it with aid
                          onReplyWithImage(aid, file.path);
                        }
                        Navigator.of(context).pop();
                      },
                    ),
                    PlatformDialogAction(
                      child: Text(S.of(context).uploadRawImageToServer),
                      onPressed: () async{
                        setState(() {
                          isUploadingPicture = true;
                        });
                        EasyLoading.showInfo(S.of(context).uploadingImageToServer);
                        String respString = await uploadPhotoToDiscuzServer(context, File(file.path));
                        setState(() {
                          isUploadingPicture = false;
                        });
                        print("Successful upload image string ${respString}");
                        String aid = getAidFromDiscuzUploadResponse(context, respString);
                        if(aid.isNotEmpty){
                          // send it with aid
                          onReplyWithImage(aid, file.path);
                        }
                        Navigator.of(context).pop();
                      },
                    ),
                    PlatformDialogAction(
                      child: Text(S.of(context).cancel),
                      onPressed: () async{
                        // cancel it
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                );
              }
          );


        }
        else{
          EasyLoading.showToast(S.of(context).noImagePicked);
        }


      }),
      ExtraFuncBlockButton(PlatformIcons(context).photoCameraSolid, S.of(context).takeAPicture, onPressed: () async{
        final XFile? image = await _picker.pickImage(source: ImageSource.camera);
        if(image != null){
          File file = File(image.path);

          showPlatformDialog(
              context: context,
              builder: (context){
                bool isUploadingPicture = false;
                return PlatformAlertDialog(
                  title: Text(S.of(context).uploadImageToServerDialogTitle),
                  content: Column(
                    children: [
                      if(isUploadingPicture)
                        ListTile(
                          leading: PlatformCircularProgressIndicator(),
                          title: Text(S.of(context).uploadingImageToServer),
                        ),
                      Image.file(file),
                    ],
                  ),
                  actions: [
                    PlatformDialogAction(
                      child: Text(S.of(context).uploadCompressedImageToServer),
                      onPressed: () async{
                        setState(() {
                          isUploadingPicture = true;
                        });
                        EasyLoading.showInfo(S.of(context).uploadingImageToServer);
                        // compress it first
                        // get a temp directory

                        Directory directory = await getApplicationDocumentsDirectory();

                        final compressionPath = directory.path+"/"+file.path.split("/").last;
                        // with 90% compression
                        XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(file.path,
                          compressionPath,
                        );
                        if(compressedFile != null){
                          file = File(compressedFile.path);
                        }
                        String respString = await uploadPhotoToDiscuzServer(context, file);
                        setState(() {
                          isUploadingPicture = false;
                        });
                        print("Successful upload image string ${respString}");
                        String aid = getAidFromDiscuzUploadResponse(context, respString);
                        if(aid.isNotEmpty){
                          // send it with aid
                          onReplyWithImage(aid, file.path);

                        }
                        Navigator.of(context).pop();
                      },
                    ),
                    PlatformDialogAction(
                      child: Text(S.of(context).uploadRawImageToServer),
                      onPressed: () async{
                        setState(() {
                          isUploadingPicture = true;
                        });
                        EasyLoading.showInfo(S.of(context).uploadingImageToServer);
                        String respString = await uploadPhotoToDiscuzServer(context, file);
                        setState(() {
                          isUploadingPicture = false;
                        });
                        print("Successful upload image string ${respString}");
                        String aid = getAidFromDiscuzUploadResponse(context, respString);
                        if(aid.isNotEmpty){
                          // send it with aid
                          onReplyWithImage(aid, file.path);

                        }
                        Navigator.of(context).pop();
                      },
                    ),
                    PlatformDialogAction(
                      child: Text(S.of(context).cancel),
                      onPressed: () async{
                        // cancel it
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                );
              }
          );

        }
        else{
          EasyLoading.showToast(S.of(context).noImagePicked);
        }

      }),
      // comes with inserted attachment

    ];

    // append all saved image
    if(showHistoricalAttachment == false){
      return widgetList;
    }
    for(var imageAttachment in imageAttachmentList){
      widgetList.add(
        InkWell(
          child: Image.file(File(imageAttachment.path)),
          onTap: () async{
            VibrationUtils.vibrateWithClickIfPossible();
            // add to textfields
            onReplyWithImage(imageAttachment.aid, imageAttachment.path);
            // change with
            ImageAttachmentDao imageAttachmentDao = await AppDatabase.getImageAttachmentDao();
            ImageAttachment insertedIA = imageAttachment;
            insertedIA.updateAt = DateTime.now();
            imageAttachmentDao.insertImageAttachmentWithKey(insertedIA.key, insertedIA);
          },
        )

      );
    }

    return widgetList;
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
      int code = int.parse(respString);
      switch (code){
        case -1:{
          EasyLoading.showError(S.of(context).uploadImageError1);
          return "";
        }
        case -2:{
          EasyLoading.showError(S.of(context).uploadImageError2);
          return "";
        }
        case -3:{
          EasyLoading.showError(S.of(context).uploadImageError3);
          return "";
        }
        case -4:{
          EasyLoading.showError(S.of(context).uploadImageError4);
          return "";
        }
        case -5:{
          EasyLoading.showError(S.of(context).uploadImageError5);
          return "";
        }
        case -6:{
          EasyLoading.showError(S.of(context).uploadImageError6);
          return "";
        }
        case -7:{
          EasyLoading.showError(S.of(context).uploadImageError7);
          return "";
        }
        case -8:{
          EasyLoading.showError(S.of(context).uploadImageError8);
          return "";
        }
        case -9:{
          EasyLoading.showError(S.of(context).uploadImageError9);
          return "";
        }
        case -10:{
          EasyLoading.showError(S.of(context).uploadImageError10);
          return "";
        }
        case -11:{
          EasyLoading.showError(S.of(context).uploadImageError11);
          return "";
        }

      }
      if(code > 0){
        return respString;
      }
      else{
        return "";
      }

    }
    catch(e){
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
            Icon(icons, size: 24, color: Theme.of(context).unselectedWidgetColor,),
            SizedBox(height: 6,),
            Text(text, style: Theme.of(context).textTheme.titleMedium,)
          ],
        ),
      ),
      onTap: (){
        onPressed();
      },
    );
  }



}