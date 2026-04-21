import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

class SecurityService {
  final _storage = const FlutterSecureStorage();

  Future<Uint8List> getHiveKey() async {
    const keyName = 'hive_key';
    var encryptionKey = await _storage.read(key: keyName);
    if (encryptionKey == null) {
      final key = Hive.generateSecureKey();
      await _storage.write(key: keyName, value: base64UrlEncode(key));
      return Uint8List.fromList(key);
    }
    return base64Url.decode(encryptionKey);
  }

  Future<void> saveToken(String token) => _storage.write(key: 'token', value: token);
  Future<String?> getToken() => _storage.read(key: 'token');
  Future<void> clearSession() => _storage.delete(key: 'token');
}
