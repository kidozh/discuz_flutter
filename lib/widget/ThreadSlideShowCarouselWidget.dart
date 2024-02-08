

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:discuz_flutter/JsonResult/ThreadSlideShowResult.dart';
import 'package:discuz_flutter/utility/AppPlatformIcons.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
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
  ThreadSlideShowResult threadSlideShowResult = ThreadSlideShowResult();

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

  String pushServerBaseUrl = "https://dhp.kidozh.com";

  Future<void> _loadThreadSlideShow() async {
    final dio = await NetworkUtils.getDioWithPersistCookieJar(null);
    final client = PushServiceClient(dio, baseUrl: pushServerBaseUrl);

    client.getThreadSlideShowResultByHost("keylol.com").then((value){
      setState(() {
        isLoading = false;
      });
      if(value.isSuccess()){
        // set it
        setState(() {
          threadSlideShowResult = value;
        });

      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
    // TODO: implement build
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
              return Padding(
                padding: EdgeInsets.only(top: 16),
                child: CarouselSlider.builder(
                  itemCount: threadSlideShowResult.slideshow_list.length +1,
                  itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex){
                    if(itemIndex == 0){
                      return subscriptionSlide;
                    }
                    else{
                      return getSlideShowItemWidget(itemIndex -1);
                    }
                  },
                  options: carouselOptions,

                ),
              );

            }
          }
        });
  }

  double slideHeight = 180;

  get subscriptionSlide => InkWell(
    child: Container(
      height: slideHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        color: Theme.of(context).colorScheme.primary,
      ),
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(

          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.update_outlined, color: Theme.of(context).colorScheme.onPrimary, size: 32,),
            SizedBox(height: 16,),
            Text(S.of(context).subscribeChannelForMore,
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
      await Navigator.push(context,platformPageRoute(context:context,builder: (context) => SubscribeChannelPage()));

    },
  );

  Widget getSlideShowItemWidget(int itemIndex){
    SlideShow slideShow = threadSlideShowResult.slideshow_list[itemIndex];

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
                    SizedBox(height: 48,),
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
        if(onSelectTid != null){
          return onSelectTid!(slideShow.tid);
        }

        if(discuz != null){

          await Navigator.push(
              context,
              platformPageRoute(context:context,builder: (context) => ViewThreadSliverPage(discuz,  user, slideShow.tid,
                passedSubject: slideShow.title,
              ))
          );
        }

      },
    );
  }

}