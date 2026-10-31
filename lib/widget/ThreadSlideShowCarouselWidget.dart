import '../provider/UserPreferenceNotifierProvider.dart';

import 'package:cached_network_image/cached_network_image.dart';
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
import 'thread_carousel_card.dart';
import 'thread_carousel_layout.dart';

class ThreadSlideShowCarouselWidget extends StatelessWidget {
  final ValueChanged<int>? onSelectTid;

  ThreadSlideShowCarouselWidget({super.key, this.onSelectTid});

  @override
  Widget build(BuildContext context) {
    return ThreadSlideShowCarouselStatefulWidget(onSelectTid: this.onSelectTid);
  }
}

class ThreadSlideShowCarouselStatefulWidget extends StatefulWidget {
  final ValueChanged<int>? onSelectTid;

  ThreadSlideShowCarouselStatefulWidget({super.key, this.onSelectTid});

  @override
  State<StatefulWidget> createState() {
    return ThreadSlideShowCarouselState(onSelectTid: this.onSelectTid);
  }
}

class ThreadSlideShowCarouselState
    extends State<ThreadSlideShowCarouselStatefulWidget> {
  final ValueChanged<int>? onSelectTid;

  ThreadSlideShowCarouselState({this.onSelectTid});

  bool isLoading = true;
  List<KeylolCarouselItem> keylolCarouselItemList = [];

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

          carouselItems.add(
            KeylolCarouselItem(
              imageSource,
              titleElements.first.innerHtml,
              titleParts[0].split(":").last,
              titleParts[1].split(":").last,
              titleParts[2].split(":").last,
              0,
              link,
            ),
          );
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
        if (value.discuz == null) {
          return Container();
        } else {
          Uri uri = Uri.parse(value.discuz!.baseURL);
          if (uri.host != "keylol.com") {
            // server doesn't have another site support
            return Container();
          } else {
            if (keylolCarouselItemList.isEmpty && !isLoading) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ThreadCarouselLayout(
                itemCount: isLoading ? 1 : keylolCarouselItemList.length,
                itemBuilder: (context, index) => isLoading
                    ? subscriptionSlide
                    : getSlideShowItemWidget(index),
                compact: compact,
              ),
            );
          }
        }
      },
    );
  }

  bool get compact => context
      .watch<UserPreferenceNotifierProvider>()
      .forumDisplay
      .compactCarousel;
  Widget get subscriptionSlide => Semantics(
    label: S.of(context).loading,
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PlatformCircularProgressIndicator(
            material: (context, platform) => MaterialProgressIndicatorData(
              color: Theme.of(context).colorScheme.primary,
            ),
            cupertino: (context, platform) => CupertinoProgressIndicatorData(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            S.of(context).loading,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: compact ? 12 : 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );

  Widget getSlideShowItemWidget(int itemIndex) {
    KeylolCarouselItem slideShow = keylolCarouselItemList[itemIndex];

    return ThreadCarouselCard(
      image: CachedNetworkImageProvider(slideShow.image_src),
      forum: slideShow.forum,
      category: slideShow.category,
      title: slideShow.title,
      compact: compact,
      onTap: () async {
        VibrationUtils.vibrateWithClickIfPossible();
        Discuz? discuz = Provider.of<DiscuzAndUserNotifier>(
          context,
          listen: false,
        ).discuz;
        if (slideShow.tid != 0 && onSelectTid != null) {
          return onSelectTid!(slideShow.tid);
        }

        if (discuz != null) {
          await URLUtils.openURL(
            context,
            onSelectTid,
            slideShow.link,
            (pid) {},
            null,
          );
        }
      },
    );
  }
}

class KeylolCarouselItem {
  String image_src = "";
  String title = "";
  String forum = "";
  String category = "";
  String author = "";
  int tid = 0;
  //String date = "";
  String link = "";

  KeylolCarouselItem(
    this.image_src,
    this.title,
    this.forum,
    this.category,
    this.author,
    this.tid,
    this.link,
  );
}
