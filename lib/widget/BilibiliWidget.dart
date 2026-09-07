import 'package:discuz_flutter/utility/app_motion.dart';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/JsonResult/BilibiliDynamicDetailResult.dart';
import 'package:discuz_flutter/JsonResult/BilibiliVideoResult.dart';
import 'package:discuz_flutter/client/BilibiliApiClient.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:discuz_flutter/utility/WbiSign.dart';
import 'package:flutter/material.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'cupertino_media_outline.dart';

enum BilibiliWidgetType { video, live, opus }

enum BilibiliVideoRequestType { aid, bvid }

class BilibiliWidget extends StatefulWidget {
  final String url;

  const BilibiliWidget(this.url, {super.key});

  @override
  State<BilibiliWidget> createState() => BilibiliVideoState(url);
}

class BilibiliVideoState extends State<BilibiliWidget> {
  String url;

  BilibiliVideoState(this.url);

  BilibiliWidgetType type = BilibiliWidgetType.video;
  BilibiliVideoRequestType videoRequestType = BilibiliVideoRequestType.bvid;
  String videoRequestParameter = "";
  BilibiliVideoResult videoResult = BilibiliVideoResult();
  BilibiliDynamicDetailResult opusResult = BilibiliDynamicDetailResult();

  bool isLoadingApi = false;

  Uri? uri;

  @override
  void initState() {
    super.initState();
    parseUrl();
  }

  int _requestVersion = 0;

