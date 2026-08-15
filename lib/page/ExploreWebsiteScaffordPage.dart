
import 'package:discuz_flutter/page/ExploreWebsitePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';

class ExploreWebsiteScaffordPage extends StatelessWidget{
  final String? initialURL;

  ExploreWebsiteScaffordPage({this.initialURL});

  @override
  Widget build(BuildContext context) {

    return PlatformScaffold(
      appBar: PlatformAppBar(
        automaticallyImplyLeading: true,
      ),
      body: ExploreWebsitePage(key: ValueKey(121212),initialURL: initialURL,),
    );
  }

}
