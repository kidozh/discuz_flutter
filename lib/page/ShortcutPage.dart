import 'package:discuz_flutter/screen/NullDiscuzScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

import '../entity/Discuz.dart';
import '../entity/User.dart';
import '../generated/l10n.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import 'DisplayForumSliverPage.dart';
import 'UserProfilePage.dart';
import 'ViewThreadSliverPage.dart';

class ShortcutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      iosContentPadding: true,
      iosContentBottomPadding: true,
      appBar: PlatformAppBar(
        title: Text(S.of(context).shortcut),
        automaticallyImplyLeading: true,
      ),
      body: ShortcutStatefulWidget(),
    );
  }
}

class ShortcutStatefulWidget extends StatefulWidget {
  @override
  ShortcutState createState() {
    return ShortcutState();
  }
}

class ShortcutState extends State<ShortcutStatefulWidget> {
  final TextEditingController _fidTextController = new TextEditingController();
  final TextEditingController _tidTextController = new TextEditingController();
  final TextEditingController _uidTextController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<DiscuzAndUserNotifier>(
        builder: (context, discuzAndUser, child) {
      if (discuzAndUser.discuz == null) {
        return NullDiscuzScreen();
      } else {
        Discuz _discuz = discuzAndUser.discuz!;
        User? _user = discuzAndUser.user;
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                      child: PlatformTextField(
                    controller: _fidTextController,
                    hintText: S.of(context).shortcutFidHint,
                  )),
                  ValueListenableBuilder(
                      valueListenable: _fidTextController,
                      builder: (context, TextEditingValue value, child) {
                        if (value.text.isNotEmpty) {
                          return ElevatedButton(
                            child: Text(S.of(context).shortcutGo),
                            onPressed: () async {
                              int fid = int.parse(value.text);
                              await Navigator.push(
                                  context,
                                  platformPageRoute(
                                      context: context,
                                      builder: (context) =>
                                          DisplayForumSliverPage(
                                              _discuz, _user, fid)));
                            },
                          );
                        } else {
                          return Container();
                        }
                      })
                ],
              ),
              // for tid
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                      child: PlatformTextField(
                        controller: _tidTextController,
                        hintText: S.of(context).shortcutTidHint,
                      )),
                  ValueListenableBuilder(
                      valueListenable: _tidTextController,
                      builder: (context, TextEditingValue value, child) {
                        if (value.text.isNotEmpty) {
                          return ElevatedButton(
                            child: Text(S.of(context).shortcutGo),
                            onPressed: () async {
                              int tid = int.parse(value.text);
                              await Navigator.push(
                                  context,
                                  platformPageRoute(
                                      context: context,
                                      builder: (context) =>
                                          ViewThreadSliverPage(
                                              _discuz, _user, tid)));
                            },
                          );
                        } else {
                          return Container();
                        }
                      })
                ],
              ),
              // for uid
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                      child: PlatformTextField(
                        controller: _uidTextController,
                        hintText: S.of(context).shortcutUidHint,
                      )),
                  ValueListenableBuilder(
                      valueListenable: _uidTextController,
                      builder: (context, TextEditingValue value, child) {
                        if (value.text.isNotEmpty) {
                          return ElevatedButton(
                            child: Text(S.of(context).shortcutGo),
                            onPressed: () async {
                              int uid = int.parse(value.text);
                              await Navigator.push(
                                  context,
                                  platformPageRoute(
                                      context: context,
                                      builder: (context) =>
                                          UserProfilePage(
                                              _discuz, _user, uid)));
                            },
                          );
                        } else {
                          return Container();
                        }
                      })
                ],
              )
            ],
          ),
        );
      }
    });
  }
}
