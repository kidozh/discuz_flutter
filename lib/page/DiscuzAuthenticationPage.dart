

import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../generated/l10n.dart';

class DiscuzAuthenticationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DiscuzAuthenticationState();
  }
  
}

class DiscuzAuthenticationState extends State<DiscuzAuthenticationPage>{
  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      iosContentPadding: true,
      appBar: PlatformAppBar(
        title: Text(S.of(context).discuzAuthenticationTitle),
      ),

    );
  }



}