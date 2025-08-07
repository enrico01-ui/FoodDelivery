import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Storage {
  static const FlutterSecureStorage storage = FlutterSecureStorage();

  static Future<void> writeSecureData(String key, String value) async {
    await storage.write(key: key, value: value);
    
  }

  static Future<String?> readSecureData(String key) async {
    return await storage.read(key: key);
  }

  static Future<void> deleteSecureData(String key) async {
    await storage.delete(key: key);
  }

  static FlutterSecureStorage getStorage() {
    return storage;
  }
}