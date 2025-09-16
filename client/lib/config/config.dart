final baseUrl = 'http://192.168.1.10:2000/api/v1';

final registerRequest = '$baseUrl/users/register/request';
final registerVerify = '$baseUrl/users/register/verify';
final registerResendOtp = '$baseUrl/users/register/resend-otp';
final login = '$baseUrl/users/login';
final logout = '$baseUrl/users/logout';
final requestForgotPassword = '$baseUrl/users/forgot-password/request';
final verifyForgotPassword = '$baseUrl/users/forgot-password/verify';
final resetForgotPassword = '$baseUrl/users/forgot-password/reset';
final refreshAccessToken = '$baseUrl/users/refresh';

