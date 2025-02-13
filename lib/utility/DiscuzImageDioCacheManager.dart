import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_cache_manager_dio/flutter_cache_manager_dio.dart';

class DiscuzImageDioCacheManager extends CacheManager {
  static const key = 'dioCache';

  static late final DiscuzImageDioCacheManager _instance;

  static DiscuzImageDioCacheManager get instance => _instance;

  static void initialize(Dio client) {
    _instance = DiscuzImageDioCacheManager(client);
  }

  DiscuzImageDioCacheManager(Dio dio)
      : super(Config(key, fileService: DioHttpFileService(dio)));
}