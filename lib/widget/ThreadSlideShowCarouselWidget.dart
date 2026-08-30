

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
    try {
      final dio = await NetworkUtils.getDioWithPersistCookieJar(null);
      final html = await dio.get(keylolBaseUrl);
      final document = parse(html.data);
      final carouselItems = <KeylolCarouselItem>[];
      final slideshowElements = document.getElementsByClassName("slideshow");

      if (slideshowElements.isNotEmpty) {
        final slides = slideshowElements.first.getElementsByTagName("li");
        for (final slideListItem in slides) {
          final anchors = slideListItem.getElementsByTagName("a");
          if (anchors.isEmpty) continue;

          final slide = anchors.first;
          final link = slide.attributes["href"];
          final images = slide.getElementsByTagName("img");
          if (images.isEmpty || link == null) continue;

          final imageSource = images.first.attributes["src"];
          final imageTitle = images.first.attributes["title"];
          final titleElements = slideListItem.getElementsByClassName("title");
          if (titleElements.isEmpty ||
              titleElements.first.innerHtml.isEmpty ||
              imageSource == null ||
              imageTitle == null) {
            continue;
          }

          final titleParts = imageTitle.split("\n");
          if (titleParts.length < 3) continue;

          carouselItems.add(KeylolCarouselItem(
            imageSource,
            titleElements.first.innerHtml,
            titleParts[0].split(":").last,
            titleParts[1].split(":").last,
            titleParts[2].split(":").last,
            0,
            link,
          ));
        }
      }

      if (!mounted) return;
      setState(() {
        keylolCarouselItemList = carouselItems;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        keylolCarouselItemList = [];
        isLoading = false;
      });
    }
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
                return isLoading
                    ? subscriptionSlide
                    : const SizedBox.shrink();
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
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: light
                            ? [
                                Colors.white.withValues(alpha: 0.42),
                                Colors.white.withValues(alpha: 0.16),
                              ]
                            : [
                                Colors.black.withValues(alpha: 0.30),
                                colors.surface.withValues(alpha: 0.16),
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
