

import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:discuz_flutter/JsonResult/DisplayForumResult.dart';
import 'package:discuz_flutter/entity/ForumThread.dart';
import 'package:discuz_flutter/screen/EmptyScreen.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:discuz_flutter/widget/ForumThreadWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:html/parser.dart';
import 'package:provider/provider.dart';

import '../entity/Discuz.dart';
import '../entity/User.dart';
import '../generated/l10n.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../utility/NetworkUtils.dart';

class KeylolMobileTopicWidget extends StatelessWidget{
  final ValueChanged<int>? onSelectTid;

  KeylolMobileTopicWidget({super.key, this.onSelectTid});

  @override
  Widget build(BuildContext context) {
    return KeylolMobileTopicStatefulWidget(onSelectTid: this.onSelectTid,);
  }
}


class KeylolMobileTopicStatefulWidget extends StatefulWidget{
  final ValueChanged<int>? onSelectTid;

  KeylolMobileTopicStatefulWidget({super.key, this.onSelectTid});

  @override
  State<StatefulWidget> createState() {
    return KeylolMobileTopicState(onSelectTid: this.onSelectTid);
  }

}


class KeylolMobileTopicState extends State<KeylolMobileTopicStatefulWidget>{

  final ValueChanged<int>? onSelectTid;

  KeylolMobileTopicState({this.onSelectTid});

  bool isLoading = true;
  //List<KeylolPortalThreadItem> keylolPortalThreadList = [];
  List<List<KeylolPortalThreadItem>> keylolPortalThreadList_list = [];
  List<String> mobileTopicTitleList = [];



  @override
  void initState() {
    super.initState();
    //  start to fetch it
    _loadThreadSlideShow();


  }

  String keylolBaseUrl = "https://keylol.com";


  Future<void> _loadThreadSlideShow() async {
    User? _user = Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
    final dio = await NetworkUtils.getDioWithPersistCookieJar(_user);


    dio.get(keylolBaseUrl).then((html){
        var document = parse(html.data);
        print("document ->  ${html}");

        List<String> mobileTopicTitleList = [];

        // parse the titletext first
        var slideTitleTextList = document.getElementsByClassName("titletext");
        print("Get slide title length ${slideTitleTextList.length}");
        for(var slideTitleText in slideTitleTextList){
          var slideTitleLink = slideTitleText.getElementsByTagName("a").firstOrNull;
          if(slideTitleLink != null){
            mobileTopicTitleList.add(slideTitleLink.innerHtml);
          }
        }

        //print("Get mobile topic ${mobileTopicTitleList.length}");


        var slideshowElementList= document.getElementsByClassName("module cl xl xl1");
        //print("Get tb-c length ${slideshowElementList.length}");
        int cnt = 0;

        for(var tabElement in slideshowElementList){
          List<KeylolPortalThreadItem> keylolPortalThreadList = [];
          var listItemList = tabElement.getElementsByTagName("li");

          //print("Get listItem li ${listItemList.length}");
          for (var listItem in listItemList){
            var threadLinkList = listItem.getElementsByTagName("a");
            //print("Get link from thread ${threadLinkList.length}");
            if(threadLinkList.length != 3){
              continue;
            }
            var usernameNode = threadLinkList[0];
            var forumNode = threadLinkList[1];
            var threadNode = threadLinkList[2];
            var thread_title = threadNode.attributes["title"];
            String authorLink = usernameNode.attributes["href"] == null? "": usernameNode.attributes["href"]!;
            if(thread_title == null || authorLink.isEmpty){
              continue;
            }
            List<String> title_split_list = thread_title.split("\n");
            String link = threadNode.attributes["href"] == null? "": threadNode.attributes["href"]!;
            //print("title split list ${title_split_list.length}");
            if(title_split_list.length < 4 || link.isEmpty){
              continue;
            }
            String forum = title_split_list[0].split(":").last;
            String author = usernameNode.innerHtml;

            RegExp authorPidRegExp = RegExp(r'suid-(\d+)');
            RegExpMatch? match = authorPidRegExp.firstMatch(authorLink);
            if(match == null || match.groupCount != 1){
              continue;
            }
            String authorPidString = match.group(1) == null? "": match.group(1)!;
            int authorPid = int.tryParse(authorPidString) == null? 0: int.parse(authorPidString);

            RegExp tidRegExp = RegExp(r't(\d+)');
            RegExpMatch? tidMatch = tidRegExp.firstMatch(link);
            if(tidMatch == null || tidMatch.groupCount != 1){
              continue;
            }
            String tidString = tidMatch.group(1) == null? "": tidMatch.group(1)!;
            int tid = int.tryParse(tidString) == null? 0: int.parse(tidString);

            //author = title_split_list[1].split(":").last;
            String lastPoster = title_split_list[3].split(":").last;
            RegExp removeTagRegExp = RegExp(r'<.*?>');
            String title = threadNode.innerHtml.replaceAll(removeTagRegExp, "");

            KeylolPortalThreadItem keylolPortalThreadItem = KeylolPortalThreadItem(title, forum, author, authorPid, tid, link, lastPoster);
            keylolPortalThreadList.add(keylolPortalThreadItem);
          }
          keylolPortalThreadList_list.add(keylolPortalThreadList);
          cnt += 1;
        }
        setState(() {
          this.mobileTopicTitleList = mobileTopicTitleList;
          this.keylolPortalThreadList_list = keylolPortalThreadList_list;
        });

    });
  }

