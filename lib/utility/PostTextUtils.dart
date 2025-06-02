


import 'dart:developer';

import 'package:html/dom.dart';
import 'package:html/parser.dart';

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
        .replaceAll(RegExp(r"\[spoil.*?\]"), r'<spoil>')
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

    string = string.replaceAllMapped(RegExp(r"\[media.*?\](.*?)\[/media\]"), (match) {

      if(match.groupCount == 1){
        return '<media>${match.group(1)}</media>';
      }
      return "";
    });
    return string;
  }

  static String wrapLinksInHtml(String htmlContent) {
    Document document = parse(htmlContent);

    void processNode(Node node) {
      if (node is Text) {
        final text = node.text;
        final linkRegExp = RegExp(r'((https?:\/\/|www\.)[^\s<]+)', caseSensitive: false);

        if (linkRegExp.hasMatch(text)) {
          final parent = node.parent;
          if (parent == null) return;

          final matches = linkRegExp.allMatches(text).toList();
          final fragments = <Node>[];
          int lastIndex = 0;

          for (final match in matches) {
            final linkText = match.group(0)!;
            final href = linkText.startsWith('http') ? linkText : 'http://$linkText';

            if (match.start > lastIndex) {
              fragments.add(Text(text.substring(lastIndex, match.start)));
            }

            final a = Element.tag('a')
              ..attributes['href'] = href
              ..text = linkText;
            fragments.add(a);

            lastIndex = match.end;
          }

          if (lastIndex < text.length) {
            fragments.add(Text(text.substring(lastIndex)));
          }

          // 替换：插入新节点，然后删除原始 Text 节点
          for (final frag in fragments) {
            parent.insertBefore(frag, node);
          }
          node.remove();
        }
      } else {
        // 递归处理子节点
        for (final child in node.nodes.toList()) {
          processNode(child);
        }
      }
    }

    document.body?.nodes.toList().forEach(processNode);
    return document.body?.innerHtml ?? htmlContent;
  }

  static String getDecodedString(String html, bool useCompactParagraph){
    String decodedString = replaceCollapseTag(html);
    decodedString = replaceSpoilTag(decodedString);
    decodedString = replaceCountDownTag(decodedString);
    decodedString = replaceMediaTag(decodedString);
    decodedString = decodedString;
    if(useCompactParagraph){
      decodedString = decodedString.replaceAll(RegExp(r"<br\s+?/>\s+<br\s+?/>"), r"<br />");
    }


    // if(useCompactParagraph){
    //   decodedString = decodedString.replaceAll(RegExp(r"<br.*?/>"), "");
    // }

    decodedString = wrapLinksInHtml(decodedString);

    return decodedString;
  }

  static String decodePostMessage(String message){
    message = message.replaceAll(RegExp(r'style=".*?"'), "");
    message = message.replaceAll(RegExp(r'color=".*?"'), "");
    log("Get decoded remove style message ${message}");
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