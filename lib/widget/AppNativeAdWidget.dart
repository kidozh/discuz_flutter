

import 'package:discuz_flutter/utility/AdHelper.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../entity/Discuz.dart';
import '../generated/l10n.dart';
import '../provider/DiscuzAndUserNotifier.dart';

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
    Discuz? discuz = Provider.of<DiscuzAndUserNotifier>(context, listen: false).discuz;
    if(discuz!= null){
      // check with list
      Uri uri = Uri.parse(discuz.baseURL);
      if (AdHelper.adWhiteDiscuzHostList.contains(uri.host)){
        // not showing ad
        return Container();
      }
    }
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