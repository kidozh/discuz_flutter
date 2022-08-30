

import 'package:hive/hive.dart';

import '../entity/Draft.dart';

class DraftDao{
  Box<Draft> draftBox;

  DraftDao(this.draftBox);
}