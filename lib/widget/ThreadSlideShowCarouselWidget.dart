import 'package:discuz_flutter/utility/pane_navigation.dart';
import '../provider/UserPreferenceNotifierProvider.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:provider/provider.dart';

import '../entity/Discuz.dart';
import '../generated/l10n.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../utility/NetworkUtils.dart';
import 'thread_carousel_card.dart';
import 'thread_carousel_layout.dart';

class ThreadSlideShowCarouselWidget extends StatefulWidget {
  final ThreadSelectionCallback? onSelectTid;
  final Future<List<KeylolCarouselItem>> Function()? loadItems;
  final ImageProvider Function(String)? imageProviderBuilder;

  const ThreadSlideShowCarouselWidget({
    super.key,
    this.onSelectTid,
    this.loadItems,
    this.imageProviderBuilder,
  });

  @override
  State<ThreadSlideShowCarouselWidget> createState() =>
      _ThreadSlideShowCarouselState();
}

class _ThreadSlideShowCarouselState
    extends State<ThreadSlideShowCarouselWidget> {
  bool isLoading = true;
  bool _imagesReady = false;
  List<KeylolCarouselItem> keylolCarouselItemList = [];

  @override
  void initState() {
    super.initState();
    _loadThreadSlideShow();
  }

  String keylolBaseUrl = "https://keylol.com";

  Future<void> _loadThreadSlideShow() async {
    try {
      final items = await (widget.loadItems?.call() ?? _fetchThreadSlideShow());
      if (!mounted) return;
      setState(() {
        keylolCarouselItemList = items;
        isLoading = false;
      });
      // A wide feed shows at most three cards. Do not start the timer while
      // their artwork is still loading; swiping remains available meanwhile.
      await Future.wait([
        for (final item in items.take(3))
          precacheImage(
            _imageProvider(item.imageSource),
            context,
            onError: (_, _) {},
          ),
      ]);
      if (!mounted) return;
      setState(() => _imagesReady = true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        keylolCarouselItemList = [];
        isLoading = false;
      });
    }
  }

  ImageProvider _imageProvider(String source) =>
      widget.imageProviderBuilder?.call(source) ??
      CachedNetworkImageProvider(source);

  Future<List<KeylolCarouselItem>> _fetchThreadSlideShow() async {
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

    return carouselItems;
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
                itemCount: keylolCarouselItemList.length,
                itemBuilder: (context, index) => isLoading
                    ? subscriptionSlide
                    : getSlideShowItemWidget(index),
                compact: compact,
                isLoading: isLoading,
                autoPlay: _imagesReady,
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
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: EdgeInsets.all(compact ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _placeholderBar(width: 64, height: 20),
            const Spacer(),
            _placeholderBar(width: 90, height: 12),
            const SizedBox(height: 10),
            _placeholderBar(height: 17),
            const SizedBox(height: 8),
            FractionallySizedBox(
              widthFactor: 0.65,
              child: _placeholderBar(height: 17),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _placeholderBar({double? width, required double height}) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(6),
    ),
  );

  Widget getSlideShowItemWidget(int itemIndex) {
    KeylolCarouselItem slideShow = keylolCarouselItemList[itemIndex];

    return ThreadCarouselCard(
      image: _imageProvider(slideShow.imageSource),
      forum: slideShow.forum,
      category: slideShow.category,
      title: slideShow.title,
      compact: compact,
      onTap: () async {
        VibrationUtils.vibrateWithClickIfPossible();
        final onSelectTid = widget.onSelectTid;
        Discuz? discuz = Provider.of<DiscuzAndUserNotifier>(
          context,
          listen: false,
        ).discuz;
        if (slideShow.tid != 0 && onSelectTid != null) {
          return onSelectTid(slideShow.tid, subject: slideShow.title);
        }

        if (discuz != null) {
          await URLUtils.openURL(
            context,
            onSelectTid,
            slideShow.link,
            (pid) {},
            null,
            subject: slideShow.title,
          );
        }
      },
    );
  }
}

class KeylolCarouselItem {
  final String imageSource;
  final String title;
  final String forum;
  final String category;
  final String author;
  final int tid;
  final String link;

  const KeylolCarouselItem(
    this.imageSource,
    this.title,
    this.forum,
    this.category,
    this.author,
    this.tid,
    this.link,
  );
}
