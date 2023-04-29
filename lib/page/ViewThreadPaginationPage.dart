
import 'package:flutter/cupertino.dart';

import '../JsonResult/ViewThreadResult.dart';
import '../entity/Discuz.dart';
import '../entity/DiscuzError.dart';
import '../entity/Post.dart';
import '../entity/User.dart';
import '../widget/CaptchaWidget.dart';

class ViewThreadPaginationPage extends StatelessWidget {
  Discuz discuz;
  User? user;
  int tid;
  String? passedSubject;
  VoidCallback? onClosed;

  ViewThreadPaginationPage(this.discuz, this.user, this.tid, {this.passedSubject, this.onClosed});

  @override
  Widget build(BuildContext context) {
    return ViewThreadPaginationStatefulWidget(
      discuz,
      user,
      tid,
      passedSubject: passedSubject,
      onClosed: onClosed,
    );
  }
}


class ViewThreadPaginationStatefulWidget extends StatefulWidget {
  late final Discuz discuz;
  late final User? user;
  int tid = 0;
  String? passedSubject;
  VoidCallback? onClosed;

  ViewThreadPaginationStatefulWidget(this.discuz, this.user, this.tid,
      {this.passedSubject, this.onClosed});

  @override
  _ViewThreadPaginationState createState() {
    return _ViewThreadPaginationState(this.discuz, this.user, this.tid,
        passedSubject: passedSubject,
        onClosed: onClosed
    );
  }
}

class _ViewThreadPaginationState extends State<ViewThreadPaginationStatefulWidget> {
  ViewThreadResult _viewThreadResult = ViewThreadResult();
  DiscuzError? _error;
  List<Post> _postList = [];
  int _page = 1;
  String? passedSubject;
  final TextEditingController _replyController = new TextEditingController();
  final CaptchaController _captchaController = new CaptchaController(new CaptchaFields("", "post", ""));

  late final Discuz discuz;
  late final User? user;
  int tid;

  bool historySaved = false;
  VoidCallback? onClosed;

  _ViewThreadPaginationState(this.discuz, this.user, this.tid,
      {this.passedSubject, this.onClosed});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container();
  }



}