import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import 'buynow_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

  @override
  void initState() {
    super.initState();
    // fetch cart when screen opens
    Future.microtask(() {
      final token = context.read<AuthProvider>().accessToken!;
      final cartProvider = context.read<CartProvider>();
      cartProvider.fetchCart(token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final token = context.read<AuthProvider>().accessToken!;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cart"),
        backgroundColor: Colors.blue.shade700,
      ),
      body: cartProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartProvider.cartItems.isEmpty
          ? const Center(
        child: Text(
          "Your cart is empty",
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: cartProvider.cartItems.length,
        itemBuilder: (context, index) {
          final item = cartProvider.cartItems[index];
          final product = item["productId"];

          return Card(
            margin: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product["imageUrl"],
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(product["name"]),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("\$${product["price"]}"),
                  Text("Quantity: ${item["quantity"]}"),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Decrease button
                  IconButton(
                    icon: const Icon(Icons.remove_circle,
                        color: Colors.red),
                    onPressed: () {
                      final newQty =
                          (item["quantity"] as int) - 1;
                      if (newQty > 0) {
                        cartProvider.updateCartItem(
                            token, item["_id"], newQty);
                      } else {
                        cartProvider.removeFromCart(token, item["_id"]);
                      }
                    },
                  ),
                  // Increase button
                  IconButton(
                    icon: const Icon(Icons.add_circle,
                        color: Colors.green),
                    onPressed: () {
                      final newQty =
                          (item["quantity"] as int) + 1;
                      cartProvider.updateCartItem(
                          token, item["_id"], newQty);
                    },
                  ),
                  // Delete button
                  IconButton(
                    icon: const Icon(Icons.delete,
                        color: Colors.grey),
                    onPressed: () {
                      cartProvider.removeFromCart(token, item["_id"]);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: () {
            final cartProvider = Provider.of<CartProvider>(context, listen: false);
            final cartItems = cartProvider.cartItems;

            if (cartItems.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Your cart is empty.")),
              );
              return;
            }

            final formattedItems = cartItems.map<Map<String, dynamic>>((item) {
              final product = item["productId"];
              return {
                "_id": product["_id"],
                "name": product["name"],
                "imageUrl": product["imageUrl"],
                "price": product["price"],
                "quantity": item["quantity"],
              };
            }).toList();

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BuyNowScreen(cartItems: formattedItems),
              ),
            );
          },


          child: Text(
            "Checkout (\$${cartProvider.totalAmount.toStringAsFixed(2)})",
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
