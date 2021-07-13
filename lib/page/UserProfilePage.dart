
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/JsonResult/UserProfileResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/screen/BlankScreen.dart';
import 'package:discuz_flutter/utility/CustomizeColor.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/widget/DiscuzHtmlWidget.dart';
import 'package:discuz_flutter/widget/ErrorCard.dart';
import 'package:discuz_flutter/widget/UserProfileListItem.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

import 'PrivateMessageDetailPage.dart';


class UserProfilePage extends StatelessWidget{
  late final Discuz discuz;
  late final User? user;
  int uid = 0;

  UserProfilePage(this.discuz,this.user,this.uid);

  @override
  Widget build(BuildContext context) {

    return UserProfileStatefulWidget(discuz, user, uid);
  }

}

class UserProfileStatefulWidget extends StatefulWidget{

  late final Discuz discuz;
  late final User? user;
  int uid = 0;

  UserProfileStatefulWidget(this.discuz,this.user,this.uid);

  @override
  State<StatefulWidget> createState() {

    return UserProfileState(discuz, user, uid);
  }

}

class UserProfileState extends State<UserProfileStatefulWidget>{

  late final Discuz discuz;
  late final User? user;
  int uid = 0;
  
  UserProfileResult? _userProfileResult = null;

  UserProfileState(this.discuz,this.user, this.uid);

