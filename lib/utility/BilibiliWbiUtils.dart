import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:http/http.dart' as http;

/// WBI 签名工具
class BilibiliWbiUtils {
  // 映射表（取前 32）用于从 img_key + sub_key 重排得到 mixin_key
  static const List<int> _mixinKeyEncTab = [
    46, 47, 18, 2, 53, 8, 23, 32, 15, 50, 10, 31, 58, 3, 45, 35, 27, 43, 5, 49,
    33, 9, 42, 19, 29, 28, 14, 39, 12, 38, 41, 13, 37, 48, 7, 16, 24, 55, 40, 61,
    26, 17, 0, 1, 60, 51, 30, 4, 22, 25, 54, 21, 56, 59, 6, 63, 57, 62, 11, 36,
    20, 34, 44, 52
  ];

  /// 从 imgKey + subKey 生成 mixin_key（取重排后的前 32 位）
  static String _genMixinKey(String imgKey, String subKey) {
    final raw = imgKey + subKey; // 长度应≥64
    final sb = StringBuffer();
    for (final i in _mixinKeyEncTab) {
      sb.write(raw[i]);
    }
    final mixed = sb.toString();
    return mixed.substring(0, 32);
  }

  /// 过滤 value 中的 "!'()*" 字符（与官方观测一致）
  static String _filterValue(String v) =>
      v.replaceAll(RegExp(r"[!'()*]"), '');

  /// 将原始 params 加上 wts，并计算 w_rid；返回可直接用于构造 URL 的参数表
  static Map<String, String> sign(
      Map<String, dynamic> params,
      String imgKey,
      String subKey,
      ) {
    final mixinKey = _genMixinKey(imgKey, subKey);

    // 追加 wts（秒级时间戳）
    final wts = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    final tmp = <String, String>{};
    for (final e in params.entries) {
      tmp[e.key] = _filterValue(e.value.toString());
    }
    tmp['wts'] = wts;

    // 按 key 升序、用 encodeComponent（大写百分号编码/空格为%20）
    final sortedKeys = tmp.keys.toList()..sort();
    final query = sortedKeys
        .map((k) =>
    '${Uri.encodeComponent(k)}=${Uri.encodeComponent(tmp[k] ?? '')}')
        .join('&');

    // w_rid = MD5(query + mixin_key)
    final wRid = md5.convert(utf8.encode(query + mixinKey)).toString();

    final out = Map<String, String>.from(tmp);
    out['w_rid'] = wRid;
    return out;
  }

  /// 获取当日最新的 img_key / sub_key（来自 nav 接口中的 wbi_img）
  /// 可选传入 SESSDATA（不是必须，未登录也通常能拿到 wbi_img）
  static Future<({String imgKey, String subKey})> fetchWbiKeys({
    String? sessdata,
  }) async {
    final uri = Uri.parse('https://api.bilibili.com/x/web-interface/nav');
    final headers = <String, String>{
      'Referer': 'https://www.bilibili.com/',
      'User-Agent':
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome Safari',
      if (sessdata != null) 'Cookie': 'SESSDATA=$sessdata',
    };

    final resp = await http.get(uri, headers: headers);
    if (resp.statusCode != 200) {
      throw Exception('Fetch nav failed: ${resp.statusCode}');
    }
    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    final data = (json['data'] ?? {}) as Map<String, dynamic>;
    final wbi = (data['wbi_img'] ?? {}) as Map<String, dynamic>;
    String _name(String url) {
      final last = url.split('/').last;
      final dot = last.indexOf('.');
      return dot >= 0 ? last.substring(0, dot) : last;
    }

    final imgKey = _name((wbi['img_url'] ?? '') as String);
    final subKey = _name((wbi['sub_url'] ?? '') as String);
    if (imgKey.isEmpty || subKey.isEmpty) {
      throw Exception('Missing wbi keys in nav response');
    }
    return (imgKey: imgKey, subKey: subKey);
  }

  static Future<void> checkAndUpdateBilibiliMixinKey() async {
    bool shouldUpdateMixinKey = await UserPreferencesUtils.shouldRegisterBilibiliWbi();
    if(shouldUpdateMixinKey){
      // then update it
      final imgAndSubKey = await fetchWbiKeys();
      final String mixinKey = _genMixinKey(imgAndSubKey.imgKey, imgAndSubKey.subKey);
      await UserPreferencesUtils.putBilibiliWbiMixinKey(mixinKey);
      await UserPreferencesUtils.putLastBilibiliWbiUpdateTime();

    }
  }

  static Future<Map<String, String>> signWithCache(
      Map<String, dynamic> params,
      ) async{
    String mixKeyInCache = await UserPreferencesUtils.getBilibiliWbiMixinKey();
    if(mixKeyInCache == ""){
      // should fetch it
      final imgAndSubKey = await fetchWbiKeys();
      final String mixinKeyRealTime = _genMixinKey(imgAndSubKey.imgKey, imgAndSubKey.subKey);
      mixKeyInCache = mixinKeyRealTime;
      await UserPreferencesUtils.putBilibiliWbiMixinKey(mixinKeyRealTime);
      await UserPreferencesUtils.putLastBilibiliWbiUpdateTime();
    }
    final mixinKey = mixKeyInCache;

    // 追加 wts（秒级时间戳）
    final wts = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    final tmp = <String, String>{};
    for (final e in params.entries) {
      tmp[e.key] = _filterValue(e.value.toString());
    }
    tmp['wts'] = wts;

    // 按 key 升序、用 encodeComponent（大写百分号编码/空格为%20）
    final sortedKeys = tmp.keys.toList()..sort();
    final query = sortedKeys
        .map((k) =>
    '${Uri.encodeComponent(k)}=${Uri.encodeComponent(tmp[k] ?? '')}')
        .join('&');

    // w_rid = MD5(query + mixin_key)
    final wRid = md5.convert(utf8.encode(query + mixinKey)).toString();

    final out = Map<String, String>.from(tmp);
    out['w_rid'] = wRid;
    return out;
  }

}
