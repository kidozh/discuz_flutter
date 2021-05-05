

import 'dart:async';

import 'package:discuz_flutter/converter/FloorDateTimeConverter.dart';
import 'package:discuz_flutter/dao/TrustHostDao.dart';
import 'package:discuz_flutter/entity/TrustHost.dart';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;



part 'TrustHostDatabase.g.dart'; // the generated code will be there

@Database(version: 1, entities: [TrustHost])
abstract class TrustHostDatabase extends FloorDatabase {
  TrustHostDao get trustHostDatabaseDao;
}