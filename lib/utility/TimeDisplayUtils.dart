

import 'package:discuz_flutter/generated/l10n.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class TimeDisplayUtils{

  static String getLocaledTimeDisplay(BuildContext context, DateTime dateTime){
    DateTime now = DateTime.now();
    int nowMilliSec = now.millisecondsSinceEpoch;
    int dateTimeMilliSec = dateTime.millisecondsSinceEpoch;
    int nowSec = nowMilliSec ~/ 1000;
    int dateTimeSec = dateTimeMilliSec ~/ 1000;
    // check for the past time first
    if(nowMilliSec > dateTimeMilliSec){
      // seems in the past
      int second = nowSec - dateTimeSec;
      int minute = second ~/ 60;
      int hour = second ~/ 3600;
      int day = second ~/ (3600 * 24);
      //print("Time Count ${second} ${minute} ${hour} ${day}");
      if(second<60){
        // happened in 1 minutes
        return S.of(context).justNow;
      }
      else if(minute < 60){
        return S.of(context).minuteAgo(minute);
      }
      else if(hour< 24){
        return S.of(context).hourAgo(hour);
      }
      else if(day<7){
        return S.of(context).dayAgo(day);
      }
      else{
        return DateFormat.yMd().format(dateTime);
      }


    }
    else{
      int second =  dateTimeSec - nowSec;
      int minute = second ~/ 60;
      int hour = second ~/ 3600;
      int day = second ~/ (3600 * 24);
      if(second<60){
        // happened in 1 minutes
        return S.of(context).justNow;
      }
      else if(minute < 60){
        return S.of(context).minuteLater(minute);
      }
      else if(hour< 24){
        return S.of(context).hourLater(hour);
      }
      else if(day<7){
        return S.of(context).dayLater(day);
      }
      else{
        return DateFormat.yMd().format(dateTime);
      }
    }
  }
}