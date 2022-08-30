


import 'package:discuz_flutter/dao/DiscuzDao.dart';
import 'package:discuz_flutter/dao/ImageAttachmentDao.dart';
import 'package:discuz_flutter/dao/ViewHistoryDao.dart';
import 'package:discuz_flutter/entity/BlockUser.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/Draft.dart';
import 'package:discuz_flutter/entity/FavoriteForumInDatabase.dart';
import 'package:discuz_flutter/entity/FavoriteThreadInDatabase.dart';
import 'package:discuz_flutter/entity/ImageAttachment.dart';
import 'package:discuz_flutter/entity/TrustHost.dart';
import 'package:discuz_flutter/entity/ViewHistory.dart';
import 'package:hive/hive.dart';

import '../dao/BlockUserDao.dart';
import '../dao/DraftDao.dart';
import '../dao/FavoriteForumDao.dart';
import '../dao/FavoriteThreadDao.dart';
import '../dao/SmileyDao.dart';
import '../dao/TrustHostDao.dart';
import '../dao/UserDao.dart';
import '../entity/Smiley.dart';
import '../entity/User.dart';

class AppDatabase{
  static const hiveBoxPrefix = "discuz_flutter";
  static Box<Discuz>? discuzBox;
  static Box<BlockUser>? blockUserBox;
  static Box<FavoriteForumInDatabase>? favoriteForumBox;
  static Box<FavoriteThreadInDatabase>? favoriteThreadBox;
  static Box<TrustHost>? trustHostBox;
  static Box<User>? userBox;
  static Box<ViewHistory>? viewHistoryBox;
  static Box<Smiley>? smileyBox;
  static Box<ImageAttachment>? imageAttachmentBox;
  static Box<Draft>? draftBox;

  static Future<void> initBoxes() async {
    Hive
      ..registerAdapter(DiscuzAdapter())
      ..registerAdapter(BlockUserAdapter())
      ..registerAdapter(FavoriteForumInDatabaseAdapter())
      ..registerAdapter(FavoriteThreadInDatabaseAdapter())
      ..registerAdapter(TrustHostAdapter())
      ..registerAdapter(UserAdapter())
      ..registerAdapter(SmileyAdapter())
      ..registerAdapter(ViewHistoryAdapter())
      ..registerAdapter(ImageAttachmentAdapter())
      ..registerAdapter(DraftAdapter())
    ;


    //blockUserBox = await Hive.openBox<BlockUser>('${hiveBoxPrefix}_block_user');


    await getBlockUserDao();
    await getDiscuzDao();
    await getFavoriteForumDao();
    await getFavoriteThreadDao();
    await getTrustHostDao();
    await getUserDao();
    await getViewHistoryDao();
    await getImageAttachmentDao();
    await getDraftDao();
  }



  static Future<BlockUserDao> getBlockUserDao() async {
    if(blockUserBox == null){
      blockUserBox = await Hive.openBox<BlockUser>('${hiveBoxPrefix}_block_user');
    }

    return BlockUserDao(blockUserBox!);
  }

  static Future<DiscuzDao> getDiscuzDao() async {
    if(discuzBox == null){
      discuzBox = await Hive.openBox<Discuz>('${hiveBoxPrefix}_discuz');
    }

    return DiscuzDao(discuzBox!);
  }

  static Future<FavoriteForumDao> getFavoriteForumDao() async {
    if(favoriteForumBox == null){
      favoriteForumBox = await Hive.openBox<FavoriteForumInDatabase>('${hiveBoxPrefix}_favorite_forum');
    }

    return FavoriteForumDao(favoriteForumBox!);
  }

  static Future<FavoriteThreadDao> getFavoriteThreadDao() async {
    if(favoriteThreadBox == null){
      favoriteThreadBox = await Hive.openBox<FavoriteThreadInDatabase>('${hiveBoxPrefix}_favorite_thread');
    }

    return FavoriteThreadDao(favoriteThreadBox!);
  }

  static Future<TrustHostDao> getTrustHostDao() async {
    if(trustHostBox == null){
      trustHostBox = await Hive.openBox<TrustHost>('${hiveBoxPrefix}_trust_host');
    }

    return TrustHostDao(trustHostBox!);
  }

  static Future<UserDao> getUserDao() async {
    if(userBox == null){
      userBox = await Hive.openBox<User>('${hiveBoxPrefix}_user');
    }

    return UserDao(userBox!);
  }

  static Future<ViewHistoryDao> getViewHistoryDao() async {
    if(viewHistoryBox == null){
      viewHistoryBox =  await Hive.openBox<ViewHistory>('${hiveBoxPrefix}_view_history');
    }

    return ViewHistoryDao(viewHistoryBox!);
  }

  static Future<SmileyDao> getSmileyDao() async {
    if(smileyBox == null){
      smileyBox =  await Hive.openBox<Smiley>('${hiveBoxPrefix}_smiley');
    }

    return SmileyDao(smileyBox!);
  }

  static Future<ImageAttachmentDao> getImageAttachmentDao() async {
    if(imageAttachmentBox == null){
      imageAttachmentBox =  await Hive.openBox<ImageAttachment>('${hiveBoxPrefix}_image_attachment_1');
    }

    return ImageAttachmentDao(imageAttachmentBox!);
  }

  static Future<DraftDao> getDraftDao() async {
    if(draftBox == null){
      draftBox =  await Hive.openBox<Draft>('${hiveBoxPrefix}_draft_1');
    }

    return DraftDao(draftBox!);
  }


}