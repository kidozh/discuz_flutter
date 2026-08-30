

import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:html/parser.dart';
import 'package:provider/provider.dart';

import '../entity/Discuz.dart';
import '../generated/l10n.dart';
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
                  padding: EdgeInsets.only(top: 8),
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

  Widget get subscriptionSlide => Semantics(
        label: S.of(context).loading,
        child: PlatformLiquidGlassCard(
          margin: const EdgeInsets.all(8),
          tintColor: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(22),
          child: SizedBox(
            height: slideHeight,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PlatformCircularProgressIndicator(
                  material: (context, platform) =>
                      MaterialProgressIndicatorData(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  cupertino: (context, platform) =>
                      CupertinoProgressIndicatorData(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  S.of(context).loading,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget getSlideShowItemWidget(int itemIndex) {
    KeylolCarouselItem slideShow = keylolCarouselItemList[itemIndex];

    final light = Theme.of(context).brightness == Brightness.light;
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: '${slideShow.forum} ${slideShow.category} ${slideShow.title}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          VibrationUtils.vibrateWithClickIfPossible();
          Discuz? discuz =
              Provider.of<DiscuzAndUserNotifier>(context, listen: false).discuz;
          if (slideShow.tid != 0 && onSelectTid != null) {
            return onSelectTid!(slideShow.tid);
          }

          if (discuz != null) {
            await URLUtils.openURL(
                context, onSelectTid, slideShow.link, (pid) {}, null);

            // await Navigator.push(
            //     context,
            //     platformPageRoute(context:context,builder: (context) => ViewThreadSliverPage(discuz,  user, slideShow.tid,
            //       passedSubject: slideShow.title,
            //     ))
            // );
          }
        },
        child: PlatformLiquidGlassCard(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          borderRadius: BorderRadius.circular(22),
          child: SizedBox(
            height: slideHeight,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image(
                  image: CachedNetworkImageProvider(slideShow.image_src),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => ColoredBox(
                    color: colors.surfaceContainerHighest,
                  ),
                ),
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: light
                            ? [
                                Colors.white.withValues(alpha: 0.70),
                                Colors.white.withValues(alpha: 0.34),
                              ]
                            : [
                                Colors.black.withValues(alpha: 0.48),
                                colors.surface.withValues(alpha: 0.30),
                              ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slideShow.forum,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.primary,
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        slideShow.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.onSurface.withValues(alpha: 0.68),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        slideShow.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 18,
                          height: 1.16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.white.withValues(
                          alpha: light ? 0.52 : 0.18,
                        ),
                        width: 0.8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
