import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Storage {
  static const String _userIdKey = '96273733';
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static final Storage _instance = Storage._internal();

  factory Storage() {
    return _instance;
  }
  Storage._internal();

  Future<void> saveId(String userId) async {
    await _secureStorage.write(key: _userIdKey, value: userId);
  }

  Future<String?> getId() async {
    return await _secureStorage.read(key: _userIdKey);
  }

  Future<void> deleteId() async {
    await _secureStorage.delete(key: _userIdKey);
  }
}
