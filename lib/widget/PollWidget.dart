import 'dart:developer';

import 'package:discuz_flutter/JsonResult/ViewThreadResult.dart' as PollOptionInResult;
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/utility/AppPlatformIcons.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/TimeDisplayUtils.dart';
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
    List<String> checkedOptionIds = [];
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
    List<FlutterPolls.PollOption> flutterPollOptionList = [];

    flutterPollOptionList = pollOptionList.map(
            (e) => FlutterPolls.PollOption(id:e.id.toString(),title: Text(e.name), votes: e.voteNumber)
    ).toList();
    log("The poll option: ${flutterPollOptionList}");
    int maxVote = 0;
    String? maxOptionId = null;
    for(int i=0;i<flutterPollOptionList.length; i++){
      if(flutterPollOptionList[i].votes> maxVote){
        maxVote = flutterPollOptionList[i].votes;
        maxOptionId = flutterPollOptionList[i].id!;
      }
      log("Print ${i} -> ${flutterPollOptionList[i].votes} ${flutterPollOptionList[i].id}");
    }

    if(flutterPollOptionList.isNotEmpty){
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 8.0),
        child: FlutterPolls.FlutterPolls(
          pollId: this.fid.toString(),
          onVoted: (FlutterPolls.PollOption pollOption, int newTotalVoters) async {
            return await vote(pollOption);
          },
          hasVoted: !poll.allowVote,
          userVotedOptionId: !poll.allowVote? maxOptionId!: null,
          pollTitle: poll.allowVote?Text(S.of(context).pollTitle):Text(S.of(context).pollNotAllowed),
          pollOptions: flutterPollOptionList,
          pollEnded: poll.expiredAt.isBefore(DateTime.now()),
          votedBackgroundColor: Theme.of(context).colorScheme.surface,
          votedProgressColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          leadingVotedProgessColor: Theme.of(context).colorScheme.primary.withOpacity(0.6),
          votedCheckmark: Icon(AppPlatformIcons(context).checkCircleOutlined, color: Theme.of(context).textTheme.bodySmall?.color,),
          metaWidget: Row(
            children: [
              RichText(
                text: TextSpan(
                    text: ' · ' + S.of(context).pollExpireAt(TimeDisplayUtils.getLocaledTimeDisplay(context, poll.expiredAt)),
                ),


              )
            ],
          ),
        ),
      );
    }
    else{
      return Container();
    }

  }

}