  void _loadUserProfile() async {
    print("get uid profile : ${uid}");
    User? user = Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
    var dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    final MobileApiClient client = MobileApiClient(dio, baseUrl: discuz.baseURL);

    client.userProfileResultRaw(uid).then((value) => log(value));

    client.userProfileResult(uid).then((value){
      setState(() {
        this._userProfileResult = value;
      });
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
    // TODO: implement build
    if(_userProfileResult == null){
      return PlatformScaffold(
        iosContentPadding: true,
        iosContentBottomPadding: true,
        appBar: PlatformAppBar(
            title: Text(S.of(context).userProfile)
        ),
        body: BlankScreen(),
      );
    }
    else if(_userProfileResult != null && _userProfileResult!.errorResult!= null){
      return PlatformScaffold(
        iosContentPadding: true,
        iosContentBottomPadding: true,
        appBar: PlatformAppBar(
            title: Text(S.of(context).userProfile)
        ),
        body: ErrorCard(_userProfileResult!.errorResult!.key,
          _userProfileResult!.errorResult!.content,
          (){
            _loadUserProfile();
          }
        ),
      );
    }
    return PlatformScaffold(
      iosContentPadding: true,
      iosContentBottomPadding: true,
      appBar: PlatformAppBar(
        title: _userProfileResult == null? Text(S.of(context).userProfile): Text(_userProfileResult!.variables.getSpace().username),
        trailingActions: [
          Row(
            children: [
              IconButton(
                  icon: Icon(Icons.message),
                  onPressed: () {
                    if(_userProfileResult!= null && _userProfileResult!.variables.space!= null){
                      Navigator.push(
                          context,
                          platformPageRoute(context:context,builder: (context) => PrivateMessageDetailScreen(uid, _userProfileResult!.variables.space!.username))
                      );
                    }

                  }),
            ],
          )

        ],
      ),
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          EasyRefresh.custom(
              slivers: [
                SliverList(delegate: SliverChildListDelegate([
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 220.0,
                        color: Colors.white,
                      ),
                      ClipPath(
                        clipper: TopBarClipper(
                            MediaQuery.of(context).size.width, 200
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 200,
                          child: Container(
                            width: double.infinity,
                            height: 240.0,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      // username
                      Container(
                        margin: new EdgeInsets.only(top: 40.0),
                        child: new Center(
                          child: Text(_userProfileResult!.variables.getSpace().username, style: TextStyle(fontSize: 30.0, color: Colors.white),),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 100.0),
                        child: Center(
                          child: Container(
                            width: 100.0,
                            height: 100.0,
                            child: CircleAvatar(
                              child: CachedNetworkImage(
                                imageUrl: URLUtils.getAvatarURL(discuz, uid.toString()),
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) =>
                                    CircularProgressIndicator(
                                        value: downloadProgress.progress),
                                errorWidget: (context, url, error) => Container(
                                  width: 100.0,
                                  height: 100.0,
                                  child: CircleAvatar(

                                    backgroundColor: CustomizeColor.getColorBackgroundById(uid),
                                    child: Text(
                                      _userProfileResult!.variables.getSpace().username.length != 0
                                          ? _userProfileResult!.variables.getSpace().username[0].toUpperCase()
                                          : S.of(context).anonymous,
                                      style: TextStyle(color: Colors.white, fontSize: 45),
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
                      ),

                    ],
                  ),
                  Container(
                    width: double.infinity,
                    color: Theme.of(context).brightness == Brightness.light? Colors.white: Colors.white12,
                    padding: EdgeInsets.all(10.0),
                    child: DiscuzHtmlWidget(discuz,_userProfileResult!.variables.getSpace().signatureHtml),
                  ),
                  // custom title
                  Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: EdgeInsets.all(4),
                      child: Card(
                        color: Colors.blueGrey,
                        child: Container(
                          padding: EdgeInsets.all(4.0),
                          child: Column(
                            children: [
                              if(_userProfileResult!.variables.getSpace().customStatus.isNotEmpty)
                                UserProfileListItem(
                                  icon: Icon(Icons.category, color: Colors.white,),
                                  title: S.of(context).customStatusTitle,
                                  titleColor: Colors.white,
                                  describe: _userProfileResult!.variables.getSpace().customStatus,
                                  describeColor: Colors.white,
                                ),
                              if(_userProfileResult!.variables.getSpace().bio.isNotEmpty)
                                UserProfileListItem(
                                  icon: Icon(Icons.edit, color: Colors.white,),
                                  title: S.of(context).bio,
                                  titleColor: Colors.white,
                                  describe: _userProfileResult!.variables.getSpace().bio,
                                  describeColor: Colors.white,
                                ),
                              if(_userProfileResult!.variables.getSpace().recentNote.isNotEmpty)
                                UserProfileListItem(
                                  icon: Icon(Icons.message_outlined, color: Colors.white,),
                                  title: S.of(context).recentNote,
                                  titleColor: Colors.white,
                                  describe: _userProfileResult!.variables.getSpace().recentNote,
                                  describeColor: Colors.white,
                                )
                            ],
                          ),
                        ),
                      )
                  ),

                  // admin group
                  Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: EdgeInsets.all(4),
                      child: Card(
                        color: Colors.blue,
                        child: Container(
                          padding: EdgeInsets.all(4.0),
                          child: Column(
                            children: [
                              if(_userProfileResult!.variables.getSpace().adminGroupInfo.groupTitle.isNotEmpty)
                              UserProfileListItem(
                                icon: Icon(Icons.verified_user_rounded, color: Colors.white,),
                                title: _userProfileResult!.variables.getSpace().adminGroupInfo.groupTitle.replaceAll(RegExp(r'<.*?>'), ""),
                                titleColor: Colors.white,
                                describe: S.of(context).groupInfoDescription(_userProfileResult!.variables.getSpace().adminGroupInfo.readAccess, _userProfileResult!.variables.getSpace().adminGroupInfo.stars),
                                describeColor: Colors.white,
                              ),
                              UserProfileListItem(
                                icon: Icon(Icons.group, color: Colors.white,),
                                title: _userProfileResult!.variables.getSpace().groupInfo.groupTitle.replaceAll(RegExp(r'<.*?>'), ""),
                                titleColor: Colors.white,
                                describe: S.of(context).groupInfoDescription(_userProfileResult!.variables.getSpace().groupInfo.readAccess, _userProfileResult!.variables.getSpace().groupInfo.stars),
                                describeColor: Colors.white,
                              )
                            ],
                          ),
                        ),
                      )
                  ),
                  // register time
                  Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: EdgeInsets.all(4),
                      child: Card(
                        color: Colors.green,
                        child: Container(
                          padding: EdgeInsets.all(4.0),
                          child: Column(
                            children: [

                              UserProfileListItem(
                                icon: Icon(Icons.add_circle_outline_outlined, color: Colors.white,),
                                title: S.of(context).registerAccountTime,
                                titleColor: Colors.white,
                                describe: _userProfileResult!.variables.getSpace().registerDateString,
                                describeColor: Colors.white,
                              ),
                              UserProfileListItem(
                                icon: Icon(Icons.history, color: Colors.white,),
                                title: S.of(context).lastVisitTime,
                                titleColor: Colors.white,
                                describe: _userProfileResult!.variables.getSpace().lastvisit,
                                describeColor: Colors.white,
                              ),
                              UserProfileListItem(
                                icon: Icon(Icons.access_time, color: Colors.white,),
                                title: S.of(context).onlineHoursTitle,
                                titleColor: Colors.white,
                                describe: S.of(context).onlineHours(_userProfileResult!.variables.getSpace().oltime),
                                describeColor: Colors.white,
                              ),
                              UserProfileListItem(
                                icon: Icon(Icons.timelapse, color: Colors.white,),
                                title: S.of(context).lastActivityTime,
                                titleColor: Colors.white,
                                describe: _userProfileResult!.variables.getSpace().lastactivity,
                                describeColor: Colors.white,
                              ),
                              UserProfileListItem(
                                icon: Icon(Icons.av_timer, color: Colors.white,),
                                title: S.of(context).lastPostTime,
                                titleColor: Colors.white,
                                describe: _userProfileResult!.variables.getSpace().lastpost,
                                describeColor: Colors.white,
                              ),
                              if(_userProfileResult!.variables.getSpace().birthYear != 0)
                                UserProfileListItem(
                                  icon: Icon(Icons.cake_outlined, color: Colors.white,),
                                  title: "${_userProfileResult!.variables.getSpace().zodiac} · ${_userProfileResult!.variables.getSpace().constellation}",
                                  titleColor: Colors.white,
                                  describe: _userProfileResult!.variables.getSpace().getBirthDay(),
                                  describeColor: Colors.white,
                                ),
                            ],
                          ),
                        ),
                      )
                  ),
                  // birthplace and habits
                  Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: EdgeInsets.all(4),
                      child: Card(
                        color: Colors.pink,
                        child: Container(
                          padding: EdgeInsets.all(4.0),
                          child: Column(
                            children: [
                              if(_userProfileResult!.variables.getSpace().site.isNotEmpty)
                              UserProfileListItem(
                                icon: Icon(Icons.work_outline, color: Colors.white,),
                                title: S.of(context).homepage,
                                titleColor: Colors.white,
                                describe: _userProfileResult!.variables.getSpace().site,
                                describeColor: Colors.white,
                              ),
                              if(_userProfileResult!.variables.getSpace().interest.isNotEmpty)
                                UserProfileListItem(
                                  icon: Icon(Icons.whatshot_rounded, color: Colors.white,),
                                  title: S.of(context).habit,
                                  titleColor: Colors.white,
                                  describe: _userProfileResult!.variables.getSpace().interest,
                                  describeColor: Colors.white,
                                ),

                            ],
                          ),
                        ),
                      )
                  ),
                  // birthplace
                  Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: EdgeInsets.all(4),
                      child: Card(
                        color: Colors.orange,
                        child: Container(
                          padding: EdgeInsets.all(4.0),
                          child: Column(
                            children: [
                              if(_userProfileResult!.variables.getSpace().getBirthPlace().isNotEmpty)
                              UserProfileListItem(
                                icon: Icon(Icons.child_care, color: Colors.white,),
                                title: S.of(context).birthPlace,
                                titleColor: Colors.white,
                                describe: _userProfileResult!.variables.getSpace().getBirthPlace(),
                                describeColor: Colors.white,
                              ),
                              if(_userProfileResult!.variables.getSpace().getResidentPlace().isNotEmpty)
                              UserProfileListItem(
                                icon: Icon(Icons.location_city_outlined, color: Colors.white,),
                                title: S.of(context).residentPlace,
                                titleColor: Colors.white,
                                describe: _userProfileResult!.variables.getSpace().getResidentPlace(),
                                describeColor: Colors.white,
                              ),
                              if(_userProfileResult!.variables.getSpace().graduateschool.isNotEmpty || _userProfileResult!.variables.getSpace().education.isNotEmpty)
                              UserProfileListItem(
                                icon: Icon(Icons.history_edu, color: Colors.white,),
                                title: _userProfileResult!.variables.getSpace().education,
                                titleColor: Colors.white,
                                describe: _userProfileResult!.variables.getSpace().graduateschool,
                                describeColor: Colors.white,
                              ),
                              if(_userProfileResult!.variables.getSpace().company.isNotEmpty || _userProfileResult!.variables.getSpace().occupation.isNotEmpty)
                                UserProfileListItem(
                                  icon: Icon(Icons.work_outline, color: Colors.white,),
                                  title: _userProfileResult!.variables.getSpace().occupation,
                                  titleColor: Colors.white,
                                  describe: _userProfileResult!.variables.getSpace().company,
                                  describeColor: Colors.white,
                                )
                            ],
                          ),
                        ),
                      )
                  ),

                  // credit
                  Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: EdgeInsets.all(4),
                      child: Card(
                        color: Colors.lightBlue,
                        child: Container(
                          padding: EdgeInsets.all(4.0),
                          child: Column(
                            children: [
                              UserProfileListItem(
                                icon: Icon(Icons.work_outline, color: Colors.white,),
                                title: S.of(context).credit,
                                titleColor: Colors.white,
                                describe: _userProfileResult!.variables.getSpace().credits.toString(),
                                describeColor: Colors.white,
                              ),

                            ],
                          ),
                        ),
                      )
                  ),


                ]))
              ]
          )
        ],
      ),

      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // to new message
      //   },
      //   child: Icon(Icons.message),
      // ),

    );
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