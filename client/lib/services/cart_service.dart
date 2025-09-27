import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';

class CartService {

  // -------- Add product to cart --------
  static Future<Map<String, dynamic>> addToCart(
      String token,
      String productId,
      int quantity,
      ) async {
    final response = await http.post(
      Uri.parse(addCart),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "productId": productId,
        "quantity": quantity,
      }),
    );

    return _processResponse(response);
  }

  // -------- Fetch user's cart --------
  static Future<dynamic> fetchCart(String token) async {
    final response = await http.get(
      Uri.parse(getCart),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    return _processResponse(response);
  }

  // -------- Update item quantity --------
  static Future<Map<String, dynamic>> updateCartItem(
      String token,
      String cartItemId,
      int quantity,
      ) async {
    final response = await http.put(
      Uri.parse("$updateCart/$cartItemId"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"quantity": quantity}),
    );

    return _processResponse(response);
  }

  // -------- Remove item from cart --------
  static Future<Map<String, dynamic>> removeFromCart(
      String token,
      String cartItemId,
      ) async {
    final response = await http.delete(
      Uri.parse("$deleteCart/$cartItemId"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    return _processResponse(response);
  }

  // -------- Helper: response handler --------
  static dynamic _processResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;

    if (statusCode >= 200 && statusCode < 300) {
      return body;
    } else {
      throw Exception(
        "Request failed [${response.statusCode}]: ${body?['message'] ?? response.body}",
      );
    }
  }
}
