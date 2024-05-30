

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:discuz_flutter/JsonResult/ThreadSlideShowResult.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:html/parser.dart';
import 'package:provider/provider.dart';

import '../client/PushServiceClient.dart';
import '../entity/Discuz.dart';
import '../entity/User.dart';
import '../generated/l10n.dart';
import '../page/SubscribeChannelPage.dart';
import '../page/ViewThreadSliverPage.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../utility/NetworkUtils.dart';

class ThreadSlideShowCarouselWidget extends StatelessWidget{
  final ValueChanged<int>? onSelectTid;

  ThreadSlideShowCarouselWidget({super.key, this.onSelectTid});

  @override
  Widget build(BuildContext context) {
    return ThreadSlideShowCarouselStatefulWidget(onSelectTid: this.onSelectTid,);
  }
}


class ThreadSlideShowCarouselStatefulWidget extends StatefulWidget{
  final ValueChanged<int>? onSelectTid;

  ThreadSlideShowCarouselStatefulWidget({super.key, this.onSelectTid});

  @override
  State<StatefulWidget> createState() {
    return ThreadSlideShowCarouselState(onSelectTid: this.onSelectTid);
  }

}


class ThreadSlideShowCarouselState extends State<ThreadSlideShowCarouselStatefulWidget>{

  final ValueChanged<int>? onSelectTid;

  ThreadSlideShowCarouselState({this.onSelectTid});

  bool isLoading = true;
  List<KeylolCarouselItem> keylolCarouselItemList = [];

  CarouselOptions carouselOptions = CarouselOptions(
    height: 200,
    aspectRatio: 16/9,
    viewportFraction: 0.8,
    initialPage: 0,
    enableInfiniteScroll: true,
    reverse: false,
    autoPlay: true,
    autoPlayInterval: Duration(seconds: 3),
    autoPlayAnimationDuration: Duration(milliseconds: 800),
    autoPlayCurve: Curves.fastOutSlowIn,
    enlargeCenterPage: true,
    enlargeFactor: 0.3,
    // trigger set none
    onPageChanged: null,
    scrollDirection: Axis.horizontal,
  );



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //  start to fetch it
    _loadThreadSlideShow();


  }

  String keylolBaseUrl = "https://keylol.com";


  Future<void> _loadThreadSlideShow() async {
    final dio = await NetworkUtils.getDioWithPersistCookieJar(null);


    dio.get(keylolBaseUrl).then((html){
        var document = parse(html.data);
        //print("document ->  ${document}");
        List<KeylolCarouselItem> carouselItemList = [];

        var slideshowElementList= document.getElementsByClassName("slideshow");
        //print("Get slide show length ${slideshowElementList.length}");
        if(slideshowElementList.length >= 1){

          var slideshowELement = slideshowElementList.first;
          var slideshow = slideshowELement.getElementsByTagName("li");
          for(var slide_li in slideshow){
            var slide_a_list = slide_li.getElementsByTagName("a");
            if(slide_a_list.isEmpty){
              continue;
            }
            var slide = slide_a_list.first;
            String? link = slide.attributes["href"];
            var img_element_list = slide.getElementsByTagName("img");
            //print("Get img element link ${link}");
            if(img_element_list.isEmpty || link == null){
              continue;
            }
            else{
              var img_element = img_element_list.first;
              String? img_src = img_element.attributes["src"];
              String? img_title = img_element.attributes["title"];
              var span_title = slide_li.getElementsByClassName("title");
              //print("Get img element detail ${img_src} ${img_title} ${span_title}");
              if(span_title.isEmpty ||
                  span_title.first.innerHtml.isEmpty ||
                  img_src == null ||
                  img_title == null){
                continue;
              }
              else{
                // parse the title by regex
                List<String> title_split_list = img_title.split("\n");
                if(title_split_list.length < 3){
                  continue;
                }
                String forum = title_split_list[0].split(":").last;
                String category = title_split_list[1].split(":").last;
                String author = title_split_list[2].split(":").last;
                // get tid


                String title = span_title.first.innerHtml;
                carouselItemList.add(
                    KeylolCarouselItem(
                  img_src, title, forum, category, author, 0, link
                ));

              }
            }

          }
          //print("Set carousel item length-> ${carouselItemList.length}");

          setState(() {
            keylolCarouselItemList = carouselItemList;
          });
        }
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
              if(keylolCarouselItemList.isEmpty){
                return subscriptionSlide;
              }
              else{
                return Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: CarouselSlider.builder(
                    itemCount: keylolCarouselItemList.length,
                    itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex){
                      return getSlideShowItemWidget(itemIndex);
                    },
                    options: carouselOptions,

                  ),
                );
              }


            }
          }
        });
  }

  double slideHeight = 180;

  get subscriptionSlide => InkWell(
    child: Container(
      margin: EdgeInsets.all(8.0),

      height: slideHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        color: Theme.of(context).colorScheme.primary,
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(

          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            PlatformCircularProgressIndicator(
              material: (context, platform) => MaterialProgressIndicatorData(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              cupertino: (context, platform) => CupertinoProgressIndicatorData(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            SizedBox(height: 16,),
            Text(S.of(context).loading,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 16
              ),
            )
          ],
        ),
      ),
    ),
    onTap: () async{
      VibrationUtils.vibrateWithClickIfPossible();
      // await Navigator.push(context,platformPageRoute(context:context,builder: (context) => SubscribeChannelPage()));

    },
  );

  Widget getSlideShowItemWidget(int itemIndex){
    KeylolCarouselItem slideShow = keylolCarouselItemList[itemIndex];

    return InkWell(
      child: Column(
        children: [
          Container(
            height: slideHeight,
            width: double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),

                image: DecorationImage(
                  fit: BoxFit.cover,
                  colorFilter: Theme.of(context).brightness == Brightness.light?
                  ColorFilter.mode(Color(0xD3FFFFFF), BlendMode.lighten):
                  ColorFilter.mode(Color(0xFF3D3D3D), BlendMode.darken),

                  image: CachedNetworkImageProvider(
                      slideShow.image_src
                  ),

                )
            ),
            child: ClipRect(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: Column(
                  //direction: Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(slideShow.forum+" ",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 36,
                          fontWeight: FontWeight.bold
                      ),
                      maxLines: 1,

                    ),
                    Text(" "+slideShow.category,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 18),
                      maxLines: 1,

                    ),
                    SizedBox(height: 44,),
                    Text(slideShow.title,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Theme.of(context).textTheme.displayLarge?.color,
                          fontSize: 18
                      ),
                      maxLines: 1,
                    )
                  ],

                ),
              ),
            ),
          ),

        ],
      ),
      onTap: () async{
        VibrationUtils.vibrateWithClickIfPossible();
        Discuz? discuz = Provider.of<DiscuzAndUserNotifier>(context, listen: false).discuz;
        User? user = Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
        if(slideShow.tid!= 0 && onSelectTid != null){
          return onSelectTid!(slideShow.tid);
        }

        if(discuz != null){
          await URLUtils.openURL(context, onSelectTid, slideShow.link, (pid) { }, null);

          // await Navigator.push(
          //     context,
          //     platformPageRoute(context:context,builder: (context) => ViewThreadSliverPage(discuz,  user, slideShow.tid,
          //       passedSubject: slideShow.title,
          //     ))
          // );
        }

      },
    );
  }

}

class KeylolCarouselItem{
  String image_src = "";
  String title = "";
  String forum = "";
  String category = "";
  String author = "";
  int tid = 0;
  //String date = "";
  String link = "";

  KeylolCarouselItem(this.image_src, this.title, this.forum, this.category,
      this.author, this.tid, this.link);
}