import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/utility/SecureStorageUtils.dart';
import 'package:discuz_flutter/utility/TimeDisplayUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../dao/DiscuzAuthenticationDao.dart';
import '../dao/DiscuzDao.dart';
import '../entity/Discuz.dart';
import '../entity/DiscuzAuthentication.dart';
import '../generated/l10n.dart';
import '../utility/AppPlatformIcons.dart';
import '../utility/CustomizeColor.dart';

class DiscuzAuthenticationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DiscuzAuthenticationState();
  }
}

class DiscuzAuthenticationState extends State<DiscuzAuthenticationPage> {
  AuthenticationStatus authenticationStatus =
      AuthenticationStatus.could_not_authenticate;

  DiscuzAuthenticationDao? discuzAuthenticationDao = null;

  @override
  void initState() {
    super.initState();
    _loadAuthenticationStatus();
  }

  Future<void> _loadAuthenticationStatus() async {
    AuthenticationStatus _status =
        await SecureStorageUtils.getAuthenticationStatus();
    setState(() {
      authenticationStatus = _status;
    });

    if (_status == AuthenticationStatus.can_authenticate) {
      await _loadAuthenticationList();
    }
  }

  Future<void> _loadAuthenticationList() async {
    bool result = await SecureStorageUtils.authenticateWithSystem(context);
    if (!result) {
      setState(() {
        authenticationStatus = AuthenticationStatus.failed;
      });
    } else {
      // success
      discuzAuthenticationDao =
          await SecureStorageUtils.getDiscuzAuthenticationDao();

      setState(() {
        authenticationStatus = AuthenticationStatus.success;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      //iosContentPadding: true,
      appBar: PlatformAppBar(
        title: Text(S.of(context).discuzAuthenticationTitle),
        trailingActions: [
          if (discuzAuthenticationDao != null)
            IconButton(
              icon: Icon(PlatformIcons(context).add),
              onPressed: () {
                VibrationUtils.vibrateWithClickIfPossible();
                _showAddDiscuzAuthenticationDialog();
              },
            )
        ],
      ),
      body: getStatusWidget(),
    );
  }

  Widget getStatusWidget() {
    switch (authenticationStatus) {
      case AuthenticationStatus.can_authenticate:
        // check with it
        return failedAuthenticateWidget;
      case AuthenticationStatus.device_not_supported:
        return deviceNotSupportedWidget;
      case AuthenticationStatus.could_not_authenticate:
        return cannotAuthenticateWidget;
      case AuthenticationStatus.failed:
        return failedAuthenticateWidget;
      case AuthenticationStatus.success:
        return getAuthenticationListPage();
    }
  }

  Widget get deviceNotSupportedWidget => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 32.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    AppPlatformIcons(context).deviceNotSupportSolid,
                    color: Theme.of(context).colorScheme.error,
                    size: 36,
                  ),
                ),
                Text(S.of(context).authenticationStatusDeviceNotSupported,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.titleMedium?.color,
                      fontSize: 24,
                    )),
              ],
            ),
          )
        ],
      );

  Widget get cannotAuthenticateWidget => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    AppPlatformIcons(context).authenticationUnableSolid,
                    color: Theme.of(context).colorScheme.error,
                    size: 36,
                  ),
                ),
                Text(S.of(context).authenticationStatusCannotAuthenticate,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.titleMedium?.color,
                      fontSize: 24,
                    )),
              ],
            ),
          )
        ],
      );

  Widget get failedAuthenticateWidget => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    AppPlatformIcons(context).authenticationFailedSolid,
                    color: Theme.of(context).disabledColor,
                    size: 128,
                  ),
                ),
                Text(S.of(context).authenticationLocked,
                    style: TextStyle(
                      color: Theme.of(context).disabledColor,
                      fontSize: 24,
                    )),
                SizedBox(
                  height: 48,
                ),
                SizedBox(
                  width: double.infinity,
                  child: PlatformElevatedButton(
                    child: Text(S.of(context).authenticationRetry),
                    onPressed: () async {
                      VibrationUtils.vibrateWithClickIfPossible();
                      await _loadAuthenticationList();
                    },
                  ),
                )
              ],
            ),
          )
        ],
      );

  Widget get emptyAuthenticateWidget => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Padding(
                //   padding: EdgeInsets.all(8),
                //   child: Icon(AppPlatformIcons(context).authenticationUnableSolid,
                //     color: Theme.of(context).colorScheme.error,
                //     size: 36,
                //   ),
                // ),
                Text(S.of(context).authenticationEmpty,
                    style: TextStyle(
                      color: Theme.of(context).disabledColor,
                      fontSize: 24,
                    )),
              ],
            ),
          )
        ],
      );

  Widget getAuthenticationListPage() {
    if (discuzAuthenticationDao == null) {
      return failedAuthenticateWidget;
    } else {
      return ValueListenableBuilder(
        valueListenable:
            discuzAuthenticationDao!.discuzAuthenticationBox.listenable(),
        builder: (BuildContext context, Box<DiscuzAuthentication> value,
            Widget? child) {
          List<DiscuzAuthentication> list =
              discuzAuthenticationDao!.getAllDiscuzAuthentications();
          if (list.isEmpty) {
            return emptyAuthenticateWidget;
          } else {
            return ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  DiscuzAuthentication discuzAuthentication = list[index];
                  return PlatformListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.all(Radius.circular(4))),
                      child: Center(
                        child: Text(
                          discuzAuthentication.account.length != 0
                              ? discuzAuthentication.account[0].toUpperCase()
                              : S.of(context).anonymous,
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                              fontSize: 16),
                        ),
                      ),
                    ),
                    title: Text(discuzAuthentication.account),
                    subtitle: Text(discuzAuthentication.discuz_host),
                    onTap: () {
                      VibrationUtils.vibrateWithClickIfPossible();
                      _showAuthenticationDetailDialog(discuzAuthentication);
                    },
                  );
                });
          }
        },
      );
    }
  }

  Future<void> _showAuthenticationDetailDialog(
      DiscuzAuthentication discuzAuthentication) async {
    DiscuzDao discuzDao = await AppDatabase.getDiscuzDao();
    Discuz? discuz =
        discuzDao.findDiscuzByRealHost(discuzAuthentication.discuz_host);
    log("Get discuz ${discuz} and ${discuzAuthentication.discuz_host}");

    if (discuz == null) {
      return;
    }

    showPlatformModalSheet(
        context: context,
        builder: (context) => Container(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.grey.shade200
                  : Colors.grey.shade800,
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.65),
              padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        color: Theme.of(context).colorScheme.background,
                      ),
                      child: Column(
                        // header
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 16.0, horizontal: 16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                PlatformListTile(
                                    title: Text(
                                      discuz.siteName,
                                      maxLines: 1,
                                    ),
                                    subtitle: Text(S
                                        .of(context)
                                        .authenticationLastUpdateAt(
                                            TimeDisplayUtils
                                                .getLocaledTimeDisplay(
                                                    context,
                                                    discuzAuthentication
                                                        .updateTime))),
                                    leading: CachedNetworkImage(
                                      imageUrl: discuz.getDiscuzAvatarURL(),
                                      width: 96,
                                      height: 64,
                                      progressIndicatorBuilder:
                                          (context, url, downloadProgress) =>
                                              PlatformCircularProgressIndicator(
                                        material: (context, platform) =>
                                            MaterialProgressIndicatorData(
                                                value:
                                                    downloadProgress.progress),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.forum),
                                    )),
                                Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(S.of(context).account),
                                    Text(
                                      discuzAuthentication.account,
                                      style: TextStyle(
                                          color:
                                              Theme.of(context).disabledColor),
                                    )
                                  ],
                                ),
                                Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(S.of(context).password),
                                    Text(
                                      discuzAuthentication.password,
                                      style: TextStyle(
                                          color:
                                              Theme.of(context).disabledColor),
                                    )
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),

                    SizedBox(
                      height: 32,
                    ),

                    // another platform box
                    SizedBox(
                      width: double.infinity,
                      child: PlatformElevatedButton(
                        child: Text(S.of(context).deleteAccount,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error)),
                        color: Theme.of(context).colorScheme.background,
                        onPressed: () async {
                          VibrationUtils.vibrateWithClickIfPossible();
                          discuzAuthenticationDao!
                              .deleteDiscuzAuthentication(discuzAuthentication);
                          Navigator.of(context).pop();
                        },
                      ),
                    )
                  ],
                ),
              ),
            ));
  }

  Future<void> _showAddDiscuzAuthenticationDialog() async {
    DiscuzDao discuzDao = await AppDatabase.getDiscuzDao();
    List<Discuz> discuzList = discuzDao.findAllDiscuzs();

    TextEditingController _accountController = TextEditingController();
    TextEditingController _passwordController = TextEditingController();

    showPlatformModalSheet(
        context: context,
        builder: (context) => Container(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.grey.shade200
                  : Colors.grey.shade800,
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8),
              padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: isCupertino(context)
                          ? BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color:
                          Theme.of(context).disabledColor.withOpacity(0.1))
                          : null,
                      child: Column(
                        children: [
                          PlatformTextFormField(
                              autofillHints: [AutofillHints.username],
                              controller: _accountController,
                              hintText: S.of(context).account,
                              material: (context, platform) {
                                return MaterialTextFormFieldData(
                                  decoration: InputDecoration(
                                    labelText: S.of(context).account,
                                    hintText: S.of(context).account,
                                    prefixIcon: Icon(Icons.account_circle),
                                  ),
                                );
                              },
                              cupertino: (context, platform) {
                                return CupertinoTextFormFieldData(
                                    prefix: Text(S.of(context).account),
                                    decoration: BoxDecoration());
                              },
                          ),
                          if (isCupertino(context)) Divider(),
                          PlatformTextFormField(
                              controller: _passwordController,
                              hintText: S.of(context).password,
                              material: (context, platform) {
                                return MaterialTextFormFieldData(
                                  decoration: InputDecoration(
                                    labelText: S.of(context).password,
                                    prefixIcon: Icon(Icons.vpn_key),
                                  ),
                                );
                              },
                              cupertino: (context, platform) {
                                return CupertinoTextFormFieldData(
                                    prefix: Text(S.of(context).password),
                                    decoration: BoxDecoration());
                              },
                              obscureText: true,
                              ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
    );
  }
}
