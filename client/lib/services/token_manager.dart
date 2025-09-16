import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/jwt_util.dart';

class TokenManager {
  static Future<T?> authorizedApiCall<T>({
    required BuildContext context,
    required Future<T> Function(String accessToken) apiCall,
  }) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    String? accessToken = auth.accessToken;

    if (accessToken == null || JwtUtils.isTokenExpired(accessToken)) {
      final newAccess = await auth.refreshAccessToken();

      if (newAccess == null || JwtUtils.isTokenExpired(newAccess)) {
        auth.logoutUser();
        Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
        return null;
      }

      accessToken = newAccess;
    }

    try {
      return await apiCall(accessToken);
    } catch (e) {
      if (e.toString().contains("401")) {
        final newAccess = await auth.refreshAccessToken();

        if (newAccess == null || JwtUtils.isTokenExpired(newAccess)) {
          auth.logoutUser();
          Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
          return null;
        }

        // Retry with refreshed token
        return await apiCall(newAccess);
      }
      rethrow;
    }
  }
}

