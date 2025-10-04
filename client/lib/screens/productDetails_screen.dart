import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import 'buynow_screen.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailsScreen({super.key, required this.product});

  void _handleAddToCart(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final cartProvider = context.read<CartProvider>();

    await cartProvider.addProductToCart(
      authProvider.accessToken!,
      product["_id"],
      1,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(cartProvider.message ?? "Something went wrong")),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product["name"] ?? "Product Detail"),
        backgroundColor: Colors.blue.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                product["imageUrl"] ?? "",
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),

            // Name & Price
            Text(
              product["name"] ?? "",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "\$${product["price"]}",
              style: TextStyle(fontSize: 20, color: Colors.green.shade700),
            ),
            const SizedBox(height: 20),

            // Description
            Text(
              product["description"] ?? "",
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 40),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: () => _handleAddToCart(context),

                  icon: const Icon(Icons.shopping_cart),
                  label: const Text("Add to Cart"),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BuyNowScreen(
                          cartItems: [
                            {
                              ...product,
                              "quantity": 1,
                            }
                          ],
                        ),
                      ),
                    );
                  },


                  icon: const Icon(Icons.payment),
                  label: const Text("Buy Now"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
