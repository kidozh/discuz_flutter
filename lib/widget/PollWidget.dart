import 'dart:developer';

import 'package:discuz_flutter/JsonResult/ViewThreadResult.dart' as PollOptionInResult;
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_polls/flutter_polls.dart' as FlutterPolls;
import 'package:provider/provider.dart';

import '../JsonResult/ViewThreadResult.dart';

class PollWidget extends StatelessWidget {
  Poll poll;
  String formhash;
  int tid;
  int fid;
  PollWidget(this.poll, this.formhash, this.tid, this.fid);


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return PollStatefulWidget(poll, formhash, tid,fid);
  }
}

class PollStatefulWidget extends StatefulWidget{
  Poll poll;
  String formhash;
  int tid;
  int fid;
  PollStatefulWidget(this.poll, this.formhash, this.tid, this.fid);
  @override
  State<PollStatefulWidget> createState() {
    // TODO: implement createState
    return PollState(poll,formhash,tid,fid);
  }

}

class PollState extends State<PollStatefulWidget>{
  Poll poll;
  String formhash;
  int tid;
  int fid;
  PollState(this.poll, this.formhash, this.tid, this.fid);
  List<int> checkedOption = [];



  List<PollOptionInResult.PollOption> getPollOptions() {
    List<PollOptionInResult.PollOption> pollOptions = [];
    for (var entry in poll.pollOptionsMap.entries) {
      pollOptions.add(entry.value);
    }

    return pollOptions;
  }

  double getOptionPercent(int index){
    int totalVote = 0;
    for (var entry in poll.pollOptionsMap.entries) {
      totalVote += entry.value.voteNumber;
    }
    if(totalVote == 0){
      return 0.0;
    }
    else{
      List<PollOptionInResult.PollOption> pollOption = getPollOptions();
      PollOptionInResult.PollOption option = pollOption[index];
      return option.voteNumber.toDouble() / totalVote;
    }
  }

  Future<bool> vote(FlutterPolls.PollOption pollOption) async{
    List<int> checkedOptionIds = [];
    if(pollOption.id == null){
      return false;
    }
    else{
      checkedOptionIds.add(pollOption.id!);
    }

    // for(var i in checkedPosition){
    //   checkedOptionIds.add(options[i].id);
      User? user =
          Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
      Discuz discuz =
      Provider.of<DiscuzAndUserNotifier>(context, listen: false).discuz!;
      final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
      final client = MobileApiClient(dio, baseUrl: discuz.baseURL);
      return await client.votePoll(fid,tid, this.formhash, checkedOptionIds).then((value){
        if(value.errorResult != null && value.errorResult!.key == "thread_poll_succeed"){

          // it's a success
          // add proportion
          Map<String, PollOptionInResult.PollOption> pollOptionMap = poll.pollOptionsMap;
          for(var entry in pollOptionMap.entries){
            PollOptionInResult.PollOption pollOption = entry.value;
            if(checkedOptionIds.contains(pollOption.id)){
              pollOption.voteNumber += 1;
            }

          }

          setState(() {
            // refresh it
            poll.allowVote = false;
            poll = poll;

          });
          EasyLoading.showSuccess("${value.errorResult!.content} (${value.errorResult!.key})");
          return true;
        }
        else{
          if(value.errorResult!= null){
            EasyLoading.showError("${value.errorResult!.content} (${value.errorResult!.key})");
          }
          else{
            EasyLoading.showError(S.of(context).error);
          }
          return false;

        }
      }).catchError((e,s){
        return false;
      });
    }

  @override
  Widget build(BuildContext context) {
    List<PollOptionInResult.PollOption> pollOptionList = getPollOptions();
    List<FlutterPolls.PollOption> flutterPollOptionList = pollOptionList.map(
            (e) => FlutterPolls.PollOption(title: Text(e.name), votes: e.voteNumber, id:e.id)
    ).toList();
    log("The poll option: ${flutterPollOptionList}");
    if(flutterPollOptionList.isNotEmpty){
      return FlutterPolls.FlutterPolls(
        pollId: this.fid.toString(),
        onVoted: (FlutterPolls.PollOption pollOption, int newTotalVoters) async {
          return await vote(pollOption);
        },
        hasVoted: !poll.allowVote,
        pollTitle: Text(this.fid.toString()),
        pollOptions: flutterPollOptionList,
        pollEnded: poll.expiredAt.isBefore(DateTime.now()),
        metaWidget: Row(
          children: [

          ],
        ),
      );
    }
    else{
      return Container();
    }

  }

}
