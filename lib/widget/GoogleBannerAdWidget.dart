import 'dart:developer';

import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/AdHelper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';

class GoogleBannerAdWidget extends StatefulWidget {
  @override
  _GoogleBannerAdState createState() {
    // TODO: implement createState
    MobileAds.instance.initialize();
    return _GoogleBannerAdState();
  }
}

class _GoogleBannerAdState extends State<GoogleBannerAdWidget> {
  // TODO: Add _kAdIndex
  static final _kAdIndex = 4;

  // TODO: Add a BannerAd instance
  late BannerAd _ad;


  bool _isAdLoaded = false;


  @override
  void initState() {
    super.initState();
    log("load ad");
    // TODO: Create a BannerAd instance
    _ad = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.banner,
      request: AdRequest(),
      listener: AdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
          });
          print('Ad load success !');
        },
        onAdFailedToLoad: (ad, error) {
          // Releases an ad resource when it fails to load
          ad.dispose();

          print('Ad load failed (code=${error.code} message=${error.message})');
        },
      ),
    );

    // TODO: Load an ad
    _ad.load();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      children: [
        Container(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 4.0,horizontal: 8.0),
            child: Text(S.of(context).googleAdTitle, style: TextStyle(color: Colors.white),textAlign: TextAlign.left,),
          ),
          decoration: BoxDecoration(
            color: Colors.teal
          ),
        ),
        if(_isAdLoaded)
          Container(
            child: AdWidget(ad: _ad),
            width: _ad.size.width.toDouble(),
            height: 72.0,
            alignment: Alignment.center,
          ),
        if(!_isAdLoaded)
          Container(
            child: Text(S.of(context).googleAdSubTitle, style: TextStyle(fontSize: 22),),
            alignment: Alignment.center,
          ),
      ],
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    log("dispose ad");
    _ad.dispose();
    super.dispose();
  }
}
