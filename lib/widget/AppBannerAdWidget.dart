

import 'package:discuz_flutter/utility/AdHelper.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../generated/l10n.dart';

class AppBannerAdWidget extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return AppBannerAdState();
  }

  
}

class AppBannerAdState extends State<AppBannerAdWidget>{
  final AdManagerBannerAd myBanner = AdManagerBannerAd(
    adUnitId: AdHelper.bannerAdUnitTestId,
    sizes: [AdSize.banner],
    request: AdManagerAdRequest(),
    listener: AdManagerBannerAdListener(),
  );

  bool _isAdLoaded = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadAd();
  }

  Future<void> _loadAd() async{
    myBanner.load();
    setState(() {
      _isAdLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {

    return _isAdLoaded? Container(
      alignment: Alignment.center,
      child: AdWidget(ad: myBanner,),
      width: double.infinity,
      height: 50,
    ):Text(S.of(context).adLoadingText);
  }

}