  @override
  void didUpdateWidget(covariant BilibiliWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      ++_requestVersion;
      url = widget.url;
      uri = null;
      type = BilibiliWidgetType.video;
      videoRequestParameter = '';
      videoRequestType = BilibiliVideoRequestType.bvid;
      videoResult = BilibiliVideoResult();
      opusResult = BilibiliDynamicDetailResult();
      isLoadingApi = false;
      parseUrl();
    }
  }

  void parseUrl() {
    Uri? bilibiliUri = Uri.tryParse(url);
    if (bilibiliUri != null) {
      setState(() {
        uri = bilibiliUri;
      });
      log("Get Bilibili URL ${url}, host: ${bilibiliUri.host}, path: ${bilibiliUri.path}, split: ${bilibiliUri.path.split("/")}");

      // not the live
      if (bilibiliUri.host == "live.bilibili.com") {
        type = BilibiliWidgetType.live;
      } else if (bilibiliUri.path.startsWith("/opus")) {
        type = BilibiliWidgetType.opus;
        List<String> urlPathList = bilibiliUri.path.split("/");
        List<String> urlPathFilteredList = urlPathList
            .where((i) => i != "/" && i.isNotEmpty && i != "opus")
            .toList();
        if (urlPathFilteredList.isEmpty) return;
        String videoParameterAtLast = urlPathFilteredList.last;
        if (int.tryParse(videoParameterAtLast) != null) {
          videoRequestParameter = videoParameterAtLast;
        }
        log("load bilibili OPUS information ${url} with ${videoRequestParameter} from list : ${urlPathFilteredList}");
        if (videoRequestParameter.isNotEmpty) loadBilibiliVideoApi();
      } else if (bilibiliUri.path.startsWith("/video")) {
        type = BilibiliWidgetType.video;
        // judge whether it's bvid or avid
        List<String> urlPathList = bilibiliUri.path.split("/");
        // remove unneccessary slash
        List<String> urlPathFilteredList = urlPathList
            .where((i) => i != "/" && i.isNotEmpty && i != "video")
            .toList();
        if (urlPathFilteredList.isEmpty) return;
        String videoParameterAtLast = urlPathFilteredList.last;

        if (videoParameterAtLast.startsWith('av')) {
          videoParameterAtLast = videoParameterAtLast.substring(2);
        }
        if (int.tryParse(videoParameterAtLast) != null) {
          videoRequestType = BilibiliVideoRequestType.aid;
        }
        if (int.tryParse(videoParameterAtLast) == null &&
            !RegExp(r'^BV[0-9A-Za-z]+$').hasMatch(videoParameterAtLast)) return;
        videoRequestParameter = videoParameterAtLast;
        // start fetch it?
        log("load bilibili information ${url} with ${videoRequestParameter} from list : ${urlPathFilteredList}");
        loadBilibiliVideoApi();
      }
    }
  }

  Future<void> loadBilibiliVideoApi() async {
    if (!mounted || videoRequestParameter.isEmpty) return;
    final version = ++_requestVersion;
    final requestType = type;
    final parameter = videoRequestParameter;
    final byAid = videoRequestType == BilibiliVideoRequestType.aid;
    setState(() => isLoadingApi = true);
    try {
      final dio = await NetworkUtils.getDioWithPersistCookieJar(null);
      if (!mounted || version != _requestVersion) return;
      final client =
          BilibiliApiClient(dio, baseUrl: 'https://api.bilibili.com');
      switch (requestType) {
        case BilibiliWidgetType.video:
          final result = byAid
              ? await client.getVideoResultByAid(parameter)
              : await client.getVideoResultByBvid(parameter);
          if (!mounted || version != _requestVersion) return;
          setState(() => videoResult = result);
        case BilibiliWidgetType.opus:
          final queries = await WbiSign().makSign({'id': int.parse(parameter)});
          if (!mounted || version != _requestVersion) return;
          final result = await client.getOpusDynamicResultByIdInMaps(queries);
          if (!mounted || version != _requestVersion) return;
          setState(() => opusResult = result);
        case BilibiliWidgetType.live:
          break;
      }
    } catch (error) {
      log('Unable to load Bilibili preview: $error');
    } finally {
      if (mounted && version == _requestVersion) {
        setState(() => isLoadingApi = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => AppContentTransition(
        child: KeyedSubtree(
          key: ValueKey(
              '$url:${videoResult.data.viewData.pic}:${opusResult.data.item.modules.moduleAuthor.name}:${opusResult.data.item.modules.moduleDynamic.desc.text}'),
          child: _buildContent(context),
        ),
      );

  Widget _buildContent(BuildContext context) {
    if (uri == null) {
      return Text("Not a valid Bilibili link ${url}");
    } else if (type == BilibiliWidgetType.video &&
        videoResult.data.viewData.pic.isNotEmpty) {
      return bilibiliVideoPreviewWidget;
    } else if (type == BilibiliWidgetType.opus &&
        opusResult.code == 0 &&
        (opusResult.data.item.modules.moduleAuthor.name.isNotEmpty ||
            opusResult.data.item.modules.moduleDynamic.desc.text.isNotEmpty)) {
      return bilibiliOpusPreviewWidget;
    }

    return bilibiliDefaultWidget;
  }

  static const int bilibiliColorPink = 0xFFFB7299;
  static const int bilibiliColorGray = 0xFFF4F4F4;

  Color get _bilibiliPink => const Color(bilibiliColorPink);

  void _openBilibili() {
    VibrationUtils.vibrateWithClickIfPossible();
    URLUtils.openURL(context, null, url, null, null);
  }

  Widget _interactiveSurface({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(12),
  }) {
    final content = Semantics(
      button: true,
      label: '在哔哩哔哩中打开',
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: _openBilibili,
        child: Padding(padding: padding, child: child),
      ),
    );

    return PlatformWidgetBuilder(
      child: content,
      material: (_, child, __) => PlatformCard(
        elevation: 4,
        child: child,
      ),
      cupertino: (_, child, __) => CupertinoMediaOutline(
        borderRadius: BorderRadius.circular(22),
        child: PlatformLiquidGlassCard(
          borderRadius: BorderRadius.circular(22),
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _glassPill({
    required Widget child,
    bool onMedia = false,
  }) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final background = onMedia
        ? Colors.black.withValues(alpha: 0.48)
        : _bilibiliPink.withValues(alpha: dark ? 0.26 : 0.14);
    final border = onMedia
        ? Colors.white.withValues(alpha: 0.30)
        : _bilibiliPink.withValues(alpha: dark ? 0.48 : 0.28);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border, width: 0.7),
        boxShadow: usesAppleTranslucentSurface(context)
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: onMedia ? 0.20 : 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: child,
      ),
    );
  }

  Widget _avatar(String imageUrl, {double size = 26}) {
    final fallback = ColoredBox(
      color: _bilibiliPink.withValues(alpha: 0.18),
      child: Center(
        child: Icon(
          PlatformIcons(context).person,
          size: size * 0.56,
          color: _bilibiliPink,
        ),
      ),
    );

    return PlatformLiquidGlassAvatar(
      size: size,
      child: imageUrl.isEmpty
          ? fallback
          : CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => fallback,
            ),
    );
  }

  Widget _videoCover() {
    final viewData = videoResult.data.viewData;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: viewData.pic,
              fit: BoxFit.cover,
              placeholder: (_, __) => ColoredBox(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Center(child: PlatformCircularProgressIndicator()),
              ),
              errorWidget: (_, __, ___) => ColoredBox(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Icon(
                  PlatformIcons(context).unavailableImage,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0x66000000)],
                  stops: [0.55, 1],
                ),
              ),
            ),
            Positioned(
              left: 8,
              top: 8,
              child: _glassPill(
                onMedia: true,
                child: const FaIcon(
                  FontAwesomeIcons.bilibili,
                  size: 13,
                  color: Colors.white,
                ),
              ),
            ),
            if (viewData.duration > 0)
              Positioned(
                right: 8,
                bottom: 8,
                child: _glassPill(
                  onMedia: true,
                  child: Text(
                    _formatDuration(viewData.duration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _videoDetails() {
    final viewData = videoResult.data.viewData;
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (viewData.tname.isNotEmpty)
          _glassPill(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  PlatformIcons(context).playCircleSolid,
                  size: 12,
                  color: _bilibiliPink,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    viewData.tname,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _bilibiliPink,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (viewData.tname.isNotEmpty) const SizedBox(height: 8),
        Text(
          viewData.title,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 15,
            height: 1.22,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 9),
        Row(
          children: [
            _avatar(viewData.owner.face),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                viewData.owner.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 12.5,
                ),
              ),
            ),
            Icon(
              PlatformIcons(context).forward,
              size: 15,
              color: colors.onSurfaceVariant.withValues(alpha: 0.72),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secs = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (duration.inHours > 0) {
      return '${duration.inHours}:$minutes:$secs';
    }
    return '$minutes:$secs';
  }

  Widget get bilibiliDefaultWidget => _interactiveSurface(
        child: Row(
          children: [
            SizedBox.square(
              dimension: 42,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: _bilibiliPink.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _bilibiliPink.withValues(alpha: 0.32),
                  ),
                ),
                child: Center(
                  child: isLoadingApi
                      ? SizedBox.square(
                          dimension: 19,
                          child: PlatformCircularProgressIndicator(),
                        )
                      : FaIcon(
                          FontAwesomeIcons.bilibili,
                          size: 20,
                          color: _bilibiliPink,
                        ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isLoadingApi ? '正在载入哔哩哔哩内容' : '哔哩哔哩链接',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    url,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              PlatformIcons(context).forward,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      );

  Widget get bilibiliVideoPreviewWidget => _interactiveSurface(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 330) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _videoCover(),
                  const SizedBox(height: 12),
                  _videoDetails(),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 9, child: _videoCover()),
                const SizedBox(width: 12),
                Expanded(flex: 10, child: _videoDetails()),
              ],
            );
          },
        ),
      );

  Widget get bilibiliOpusPreviewWidget {
    final author = opusResult.data.item.modules.moduleAuthor;
    final description = opusResult.data.item.modules.moduleDynamic.desc.text;
    final colors = Theme.of(context).colorScheme;
    return _interactiveSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _avatar(author.face, size: 38),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      author.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (author.pubTime.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        author.pubTime,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _glassPill(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.bilibili,
                      size: 12,
                      color: _bilibiliPink,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '动态',
                      style: TextStyle(
                        color: _bilibiliPink,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              description,
              maxLines: 8,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 14,
                height: 1.42,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class BilibiliArticlePreviewState extends State<BilibiliWidget> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
