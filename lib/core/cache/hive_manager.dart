import 'package:hive/hive.dart';

class HiveManager {
  static final _box = Hive.box('cacheBox');

  static Future<void> save(String key, dynamic data) async =>
      await _box.put(key, data);

  static dynamic get(String key) => _box.get(key);
}
