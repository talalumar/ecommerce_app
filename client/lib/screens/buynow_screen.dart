import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/payment_service.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;

class BuyNowScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  const BuyNowScreen({super.key, required this.cartItems});

  @override
  State<BuyNowScreen> createState() => _BuyNowScreenState();
}

class _BuyNowScreenState extends State<BuyNowScreen> {
  final _formKey = GlobalKey<FormState>();
  String _address = '';
  String _phone = '';
  String _paymentMethod = 'cod'; // default: Cash on Delivery

  double get totalAmount {
    return widget.cartItems.fold(
      0.0,
          (sum, item) => sum + (item["price"] * item["quantity"]),
    );
  }

  void _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_paymentMethod == "cod") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order placed with Cash on Delivery ")),
      );
      Navigator.pop(context);
      return;
    }

    if (_paymentMethod == "card") {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final token = authProvider.accessToken!;

        // Convert items into format backend expects
        final cartItemsForBackend = widget.cartItems.map((item) {
          return {
            "productId": item["_id"],
            "price": item["price"],
            "quantity": item["quantity"] ?? 1,
          };
        }).toList();

        // Call backend to create PaymentIntent
        final response = await PaymentService.createPaymentIntent(
          token,
          cartItemsForBackend,
        );

        // Some backends return a Map or a JSON-decoded object
        final clientSecret = response["clientSecret"] ?? response["client_secret"];

        if (clientSecret == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to start payment ")),
          );
          return;
        }

        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: "MyShop",
          ),
        );

        await Stripe.instance.presentPaymentSheet();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment Successful ")),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Payment Failed  $e")),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🛍️ List of Products
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) {
                  final item = widget.cartItems[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item["imageUrl"] ?? "",
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(item["name"]),
                      subtitle: Text(
                          "\$${item["price"]} × ${item["quantity"]} = \$${(item["price"] * item["quantity"]).toStringAsFixed(2)}"),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: "Delivery Address",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) =>
                      value!.isEmpty ? "Enter delivery address" : null,
                      onSaved: (value) => _address = value!,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: "Phone Number",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) =>
                      value!.isEmpty ? "Enter phone number" : null,
                      onSaved: (value) => _phone = value!,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // 💳 Payment Method
              const Text(
                "Select Payment Method",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              RadioListTile(
                value: "cod",
                groupValue: _paymentMethod,
                title: const Text("Cash on Delivery"),
                onChanged: (value) {
                  setState(() {
                    _paymentMethod = value.toString();
                  });
                },
              ),
              RadioListTile(
                value: "card",
                groupValue: _paymentMethod,
                title: const Text("Credit/Debit Card"),
                onChanged: (value) {
                  setState(() {
                    _paymentMethod = value.toString();
                  });
                },
              ),

              const SizedBox(height: 20),

              Text(
                "Total: \$${totalAmount.toStringAsFixed(2)}",
                style:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Place Order Button
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _placeOrder,
                  icon: const Icon(Icons.check),
                  label: const Text("Place Order"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
