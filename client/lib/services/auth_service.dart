import 'dart:convert';
import 'package:client/services/storage_service.dart';
import 'package:http/http.dart' as http;
import '../config.dart';

class AuthService {
  static Future<Map<String, dynamic>> registerRequestApi({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(registerRequest),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {
          "success": false,
          "message": jsonDecode(response.body)["message"] ??
              "Something went wrong",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Error: $e",
      };
    }
  }


  static Future<Map<String, dynamic>> verifyRegisterOtpApi({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(registerVerify),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "otp": otp}),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }


  static Future<Map<String, dynamic>> loginUserApi({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(login),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }


  static Future<Map<String, dynamic>> logoutApi(String accessToken) async {
    try {
      final response = await http.post(
        Uri.parse(logout),
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        // Clear tokens from storage
        await StorageService.deleteTokens();

        return {
          "success": true,
          "message": "Logged out successfully",
        };
      } else {
        final data = json.decode(response.body);
        return {
          "success": false,
          "message": data["message"] ?? "Logout failed",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }


  static Future<Map<String, dynamic>> requestForgotPasswordApi(String email) async {
    try {
      final response = await http.post(
        Uri.parse(requestForgotPassword),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "message": data["message"]};
      } else {
        return {"success": false, "message": data["message"] ?? "Failed to send OTP"};
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }



  static Future<Map<String, dynamic>> verifyForgotPasswordOtpApi({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(verifyForgotPassword), // endpoint from config.dart
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "otp": otp,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "data": data};
      } else {
        return {"success": false, "message": data["message"] ?? "OTP verification failed"};
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }


  static Future<Map<String, dynamic>> resetPasswordApi({
    required String email,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(resetForgotPassword),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "newPassword": newPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "message": data["message"]};
      } else {
        return {"success": false, "message": data["message"] ?? "Reset failed"};
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }


  static Future<Map<String, dynamic>> resendRegisterOtpApi(String email) async {
    try {
      final response = await http.post(
        Uri.parse(registerResendOtp),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "success": false,
          "message": jsonDecode(response.body)["message"] ?? "Something went wrong",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Error: $e",
      };
    }
  }

}
