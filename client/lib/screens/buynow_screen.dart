import 'package:flutter/material.dart';

class BuyNowScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const BuyNowScreen({super.key, required this.product});

  @override
  State<BuyNowScreen> createState() => _BuyNowScreenState();
}

class _BuyNowScreenState extends State<BuyNowScreen> {
  final _formKey = GlobalKey<FormState>();
  String _address = '';
  String _phone = '';
  String _paymentMethod = 'cod'; // default: Cash on Delivery

  void _placeOrder() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    String paymentText =
    _paymentMethod == "cod" ? "Cash on Delivery" : "Credit/Debit Card";

    // Later: If credit card -> integrate Stripe here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Order placed with $paymentText!")),
    );

    Navigator.pop(context); // Go back after order
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Buy Now"),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Info
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product["imageUrl"] ?? "",
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(product["name"] ?? ""),
                  subtitle: Text("\$${product["price"]}"),
                ),
              ),
              const SizedBox(height: 20),

              // Form for address & phone
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

              // Payment Method
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
              const SizedBox(height: 30),

              // Total Price
              Text(
                "Total: \$${product["price"]}",
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Place Order button
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
