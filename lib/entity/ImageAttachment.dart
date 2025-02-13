
import 'package:hive_ce/hive.dart';

import '../utility/ConstUtils.dart';
import 'Discuz.dart';

part 'ImageAttachment.g.dart';

@HiveType(typeId: ConstUtils.HIVE_TYPE_ID_IMAGE_ATTACHMENT)
class ImageAttachment extends HiveObject{
  @HiveField(0)
  String aid = "";
  @HiveField(1)
  DateTime updateAt = DateTime.now();
  @HiveField(2)
  Discuz discuz;
  @HiveField(3)
  String path;

  ImageAttachment(this.aid, this.discuz, this.path);
}