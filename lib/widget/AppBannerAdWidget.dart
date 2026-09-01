import 'dart:math' as math;

import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/provider/UserPreferenceNotifierProvider.dart';
import 'package:discuz_flutter/utility/AdHelper.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

/// A responsive banner ad presented as a first-party list card.
///
/// The Google creative remains untouched so clicks and impression tracking are
/// still handled entirely by the ads SDK. Only the surrounding surface,
/// attribution and loading state are rendered by the app.
class AppBannerAdWidget extends StatefulWidget {
  const AppBannerAdWidget({super.key});

  @override
  State<AppBannerAdWidget> createState() => _AppBannerAdState();
}

class _AppBannerAdState extends State<AppBannerAdWidget> {
  static const double _horizontalMargin = 8;
  static const double _cardHorizontalPadding = 8;
  static const double _maximumCreativeWidth = 680;

  BannerAd? _bannerAd;
  AdSize? _adSize;
  int? _requestedWidth;
  bool _loadFailed = false;

  bool _isExempt(Discuz? discuz, String adExemptHost) {
    if (discuz == null) return false;
    final host = Uri.tryParse(discuz.baseURL)?.host;
    if (host == null || host.isEmpty) return false;
    return AdHelper.adWhiteDiscuzHostList.contains(host) ||
        adExemptHost == host;
  }

  void _ensureAdForWidth(int width) {
    if (width <= 0 || _requestedWidth == width) return;
    _requestedWidth = width;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _requestedWidth == width) _loadAd(width);
    });
  }

  Future<void> _loadAd(int width) async {
    if (!mounted || _requestedWidth != width) return;

    final previousAd = _bannerAd;
    _bannerAd = null;
    _adSize = null;
    setState(() {
      _loadFailed = false;
    });
    await previousAd?.dispose();

    final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width);
    if (!mounted || _requestedWidth != width) return;
    if (size == null) {
      setState(() {
        _loadFailed = true;
      });
      return;
    }

    final ad = BannerAd(
      adUnitId: AdHelper.bannerAdUnitTestId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (loadedAd) {
          if (!mounted || _requestedWidth != width) {
            loadedAd.dispose();
            return;
          }
          setState(() {
            _bannerAd = loadedAd as BannerAd;
            _adSize = size;
            _loadFailed = false;
          });
        },
        onAdFailedToLoad: (failedAd, error) {
          failedAd.dispose();
          if (!mounted || _requestedWidth != width) return;
          debugPrint('Adaptive banner failed to load: $error');
          setState(() {
            _bannerAd = null;
            _adSize = null;
            _loadFailed = true;
          });
        },
      ),
    );
    try {
      await ad.load();
    } catch (error) {
      await ad.dispose();
      if (!mounted || _requestedWidth != width) return;
      debugPrint('Adaptive banner could not start loading: $error');
      setState(() {
        _bannerAd = null;
        _adSize = null;
        _loadFailed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final discuz = context.watch<DiscuzAndUserNotifier>().discuz;
    final adExemptHost =
        context.watch<UserPreferenceNotifierProvider>().adExemptHost;
    if (_isExempt(discuz, adExemptHost)) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final creativeWidth = math.min(
          _maximumCreativeWidth,
          math.max(
            1,
            viewportWidth -
                (_horizontalMargin * 2) -
                (_cardHorizontalPadding * 2),
          ),
        );
        _ensureAdForWidth(creativeWidth.floor());

        if (_loadFailed) return const SizedBox.shrink();

        final ad = _bannerAd;
        final size = _adSize;
        final creative = ad != null && size != null
            ? SizedBox(
                key: const ValueKey('app-banner-ad-creative'),
                width: size.width.toDouble(),
                height: size.height.toDouble(),
                child: AdWidget(ad: ad),
              )
            : const _AdLoadingPlaceholder();

        return AppAdvertisementCard(
          title: S.of(context).googleAdTitle,
          subtitle: S.of(context).googleAdSubTitle,
          maximumWidth: creativeWidth + (_cardHorizontalPadding * 2),
          horizontalMargin: _horizontalMargin,
          contentPadding: _cardHorizontalPadding,
          child: creative,
        );
      },
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}

/// Visual shell shared by ad formats so an ad reads as an intentional list
/// item rather than a foreign rectangle inserted between posts.
class AppAdvertisementCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final double maximumWidth;
  final double horizontalMargin;
  final double contentPadding;

  const AppAdvertisementCard({
    required this.title,
    required this.subtitle,
    required this.child,
    this.maximumWidth = 696,
    this.horizontalMargin = 8,
    this.contentPadding = 8,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final borderRadius = BorderRadius.circular(18);
    final borderColor = colors.onSurface.withValues(
      alpha: dark ? 0.24 : 0.12,
    );

    final content = ClipRRect(
      borderRadius: borderRadius,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            key: const ValueKey('app-ad-header'),
            padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 12, 8),
            child: Row(
              children: [
                Icon(
                  isCupertino(context)
                      ? CupertinoIcons.speaker_2
                      : Icons.campaign_outlined,
                  size: 17,
                  color: colors.primary,
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(
                      alpha: dark ? 0.20 : 0.10,
                    ),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: colors.primary.withValues(
                        alpha: dark ? 0.38 : 0.24,
                      ),
                      width: 0.7,
                    ),
                  ),
                  child: Text(
                    title,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.35,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              contentPadding,
              0,
              contentPadding,
              contentPadding,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: child,
            ),
          ),
        ],
      ),
    );

    final card = isCupertino(context)
        ? PlatformLiquidGlassCard(
            borderRadius: borderRadius,
            tintColor: colors.primary,
            child: content,
          )
        : Container(
            decoration: BoxDecoration(
              color: Color.alphaBlend(
                colors.primary.withValues(alpha: dark ? 0.055 : 0.025),
                colors.surfaceContainerLow,
              ),
              borderRadius: borderRadius,
              border: Border.all(color: borderColor, width: 0.8),
              boxShadow: dark
                  ? null
                  : [
                      BoxShadow(
                        color: colors.shadow.withValues(alpha: 0.05),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
            ),
            child: content,
          );

    return Semantics(
      container: true,
      label: '$title，$subtitle',
      child: Center(
        child: Container(
          key: const ValueKey('app-ad-card'),
          constraints: BoxConstraints(maxWidth: maximumWidth),
          margin: EdgeInsets.symmetric(
            horizontal: horizontalMargin,
            vertical: 8,
          ),
          child: card,
        ),
      ),
    );
  }
}

class _AdLoadingPlaceholder extends StatelessWidget {
  const _AdLoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      key: const ValueKey('app-ad-loading'),
      height: 56,
      alignment: Alignment.center,
      color: colors.surfaceContainerHighest.withValues(alpha: 0.42),
      child: SizedBox.square(
        dimension: 16,
        child: isMaterial(context)
            ? CircularProgressIndicator(
                strokeWidth: 1.8,
                color: colors.primary,
              )
            : CupertinoActivityIndicator(color: colors.primary, radius: 8),
      ),
    );
  }
}
