

import 'package:discuz_flutter/utility/AdHelper.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../generated/l10n.dart';

class AppNativeAdWidget extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return AppNativeAdState();
  }

  
}

class AppNativeAdState extends State<AppNativeAdWidget>{
  final NativeAd _nativeAd = AdHelper.forumThreadNativeAd;

  bool _isAdLoaded = false;

  void initState(){
    super.initState();
    _loadAd();

  }

  Future<void> _loadAd() async{
    await _nativeAd.load();
    setState(() {
      _isAdLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {

    if(_isAdLoaded){
      return Container(
        alignment: Alignment.center,
        child: AdWidget(
          ad: _nativeAd,
        ),
        width: double.infinity,
        height: 200,
      );
    }
    else{
      return Text(S.of(context).adLoadingText);
    }
  }

}