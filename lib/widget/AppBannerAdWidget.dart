

import 'package:discuz_flutter/utility/AdHelper.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../entity/Discuz.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../provider/UserPreferenceNotifierProvider.dart';

class AppBannerAdWidget extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return AppBannerAdState();
  }

  
}

class AppBannerAdState extends State<AppBannerAdWidget>{
  BannerAd? _anchoredAdaptiveAd;

  bool _isAdLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAd();
  }

  Future<void> _loadAd() async{
    final AnchoredAdaptiveBannerAdSize? size =
    await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
        MediaQuery.of(context).size.width.truncate());
    if (size == null) {
      print('Unable to get height of anchored banner.');
      return;
    }

    _anchoredAdaptiveAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitTestId,
      size: size,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('$ad loaded: ${ad.responseInfo}');
          setState(() {
            // When the ad is loaded, get the ad size and use it to set
            // the height of the ad container.
            _anchoredAdaptiveAd = ad as BannerAd;
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('Anchored adaptive banner failedToLoad: $error');
          ad.dispose();
        },
      ),
    );

    return _anchoredAdaptiveAd!.load();
  }

  @override
  Widget build(BuildContext context) {
    Discuz? discuz = Provider.of<DiscuzAndUserNotifier>(context, listen: false).discuz;
    String adExemptHost = Provider.of<UserPreferenceNotifierProvider>(context,listen: false).adExemptHost;
    if(discuz!= null){
      // check with list
      Uri uri = Uri.parse(discuz.baseURL);
      if (AdHelper.adWhiteDiscuzHostList.contains(uri.host) || adExemptHost == uri.host){
        // not showing ad
        return Container();
      }
    }
    return _isAdLoaded && _anchoredAdaptiveAd!=null ? Container(
      color: Theme.of(context).colorScheme.surface,
      width: _anchoredAdaptiveAd!.size.width.toDouble(),
      height: _anchoredAdaptiveAd!.size.height.toDouble(),
      child: AdWidget(ad: _anchoredAdaptiveAd!),
    ):LinearProgressIndicator();
  }

  @override
  void dispose() {
    super.dispose();
    _anchoredAdaptiveAd?.dispose();
  }

}