import 'dart:developer';

import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

class ReportContentPage extends StatelessWidget{
  String authorName;
  int rid;
  int fid;
  String formhash;

  @override
  Widget build(BuildContext context) {
    return ReportContentStatefulWidget(this.authorName, this.rid, this.fid, this.formhash);
  }

  ReportContentPage(this.authorName, this.rid, this.fid, this.formhash);
}

class ReportContentStatefulWidget extends StatefulWidget{
  String authorName;
  int rid;
  int fid;
  String formhash;

  ReportContentStatefulWidget(this.authorName, this.rid, this.fid, this.formhash);

  @override
  ReportContentState createState() {
    return ReportContentState(this.authorName, this.rid, this.fid, this.formhash);
  }

}

enum ReportReason{
  TrashAdvertisement,
  IllegalContent,
  Spam,
  DuplicatePost,
  Others
}

class ReportContentState extends State<ReportContentStatefulWidget>{
  String authorName;
  int rid;
  int fid;
  String formhash;
  ReportReason? selectedReason;
  TextEditingController reportDetailReasonTextController = TextEditingController();

  ReportContentState(this.authorName, this.rid, this.fid, this.formhash);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return PlatformScaffold(
      iosContentPadding: true,
      appBar: PlatformAppBar(
        title: Text(S.of(context).reportContentTitle(authorName)),
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              title: Text(S.of(context).trashAd),
              leading: Radio<ReportReason>(
                value: ReportReason.TrashAdvertisement,
                groupValue: selectedReason,
                onChanged: (ReportReason? reportReason){
                  setState(() {
                    selectedReason = ReportReason.TrashAdvertisement;
                  });
                },
              ),

            ),
            ListTile(
              title: Text(S.of(context).illegalContent),
              leading: Radio<ReportReason>(
                value: ReportReason.IllegalContent,
                groupValue: selectedReason,
                onChanged: (ReportReason? reportReason){
                  setState(() {
                    selectedReason = ReportReason.IllegalContent;
                  });
                },
              ),

            ),
            ListTile(
              title: Text(S.of(context).spam),
              leading: Radio<ReportReason>(
                value: ReportReason.Spam,
                groupValue: selectedReason,
                onChanged: (ReportReason? reportReason){
                  setState(() {
                    selectedReason = ReportReason.Spam;
                  });
                },
              ),

            ),
            ListTile(
              title: Text(S.of(context).duplicatedPost),
              leading: Radio<ReportReason>(
                value: ReportReason.DuplicatePost,
                groupValue: selectedReason,
                onChanged: (ReportReason? reportReason){
                  setState(() {
                    selectedReason = ReportReason.DuplicatePost;
                  });
                },
              ),

            ),
            ListTile(
              title: Text(S.of(context).other),
              leading: Radio<ReportReason>(
                value: ReportReason.Others,
                groupValue: selectedReason,
                onChanged: (ReportReason? reportReason){
                  setState(() {
                    selectedReason = ReportReason.Others;
                  });
                },
              ),

            ),
            if(selectedReason!= null && selectedReason == ReportReason.Others)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16),
                child: PlatformTextField(
                  hintText: S.of(context).reportOtherReasonHint,
                  controller: reportDetailReasonTextController,
                ),
              ),
            SizedBox(
              height: 64,
            ),
            if(selectedReason!= null || (selectedReason == ReportReason.Others && reportDetailReasonTextController.text.isNotEmpty) )
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PlatformElevatedButton(
                  child: Text(S.of(context).reportContentTitle(authorName)),
                  onPressed: (){
                    _reportContentByJS();
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void _reportContentByJS() async{
    User? user = Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
    Discuz discuz = Provider.of<DiscuzAndUserNotifier>(context, listen: false).discuz!;
    final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    final client = MobileApiClient(dio, baseUrl: discuz.baseURL);
    String reportSelect = S.of(context).other;
    if (this.selectedReason == null){
      return;
    }
    switch (this.selectedReason!){
      case (ReportReason.TrashAdvertisement):{
        reportSelect = S.of(context).trashAd;
        break;
      }
      case (ReportReason.DuplicatePost):{
        reportSelect = S.of(context).duplicatedPost;
        break;
      }
      case (ReportReason.Spam):{
        reportSelect = S.of(context).spam;
        break;
      }
      case (ReportReason.Others):{
        reportSelect = S.of(context).other;
        break;
      }
      case (ReportReason.IllegalContent):{
        reportSelect = S.of(context).illegalContent;
        break;
      }


    }
    client.reportContent(formhash, reportSelect, this.reportDetailReasonTextController.text, "post", this.rid)
        .then((value) {
          EasyLoading.showSuccess(S.of(context).reportSuccessfully(discuz.siteName));
          Navigator.of(context).pop();
        }
    ).onError((error, stackTrace){
      log(stackTrace.toString());
    });
  }
}