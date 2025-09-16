import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveTokens({
  required String accessToken,
  required String refreshToken
  }) async {
  await Future.wait([
  _storage.write(key: "accessToken", value: accessToken),
  _storage.write(key: "refreshToken", value: refreshToken)
  ]);
  }


  static Future<String?> getAccessToken() async {
    return await _storage.read(key: "accessToken");
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: "refreshToken");
  }


  // Save user email
  static Future<void> saveUserEmail(String userEmail) async {
    await _storage.write(key: "userEmail", value: userEmail);
  }

  // Get user email
  static Future<String?> getUserEmail() async {
      return await _storage.read(key: "userEmail");
}

  static Future<void> deleteTokens() async {
    await Future.wait([
      _storage.delete(key: "accessToken"),
      _storage.delete(key: "refreshToken"),
      _storage.delete(key: "userEmail"),
    ]);
  }

}
