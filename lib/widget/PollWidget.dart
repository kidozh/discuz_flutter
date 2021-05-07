import 'package:discuz_flutter/JsonResult/ViewThreadResult.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:timeago/timeago.dart' as timeago;

class PollWidget extends StatelessWidget {
  Poll poll;
  PollWidget(this.poll);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return PollStatefulWidget(poll);
  }
}

class PollStatefulWidget extends StatefulWidget{
  Poll poll;
  PollStatefulWidget(this.poll);
  @override
  State<PollStatefulWidget> createState() {
    // TODO: implement createState
    return PollState(poll);
  }

}

class PollState extends State<PollStatefulWidget>{
  Poll poll;
  PollState(this.poll);
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

                ElevatedButton(
                    onPressed: checkedOption.length > poll.maxChoice? null :() {

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
