import 'package:discuz_flutter/JsonResult/ViewThreadResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

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



  List<PollOption> getPollOptions() {
    List<PollOption> pollOptions = [];
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
      List<PollOption> pollOption = getPollOptions();
      PollOption option = pollOption[index];
      return option.voteNumber.toDouble() / totalVote;
    }
  }

  void _vote() async{
    List<PollOption> options = getPollOptions();
    List<int> checkedPosition = checkedOption;
    if(checkedPosition.length> poll.maxChoice || checkedOption.isEmpty){
      return;
    }
    List<int> checkedOptionIds = [];
    for(var i in checkedPosition){
      checkedOptionIds.add(options[i].id);
    }
    // send it
    User? user =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
    Discuz discuz =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false).discuz!;
    final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    final client = MobileApiClient(dio, baseUrl: discuz.baseURL);
    print("Checked id ${checkedOptionIds}");
    // client.votePollRaw(tid, this.formhash, checkedOptionIds).then((value){
    //   print(value);
    // });

    client.votePoll(fid,tid, this.formhash, checkedOptionIds).then((value){
      if(value.errorResult != null && value.errorResult!.key == "thread_poll_succeed"){

        // it's a success
        // add proportion
        Map<String, PollOption> pollOptionMap = poll.pollOptionsMap;
        for(var entry in pollOptionMap.entries){
          PollOption pollOption = entry.value;
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
      }
      else{
        if(value.errorResult!= null){
          EasyLoading.showError("${value.errorResult!.content} (${value.errorResult!.key})");
        }
        else{
          EasyLoading.showError(S.of(context).error);
        }

      }
    });

  }

  @override
  Widget build(BuildContext context) {
    List<PollOption> pollOption = getPollOptions();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // functionality row
          ListView.builder(
            shrinkWrap: true,
            itemBuilder: (context, index) {
              PollOption option = pollOption[index];
              return GestureDetector(
                child: Container(
                    margin: EdgeInsets.fromLTRB(4, 4, 16, 4),
                    // padding: EdgeInsets.symmetric(vertical: 4.0),
                    width: double.infinity,
                    child: GestureDetector(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LinearPercentIndicator(
                            width: MediaQuery.of(context).size.width*0.9,
                            lineHeight: 36.0,
                            animation: true,
                            animationDuration: 500,
                            percent: getOptionPercent(index),
                            backgroundColor: Theme.of(context).brightness == Brightness.dark? Colors.white24: Colors.grey.shade300,
                            progressColor: Colors.blue.shade400,
                            center: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if(checkedOption.contains(index))
                                  Icon(Icons.check),
                                Text(
                                  option.name,
                                  style: new TextStyle(fontSize: 14.0),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      onTap: (){
                        // check whether it's simple choice
                        if(!poll.allowVote){
                          return;
                        }
                        if(checkedOption.contains(index)){
                          // remove it
                          setState(() {
                            checkedOption.remove(index);
                          });
                        }
                        else{
                          setState(() {
                            checkedOption.add(index);
                          });
                        }
                        // check if options is multiple
                        if (poll.maxChoice == 1){
                          _vote();
                        }

                        print("object");
                      },
                    )
                ),
              );
            },
            itemCount: pollOption.length,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // visible
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 12),
                            SizedBox(
                              width: 8.0,
                            ),
                            Text(S.of(context).pollExpireAt(timeago.format(poll.expiredAt)), style: TextStyle(fontSize: 12))
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.how_to_vote_outlined, size: 12),
                            SizedBox(
                              width: 8.0,
                            ),
                            Text(
                              S.of(context).pollVoterNumber(poll.votersCount), style: TextStyle(fontSize: 12),
                            )
                          ],
                        ),
                      ],
                    )),
                if(poll.allowVote && poll.maxChoice > 1)
                ElevatedButton(
                    onPressed: checkedOption.length > poll.maxChoice || checkedOption.isEmpty? null :() {
                      _vote();
                    },
                    child: Text(S.of(context).submitPoll(checkedOption.length, poll.maxChoice)))
              ],
            ),
          )
        ],
      ),
    );
  }

}
