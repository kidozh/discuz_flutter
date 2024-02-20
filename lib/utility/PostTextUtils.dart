

class PostTextUtils{
  static String replaceCollapseTag(String string){
    //log("Recv html $string");
    string = string.replaceAllMapped(RegExp(r"\[collapse(|=(.*?))]"), (match){
      //log("Get match string ${match.groupCount} ${match.group(0)}");
      if(match.groupCount == 2){
        String title = match.group(1)!;
        if(title.startsWith("=")){
          title = title.replaceFirst("=", "");
        }
        //log("Recv matched message ${match.group(1)} $title");
        return '<collapse title="$title">';
      }
      else{
        return '<collapse>';
      }
    });
    string = string.replaceAll(RegExp(r"\[/collapse.*?\]"), r"</collapse>");

    return string;
  }

  static String replaceSpoilTag(String string){
    string = string
        .replaceAll(RegExp(r"\[spoil.*?\]"), r'<spoil><br/>')
        .replaceAll(RegExp(r"\[/spoil\]"), r"</spoil>");

    return string;
  }

  static String replaceCountDownTag(String string){
    string = string.replaceAllMapped(RegExp(r"\[micxp_countdown.*?\](.*?)\[/micxp_countdown\]"), (match) {
      if(match.groupCount == 1){
        return '<countdown time="${match.group(1)}"></countdown>';
      }
      return "";
    });
    return string;
  }

  static String replaceMediaTag(String string){
    // process video
    string = string.replaceAllMapped(RegExp(r"\[video.*?\](.*?)\[/video\]"), (match) {
      if(match.groupCount == 1){
        return '<video controls src="${match.group(1)}"></video>';
      }
      return "";
    });
    return string;
  }

  static String getDecodedString(String html){
    String decodedString = replaceCollapseTag(html);
    decodedString = replaceSpoilTag(decodedString);
    decodedString = replaceCountDownTag(decodedString);
    decodedString = replaceMediaTag(decodedString);
    decodedString = decodedString;
    return decodedString;
  }

  static String decodePostMessage(String message){
    return message

    ;
  }

  static String matchIsolatedURL(String message){
    // only accept HTTP(S) link
    // but not in url aready
    RegExp urlREgex = RegExp(r'(?! (<a.*?> |"))*(https?)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]');
    return "";
  }


}