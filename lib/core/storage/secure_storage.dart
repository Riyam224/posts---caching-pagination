import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  /// Save a token securely
  static Future<void> save(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Read a token
  static Future<String?> get(String key) async {
    return await _storage.read(key: key);
  }

  /// Clear all tokens
  static Future<void> clear() async {
    await _storage.deleteAll();
  }
}
