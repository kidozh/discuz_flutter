
import 'package:discuz_flutter/page/ExploreWebsitePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

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