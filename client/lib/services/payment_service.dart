import 'dart:convert';
import 'package:client/config/config.dart';
import 'package:http/http.dart' as http;

class PaymentService {
  static Future<Map<String, dynamic>> createPaymentIntent(
      String token, List<Map<String, dynamic>> cartItems) async {
    final response = await http.post(
      Uri.parse(createPayment),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"cartItems": cartItems}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data; // contains { clientSecret, orderId }
    } else {
      throw Exception(
          "Failed to create payment intent: ${response.statusCode} ${response.body}");
    }
  }
}
