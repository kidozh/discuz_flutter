import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/JsonResult/UserProfileResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/screen/BlankScreen.dart';
import 'package:discuz_flutter/utility/AppPlatformIcons.dart';
import 'package:discuz_flutter/utility/CustomizeColor.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:discuz_flutter/widget/DiscuzHtmlWidget.dart';
import 'package:discuz_flutter/widget/ErrorCard.dart';
import 'package:discuz_flutter/widget/LoadingStateWidget.dart';
import 'package:discuz_flutter/widget/UserProfileListItem.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:provider/provider.dart';

import '../entity/DiscuzError.dart';
import '../utility/UserPreferencesUtils.dart';
import 'ExploreWebsiteScaffordPage.dart';
import 'PrivateMessageDetailPage.dart';

class UserProfilePage extends StatelessWidget {
  late final Discuz discuz;
  late final User? user;
  int uid = 0;
  String? username = null;

  UserProfilePage(this.discuz, this.user, this.uid, {this.username});

  @override
  Widget build(BuildContext context) {
    print("get uid profile in page: ${uid} ${username}");
    return UserProfileStatefulWidget(discuz, user, uid,
        username: this.username);
  }
}

class UserProfileStatefulWidget extends StatefulWidget {
  late final Discuz discuz;
  late final User? user;
  int uid = 0;
  String? username = null;

  UserProfileStatefulWidget(this.discuz, this.user, this.uid, {this.username});

  @override
  State<StatefulWidget> createState() {
    print("get uid profile in state: ${uid} ${username}");
    return UserProfileState(discuz, user, uid, username: this.username);
  }
}

class UserProfileState extends State<UserProfileStatefulWidget> {
  late final Discuz discuz;
  late final User? user;
  String? username = null;
  int uid = 0;
  bool isUpdating = false;

  DiscuzError? _discuzError = null;

  UserProfileResult? _userProfileResult = null;

  UserProfileState(this.discuz, this.user, this.uid, {this.username});

