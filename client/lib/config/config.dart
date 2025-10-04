final baseUrl = 'http://192.168.1.8:2000/api/v1';

final registerRequest = '$baseUrl/users/register/request';
final registerVerify = '$baseUrl/users/register/verify';
final registerResendOtp = '$baseUrl/users/register/resend-otp';
final login = '$baseUrl/users/login';
final logout = '$baseUrl/users/logout';
final requestForgotPassword = '$baseUrl/users/forgot-password/request';
final verifyForgotPassword = '$baseUrl/users/forgot-password/verify';
final resetForgotPassword = '$baseUrl/users/forgot-password/reset';
final refreshAccessToken = '$baseUrl/users/refresh';

final addProduct = '$baseUrl/products/add';
final getProducts = '$baseUrl/products/get';
final updateProduct = '$baseUrl/products/update';
final deleteProduct = '$baseUrl/products/delete';

final addCart = '$baseUrl/cart/add';
final getCart = '$baseUrl/cart';
final updateCart = '$baseUrl/cart';
final deleteCart = '$baseUrl/cart';

final createPayment = '$baseUrl/payment/create-payment-intent';


final stripePublisedKey="pk_test_51SBRBlKExzHksQbn0iunVZxhHpZDIVlfWEC8ejUeOdnWK6bfnrUlLpBRkbMMkpniY9d37Oa8aEc2Jh58AcTiWwQi00rdb3vacj";