  @override
  Widget build(BuildContext context) {

    return Consumer<DiscuzAndUserNotifier>(
        builder: (context, value, child) {
          if(value.discuz == null){
            return Container();
          }
          else{
            Uri uri = Uri.parse(value.discuz!.baseURL);
            if(uri.host != "keylol.com"){
              // server doesn't have another site support
              return Container();
            }
            else{
              if(mobileTopicTitleList.isEmpty){
                return EmptyScreen();
              }
              else{
                return renderKeylolMobileTopicDashboard();
              }


            }
          }
        });
  }

  Widget renderKeylolMobileTopicDashboard(){
    return DefaultTabController(
        length: mobileTopicTitleList.length,
        child: Column(
          children: [
            TabBar(
              isScrollable: true,
              tabs: mobileTopicTitleList.map((e) => Tab(text: e,)).toList(),
              labelColor: Theme.of(context).colorScheme.primary,
              indicatorColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).brightness == Brightness.light?  Colors.black54 : Colors.white54,
              unselectedLabelStyle: Theme.of(context).brightness == Brightness.light? Theme.of(context).textTheme.bodyMedium: Theme.of(context).textTheme.titleMedium,
            ),
            Expanded(
              child: TabBarView(
                  children: keylolPortalThreadList_list.map(
                          (e) => ListView.builder(
                            itemCount: e.length,
                              itemBuilder: (context, index) => renderKeylolMobileTopicThread(e[index])
                          )
                  ).toList()

              ),
            )
          ],
        )
    );
  }

  Widget renderKeylolMobileTopicThread(KeylolPortalThreadItem threadItem){
    ThreadType threadType = ThreadType();
    threadType.idNameMap = {"0": threadItem.forum};
    ForumThread _forumThread = threadItem.convertToForumThread();
    Discuz? _discuz = Provider.of<DiscuzAndUserNotifier>(context).discuz;
    User? _user = Provider.of<DiscuzAndUserNotifier>(context).user;
    if(_discuz == null){
      return Container();
    }
    return ForumThreadWidget(_discuz!, _user, _forumThread, threadType, onSelectTid);
  }

}

class KeylolPortalThreadItem{
  String title = "";
  String forum = "";
  String author = "";
  int authorId = 0;
  int tid = 0;
  String link = "";
  String lastPoster = "";

  KeylolPortalThreadItem(this.title, this.forum, this.author, this.authorId, this.tid, this.link, this.lastPoster);

  ForumThread convertToForumThread(){
    ForumThread forumThread = ForumThread();
    forumThread.authorId = authorId.toString();
    forumThread.author = author;
    forumThread.subject = title;
    forumThread.tid = tid.toString();

    return forumThread;
  }
}