  void _loadUserProfile() async {
    setState(() {
      isUpdating = true;
    });
    print("get uid profile : ${uid} ${username}");
    User? user =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
    var dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    final MobileApiClient client =
        MobileApiClient(dio, baseUrl: discuz.baseURL);

    client.userProfileResult(uid).then((value) {
      setState(() {
        isUpdating = false;
        this._userProfileResult = value;
      });
      // try to save the group information
      UserPreferencesUtils.putDiscuzGroupNameById(
          discuz,
          value.variables.getSpace().groupId,
          value.variables.getSpace().groupInfo.groupTitle);
    }).catchError((e) {
      if (mounted) {
        setState(() {
          isUpdating = false;
          _discuzError = DiscuzError(
              S.of(context).networkFailed, S.of(context).networkFail);
        });
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    if (_userProfileResult == null) {
      return PlatformScaffold(
        iosContentPadding: true,
        iosContentBottomPadding: true,
        appBar: PlatformAppBar(title: Text(S.of(context).userProfile)),
        body: isUpdating
            ? Container(
                padding: EdgeInsets.all(16),
                alignment: Alignment.center,
                child: LoadingStateWidget(
                  hintText: this.username,
                ),
              )
            : _discuzError == null
                ? BlankScreen()
                : ErrorCard(_discuzError!, () {
                    VibrationUtils.vibrateWithClickIfPossible();
                    _loadUserProfile();
                  }),
      );
    } else if (_userProfileResult != null &&
        _userProfileResult!.errorResult != null) {
      return PlatformScaffold(
        iosContentPadding: true,
        iosContentBottomPadding: true,
        appBar: PlatformAppBar(title: Text(S.of(context).userProfile)),
        body: ErrorCard(
            DiscuzError(_userProfileResult!.errorResult!.key,
                _userProfileResult!.errorResult!.content), () {
          _loadUserProfile();
        }),
      );
    }
    return PlatformScaffold(
      iosContentPadding: true,
      iosContentBottomPadding: true,
      appBar: PlatformAppBar(
        liquidGlassTitle: _userProfileResult!.variables.getSpace().username,
        title: _userProfileResult == null
            ? Text(S.of(context).userProfile)
            : Text(_userProfileResult!.variables.getSpace().username),
        trailingActions: [
          PlatformIconButton(
              liquidGlassSymbol: 'message',
              icon: Icon(
                AppPlatformIcons(context).contactUserSolid,
                size: 24,
                semanticLabel: S.of(context).chatIconToolTip,
              ),
              onPressed: () {
                if (_userProfileResult != null &&
                    _userProfileResult!.variables.space != null) {
                  Navigator.push(
                      context,
                      platformPageRoute(
                          iosTitle: S.of(context).privateMessage,
                          context: context,
                          builder: (context) => PrivateMessageDetailScreen(uid,
                              _userProfileResult!.variables.space!.username)));
                }
              }),
        ],
      ),
      body: EasyRefresh(
        child: CustomScrollView(slivers: [
          SliverList(
              delegate: SliverChildListDelegate([
            PlatformLiquidGlassCard(
              margin: const EdgeInsets.fromLTRB(8, 8, 8, 4),
              tintColor: Theme.of(context).colorScheme.primaryContainer,
              child: SizedBox(
                height: 220,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 220.0,
                      color: Colors.transparent,
                    ),
                    ClipPath(
                      clipper:
                          TopBarClipper(MediaQuery.of(context).size.width, 200),
                      child: SizedBox(
                        width: double.infinity,
                        height: 200,
                        child: Container(
                          width: double.infinity,
                          height: 240.0,
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withValues(alpha: 0.34),
                        ),
                      ),
                    ),
                    // username
                    Container(
                      margin: new EdgeInsets.only(top: 40.0),
                      child: new Center(
                        child: Text(
                          _userProfileResult!.variables.getSpace().username,
                          style: TextStyle(
                              fontSize: 30.0,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 100.0),
                      child: Center(
                        child: PlatformLiquidGlassAvatar(
                          size: 100,
                          child: CachedNetworkImage(
                            imageUrl: URLUtils.getLargeAvatarURL(
                                discuz, uid.toString()),
                            fit: BoxFit.cover,
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) =>
                                    CircularProgressIndicator(
                                        value: downloadProgress.progress),
                            errorWidget: (context, url, error) => ColoredBox(
                              color: CustomizeColor.getColorBackgroundById(uid),
                              child: Center(
                                child: Text(
                                  _userProfileResult!.variables
                                              .getSpace()
                                              .username
                                              .length !=
                                          0
                                      ? _userProfileResult!.variables
                                          .getSpace()
                                          .username[0]
                                          .toUpperCase()
                                      : S.of(context).anonymous,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 45),
                                ),
                              ),
                            ),
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: imageProvider, fit: BoxFit.cover),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10.0),
              color: Colors.transparent,
              child: Row(
                children: [
                  _buildProfileMetric(
                    context,
                    S.of(context).userThread,
                    _userProfileResult!.variables.getSpace().threads.toString(),
                    onTap: () {
                      VibrationUtils.vibrateWithClickIfPossible();
                      Navigator.push(
                          context,
                          platformPageRoute(
                              iosTitle: uid.toString(),
                              context: context,
                              builder: (context) => ExploreWebsiteScaffordPage(
                                  initialURL: discuz.baseURL +
                                      "/home.php?mod=space&uid=${uid}&do=thread&view=me&type=thread&from=space")));
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildProfileMetric(
                    context,
                    S.of(context).userPost,
                    _userProfileResult!.variables.getSpace().posts.toString(),
                    onTap: () {
                      VibrationUtils.vibrateWithClickIfPossible();
                      Navigator.push(
                          context,
                          platformPageRoute(
                              iosTitle: S.of(context).openViaInternalBrowser,
                              context: context,
                              builder: (context) => ExploreWebsiteScaffordPage(
                                  initialURL: discuz.baseURL +
                                      "/home.php?mod=space&uid=${uid}&do=thread&view=me&type=reply&from=space")));
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildProfileMetric(
                    context,
                    S.of(context).userCredit,
                    _userProfileResult!.variables.getSpace().credits.toString(),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              color: Colors.transparent,
              padding: EdgeInsets.all(10.0),
              child: PlatformCard(
                padding: const EdgeInsets.all(10),
                child: DiscuzHtmlWidget(
                  discuz,
                  _userProfileResult!.variables.getSpace().signatureHtml,
                ),
              ),
            ),
            // custom title
            Container(
                width: double.infinity,
                color: Colors.transparent,
                padding: EdgeInsets.all(4),
                child: PlatformCard(
                  color: Colors.blueGrey,
                  child: Container(
                    padding: EdgeInsets.all(4.0),
                    child: Column(
                      children: [
                        if (_userProfileResult!.variables
                            .getSpace()
                            .customStatus
                            .isNotEmpty)
                          UserProfileListItem(
                            icon: Icon(
                              PlatformIcons(context).category,
                              color: Colors.white,
                            ),
                            title: S.of(context).customStatusTitle,
                            titleColor: Colors.white,
                            describe: _userProfileResult!.variables
                                .getSpace()
                                .customStatus,
                            describeColor: Colors.white,
                          ),
                        if (_userProfileResult!.variables
                            .getSpace()
                            .bio
                            .isNotEmpty)
                          UserProfileListItem(
                            icon: Icon(
                              PlatformIcons(context).edit,
                              color: Colors.white,
                            ),
                            title: S.of(context).bio,
                            titleColor: Colors.white,
                            describe:
                                _userProfileResult!.variables.getSpace().bio,
                            describeColor: Colors.white,
                          ),
                        if (_userProfileResult!.variables
                            .getSpace()
                            .recentNote
                            .isNotEmpty)
                          UserProfileListItem(
                            icon: Icon(
                              PlatformIcons(context).profileMessage,
                              color: Colors.white,
                            ),
                            title: S.of(context).recentNote,
                            titleColor: Colors.white,
                            describe: _userProfileResult!.variables
                                .getSpace()
                                .recentNote,
                            describeColor: Colors.white,
                          )
                      ],
                    ),
                  ),
                )),

            // admin group
            Container(
                width: double.infinity,
                color: Colors.transparent,
                padding: EdgeInsets.all(4),
                child: PlatformCard(
                  color: Colors.blue,
                  child: Container(
                    padding: EdgeInsets.all(4.0),
                    child: Column(
                      children: [
                        if (_userProfileResult!.variables
                            .getSpace()
                            .adminGroupInfo
                            .groupTitle
                            .isNotEmpty)
                          UserProfileListItem(
                            icon: Icon(
                              PlatformIcons(context).verifiedUser,
                              color: Colors.white,
                            ),
                            title: _userProfileResult!.variables
                                .getSpace()
                                .adminGroupInfo
                                .groupTitle
                                .replaceAll(RegExp(r'<.*?>'), ""),
                            titleColor: Colors.white,
                            describe: S.of(context).groupInfoDescription(
                                _userProfileResult!.variables
                                    .getSpace()
                                    .adminGroupInfo
                                    .readAccess,
                                _userProfileResult!.variables
                                    .getSpace()
                                    .adminGroupInfo
                                    .stars),
                            describeColor: Colors.white,
                          ),
                        UserProfileListItem(
                          icon: Icon(
                            PlatformIcons(context).groupSolid,
                            color: Colors.white,
                          ),
                          title: _userProfileResult!.variables
                              .getSpace()
                              .groupInfo
                              .groupTitle
                              .replaceAll(RegExp(r'<.*?>'), ""),
                          titleColor: Colors.white,
                          describe: S.of(context).groupInfoDescription(
                              _userProfileResult!.variables
                                  .getSpace()
                                  .groupInfo
                                  .readAccess,
                              _userProfileResult!.variables
                                  .getSpace()
                                  .groupInfo
                                  .stars),
                          describeColor: Colors.white,
                        )
                      ],
                    ),
                  ),
                )),
            // register time
            Container(
                width: double.infinity,
                color: Colors.transparent,
                padding: EdgeInsets.all(4),
                child: PlatformCard(
                  color: Colors.green,
                  child: Container(
                    padding: EdgeInsets.all(4.0),
                    child: Column(
                      children: [
                        UserProfileListItem(
                          icon: Icon(
                            PlatformIcons(context).addCircled,
                            color: Colors.white,
                          ),
                          title: S.of(context).registerAccountTime,
                          titleColor: Colors.white,
                          describe: _userProfileResult!.variables
                              .getSpace()
                              .registerDateString,
                          describeColor: Colors.white,
                        ),
                        UserProfileListItem(
                          icon: Icon(
                            PlatformIcons(context).history,
                            color: Colors.white,
                          ),
                          title: S.of(context).lastVisitTime,
                          titleColor: Colors.white,
                          describe: _userProfileResult!.variables
                              .getSpace()
                              .lastvisit,
                          describeColor: Colors.white,
                        ),
                        UserProfileListItem(
                          icon: Icon(
                            PlatformIcons(context).timeout,
                            color: Colors.white,
                          ),
                          title: S.of(context).onlineHoursTitle,
                          titleColor: Colors.white,
                          describe: S.of(context).onlineHours(
                              _userProfileResult!.variables.getSpace().oltime),
                          describeColor: Colors.white,
                        ),
                        UserProfileListItem(
                          icon: Icon(
                            PlatformIcons(context).timeout,
                            color: Colors.white,
                          ),
                          title: S.of(context).lastActivityTime,
                          titleColor: Colors.white,
                          describe: _userProfileResult!.variables
                              .getSpace()
                              .lastactivity,
                          describeColor: Colors.white,
                        ),
                        UserProfileListItem(
                          icon: Icon(
                            PlatformIcons(context).timeout,
                            color: Colors.white,
                          ),
                          title: S.of(context).lastPostTime,
                          titleColor: Colors.white,
                          describe:
                              _userProfileResult!.variables.getSpace().lastpost,
                          describeColor: Colors.white,
                        ),
                        if (_userProfileResult!.variables
                                .getSpace()
                                .birthYear !=
                            0)
                          UserProfileListItem(
                            icon: Icon(
                              PlatformIcons(context).birthday,
                              color: Colors.white,
                            ),
                            title:
                                "${_userProfileResult!.variables.getSpace().zodiac} · ${_userProfileResult!.variables.getSpace().constellation}",
                            titleColor: Colors.white,
                            describe: _userProfileResult!.variables
                                .getSpace()
                                .getBirthDay(),
                            describeColor: Colors.white,
                          ),
                      ],
                    ),
                  ),
                )),
            // birthplace and habits
            Container(
                width: double.infinity,
                color: Colors.transparent,
                padding: EdgeInsets.all(4),
                child: PlatformCard(
                  color: Colors.pink,
                  child: Container(
                    padding: EdgeInsets.all(4.0),
                    child: Column(
                      children: [
                        if (_userProfileResult!.variables
                            .getSpace()
                            .site
                            .isNotEmpty)
                          UserProfileListItem(
                            icon: Icon(
                              PlatformIcons(context).work,
                              color: Colors.white,
                            ),
                            title: S.of(context).homepage,
                            titleColor: Colors.white,
                            describe:
                                _userProfileResult!.variables.getSpace().site,
                            describeColor: Colors.white,
                          ),
                        if (_userProfileResult!.variables
                            .getSpace()
                            .interest
                            .isNotEmpty)
                          UserProfileListItem(
                            icon: Icon(
                              PlatformIcons(context).flame,
                              color: Colors.white,
                            ),
                            title: S.of(context).habit,
                            titleColor: Colors.white,
                            describe: _userProfileResult!.variables
                                .getSpace()
                                .interest,
                            describeColor: Colors.white,
                          ),
                      ],
                    ),
                  ),
                )),
            // birthplace
            Container(
                width: double.infinity,
                color: Colors.transparent,
                padding: EdgeInsets.all(4),
                child: PlatformCard(
                  color: Colors.orange,
                  child: Container(
                    padding: EdgeInsets.all(4.0),
                    child: Column(
                      children: [
                        if (_userProfileResult!.variables
                            .getSpace()
                            .getBirthPlace()
                            .isNotEmpty)
                          UserProfileListItem(
                            icon: Icon(
                              PlatformIcons(context).family,
                              color: Colors.white,
                            ),
                            title: S.of(context).birthPlace,
                            titleColor: Colors.white,
                            describe: _userProfileResult!.variables
                                .getSpace()
                                .getBirthPlace(),
                            describeColor: Colors.white,
                          ),
                        if (_userProfileResult!.variables
                            .getSpace()
                            .getResidentPlace()
                            .isNotEmpty)
                          UserProfileListItem(
                            icon: Icon(
                              PlatformIcons(context).location,
                              color: Colors.white,
                            ),
                            title: S.of(context).residentPlace,
                            titleColor: Colors.white,
                            describe: _userProfileResult!.variables
                                .getSpace()
                                .getResidentPlace(),
                            describeColor: Colors.white,
                          ),
                        if (_userProfileResult!.variables
                                .getSpace()
                                .graduateschool
                                .isNotEmpty ||
                            _userProfileResult!.variables
                                .getSpace()
                                .education
                                .isNotEmpty)
                          UserProfileListItem(
                            icon: Icon(
                              PlatformIcons(context).study,
                              color: Colors.white,
                            ),
                            title: _userProfileResult!.variables
                                .getSpace()
                                .education,
                            titleColor: Colors.white,
                            describe: _userProfileResult!.variables
                                .getSpace()
                                .graduateschool,
                            describeColor: Colors.white,
                          ),
                        if (_userProfileResult!.variables
                                .getSpace()
                                .company
                                .isNotEmpty ||
                            _userProfileResult!.variables
                                .getSpace()
                                .occupation
                                .isNotEmpty)
                          UserProfileListItem(
                            icon: Icon(
                              PlatformIcons(context).work,
                              color: Colors.white,
                            ),
                            title: _userProfileResult!.variables
                                .getSpace()
                                .occupation,
                            titleColor: Colors.white,
                            describe: _userProfileResult!.variables
                                .getSpace()
                                .company,
                            describeColor: Colors.white,
                          )
                      ],
                    ),
                  ),
                )),

            // credit
            Container(
              width: double.infinity,
              color: Colors.transparent,
              padding: EdgeInsets.all(4),
              child: PlatformCard(
                color: Colors.purple,
                child: Container(
                  padding: EdgeInsets.all(4.0),
                  child: Column(
                    children: getCreditList(),
                  ),
                ),
              ),
            ),
            // medal list
            if (_userProfileResult!.variables.getSpace().medalList.isNotEmpty)
              Container(
                  width: double.infinity,
                  color: Colors.transparent,
                  padding: EdgeInsets.all(4),
                  child: PlatformCard(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.white
                        : Colors.grey.shade900,
                    child: Container(
                      padding: EdgeInsets.all(4.0),
                      child: Column(
                        children: [
                          for (var medal in _userProfileResult!.variables
                              .getSpace()
                              .medalList)
                            UserProfileListItem(
                              icon: CachedNetworkImage(
                                imageUrl: discuz.baseURL +
                                    '/static/image/common/${medal.image}',
                              ),
                              title: medal.name,
                              titleColor: Theme.of(context).colorScheme.primary,
                              describe: medal.description,
                              describeColor: Theme.of(context).disabledColor,
                            )
                        ],
                      ),
                    ),
                  )),
          ]))
        ]),
      ),

      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // to new message
      //   },
      //   child: Icon(Icons.message),
      // ),
    );
  }

  Widget _buildProfileMetric(
    BuildContext context,
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: Semantics(
        button: onTap != null,
        label: "$label $value",
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: PlatformCard(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<UserProfileListItem> getCreditList() {
    List<UserProfileListItem> extendCreditList = [];

    if (_userProfileResult == null ||
        _userProfileResult!.variables.space == null) {
      return [];
    }
    extendCreditList.add(UserProfileListItem(
      icon: Icon(
        PlatformIcons(context).credits,
        color: Colors.white,
      ),
      title: S.of(context).credit,
      titleColor: Colors.white,
      describe: _userProfileResult!.variables.getSpace().credits.toString(),
      describeColor: Colors.white,
    ));
    SpaceVariables spaceVariables = _userProfileResult!.variables.space!;
    Map<String, ExtendCredit> extendCreditMap =
        _userProfileResult!.variables.extendCreditMap;
    print(extendCreditMap);
    if (extendCreditMap.containsKey("1")) {
      extendCreditList.add(UserProfileListItem(
        icon: Icon(
          PlatformIcons(context).work,
          color: Colors.white,
        ),
        title: extendCreditMap["1"]!.title,
        titleColor: Colors.white,
        describe:
            spaceVariables.extcredits1.toString() + extendCreditMap["1"]!.unit,
        describeColor: Colors.white,
      ));
    }
    if (extendCreditMap.containsKey("2")) {
      extendCreditList.add(UserProfileListItem(
        icon: Icon(
          PlatformIcons(context).work,
          color: Colors.white,
        ),
        title: extendCreditMap["2"]!.title,
        titleColor: Colors.white,
        describe:
            spaceVariables.extcredits2.toString() + extendCreditMap["2"]!.unit,
        describeColor: Colors.white,
      ));
    }
    if (extendCreditMap.containsKey("3")) {
      extendCreditList.add(UserProfileListItem(
        icon: Icon(
          PlatformIcons(context).work,
          color: Colors.white,
        ),
        title: extendCreditMap["3"]!.title,
        titleColor: Colors.white,
        describe:
            spaceVariables.extcredits3.toString() + extendCreditMap["3"]!.unit,
        describeColor: Colors.white,
      ));
    }
    if (extendCreditMap.containsKey("4")) {
      extendCreditList.add(UserProfileListItem(
        icon: Icon(
          PlatformIcons(context).work,
          color: Colors.white,
        ),
        title: extendCreditMap["4"]!.title,
        titleColor: Colors.white,
        describe:
            spaceVariables.extcredits4.toString() + extendCreditMap["4"]!.unit,
        describeColor: Colors.white,
      ));
    }
    if (extendCreditMap.containsKey("5")) {
      extendCreditList.add(UserProfileListItem(
        icon: Icon(
          PlatformIcons(context).work,
          color: Colors.white,
        ),
        title: extendCreditMap["5"]!.title,
        titleColor: Colors.white,
        describe:
            spaceVariables.extcredits5.toString() + extendCreditMap["5"]!.unit,
        describeColor: Colors.white,
      ));
    }
    if (extendCreditMap.containsKey("6")) {
      extendCreditList.add(UserProfileListItem(
        icon: Icon(
          PlatformIcons(context).work,
          color: Colors.white,
        ),
        title: extendCreditMap["6"]!.title,
        titleColor: Colors.white,
        describe:
            spaceVariables.extcredits6.toString() + extendCreditMap["6"]!.unit,
        describeColor: Colors.white,
      ));
    }
    if (extendCreditMap.containsKey("7")) {
      extendCreditList.add(UserProfileListItem(
        icon: Icon(
          PlatformIcons(context).work,
          color: Colors.white,
        ),
        title: extendCreditMap["7"]!.title,
        titleColor: Colors.white,
        describe:
            spaceVariables.extcredits7.toString() + extendCreditMap["7"]!.unit,
        describeColor: Colors.white,
      ));
    }
    if (extendCreditMap.containsKey("8")) {
      extendCreditList.add(UserProfileListItem(
        icon: Icon(
          PlatformIcons(context).work,
          color: Colors.white,
        ),
        title: extendCreditMap["8"]!.title,
        titleColor: Colors.white,
        describe:
            spaceVariables.extcredits8.toString() + extendCreditMap["8"]!.unit,
        describeColor: Colors.white,
      ));
    }
    return extendCreditList;
  }
}

// 顶部栏裁剪
class TopBarClipper extends CustomClipper<Path> {
  // 宽高
  double width;
  double height;

  TopBarClipper(this.width, this.height);

  @override
  Path getClip(Size size) {
    Path path = new Path();
    path.moveTo(0.0, 0.0);
    path.lineTo(width, 0.0);
    path.lineTo(width, height / 2);
    path.lineTo(0.0, height);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
