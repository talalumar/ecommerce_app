import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _accessToken;
  String? _refreshToken;
  String? _userEmail;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  String? get userEmail => _userEmail;
  bool get isLoggedIn => _accessToken != null;

  Future<void> loadUserFromStorage() async {
    _accessToken = await StorageService.getAccessToken();
    _refreshToken = await StorageService.getRefreshToken();
    _userEmail = await StorageService.getUserEmail();
    notifyListeners();
  }

  // Private setters
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _setTokens(String access, String refresh) {
    _accessToken = access;
    _refreshToken = refresh;
    notifyListeners();
  }

  void _setUserEmail(String email) {
    _userEmail = email;
    notifyListeners();
  }

  /// Registration Request
  Future<bool> registerRequest({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final response = await AuthService.registerRequestApi(
        name: name,
        email: email,
        password: password,
      );

      if (response["success"] == true) {
        _setUserEmail(email);
        _setLoading(false);
        return true;
      } else {
        _setError(response["message"]);
        return false;
      }
    } catch (e) {
      _setError("Error: $e");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Verify Registration OTP
  Future<bool> verifyRegisterOtp({
    required String otp,
  }) async {
    _setLoading(true);
    try {
      final response = await AuthService.verifyRegisterOtpApi(
        email: _userEmail!,
        otp: otp,
      );

      if (response["success"] == true) {
        _setError(null); // clear old errors
        return true;
      } else {
        _setError(response["message"]);
        return false;
      }
    } catch (e) {
      _setError("Error: $e");
      return false;
    } finally {
      _setLoading(false);
    }
  }


  /// Resend Registration OTP
  Future<bool> resendRegisterOtp() async {
    _setLoading(true);
    try {
      final response = await AuthService.resendRegisterOtpApi(_userEmail!);

      if (response["success"] == true) {
        _setLoading(false);
        return true;
      } else {
        _setError(response["message"]);
        return false;
      }
    } catch (e) {
      _setError("Error: $e");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // LOGIN
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final result = await AuthService.loginUserApi(
        email: email,
        password: password,
      );

      if (result["success"] == true) {
        _setTokens(
          result["data"]["accessToken"],
          result["data"]["refreshToken"],
        );

        _setUserEmail(email);

        await StorageService.saveDataToStorage(
          accessToken: _accessToken!,
          refreshToken: _refreshToken!,
          userEmail: _userEmail!,
        );

        _setError(null);
      } else {
        _setError(result["message"] ?? "Login failed");
      }

      return result;
    } catch (e) {
      _setError("Error: $e");
      return {"success": false, "message": "Unexpected error: $e"};
    } finally {
      _setLoading(false);
    }
  }


  /// Verify Forgot Password OTP
  Future<bool> verifyForgotPasswordOtp({
    required String otp,
  }) async {
    _setLoading(true);
    try {
      final response = await AuthService.verifyForgotPasswordOtpApi(
        email: _userEmail!,
        otp: otp,
      );

      if (response["success"] == true) {
        _setLoading(false);
        return true;
      } else {
        _setError(response["message"]);
        return false;
      }
    } catch (e) {
      _setError("Error: $e");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Resend Forgot Password OTP
  Future<bool> resendForgotPasswordOtp() async {
    _setLoading(true);
    try {
      final response = await AuthService.requestForgotPasswordApi(_userEmail!);

      if (response["success"] == true) {
        _setLoading(false);
        return true;
      } else {
        _setError(response["message"]);
        return false;
      }
    } catch (e) {
      _setError("Error: $e");
      return false;
    } finally {
      _setLoading(false);
    }
  }


  /// Request Forgot Password OTP
  Future<bool> requestForgotPassword({required String email}) async {
    _setLoading(true);
    try {
      final response = await AuthService.requestForgotPasswordApi(email);

      if (response["success"] == true) {
        _setUserEmail(email);
        _setError(null);
        return true;
      } else {
        _setError(response["message"]);
        return false;
      }
    } catch (e) {
      _setError("Error: $e");
      return false;
    } finally {
      _setLoading(false);
    }
  }


  /// Reset Password
  Future<bool> resetPassword({required String newPassword}) async {
    _setLoading(true);
    try {
      final response = await AuthService.resetPasswordApi(
        email: _userEmail!,
        newPassword: newPassword,
      );

      if (response["success"] == true) {
        _errorMessage = null;
        _setLoading(false);
        return true;
      } else {
        _setError(response["message"]);
        return false;
      }
    } catch (e) {
      _setError("Error: $e");
      return false;
    } finally {
      _setLoading(false);
    }
  }


  /// Logout
  Future<bool> logoutUser() async {
    try {
      if (_accessToken != null) {
        final result = await AuthService.logoutApi(_accessToken!);

        if (result["success"]) {
          await StorageService.deleteTokens();
          _accessToken = null;
          _refreshToken = null;
          _userEmail = null;
          notifyListeners();
          return true;
        } else {
          _setError(result["message"] ?? "Logout failed");
          return false;
        }
      } else {
        await StorageService.deleteTokens();
        _accessToken = null;
        _refreshToken = null;
        _userEmail = null;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _setError("Error: $e");
      return false;
    }
  }


}
