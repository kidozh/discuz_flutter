import 'package:discuz_flutter/entity/Post.dart';
import 'package:flutter/material.dart';

class ReplyPostNotifierProvider with ChangeNotifier{
  Post? _post;

  Post? get post => _post;

  setPost(Post? post){
    _post = post;
    notifyListeners();
  }

  ReplyPostNotifierProvider();
}