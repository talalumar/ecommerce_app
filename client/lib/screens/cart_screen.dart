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

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF8F9FA),
          elevation: 0,
          centerTitle: true,
          // leading: IconButton(
          //   icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          //   onPressed: () => Navigator.pop(context),
          // ),
          title: const Text(
            "My Cart",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
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
            : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            children: [
              const SizedBox(height: 10),
              ...cartProvider.cartItems.map((item) {
                final product = item["productId"];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        product["imageUrl"],
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      product["name"],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          "\$${product["price"]}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, color: Colors.grey),
                              onPressed: () {
                                final newQty = (item["quantity"] as int) - 1;
                                if (newQty > 0) {
                                  cartProvider.updateCartItem(token, item["_id"], newQty);
                                } else {
                                  cartProvider.removeFromCart(token, item["_id"]);
                                }
                              },
                            ),
                            Text(
                              "${item["quantity"]}",
                              style: const TextStyle(fontSize: 16),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle, color: Color(0xFF292526)),
                              onPressed: () {
                                final newQty = (item["quantity"] as int) + 1;
                                cartProvider.updateCartItem(token, item["_id"], newQty);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outlined, color: Colors.grey),
                      onPressed: () {
                        cartProvider.removeFromCart(token, item["_id"]);
                      },
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 20),
              _buildSummarySection(context, cartProvider),
              const SizedBox(height: 100),
            ],
          ),
        ),
      
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Color(0xFFF8F9FA),
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.grey.shade300,
            //     blurRadius: 8,
            //     offset: const Offset(0, -3),
            //   ),
            // ],
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF292526),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
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
            child: const Text(
              "Checkout",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, CartProvider cartProvider) {
    double subtotal = cartProvider.totalAmount;
    double shipping = 20.90;
    double total = subtotal + shipping;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.grey.shade300,
        //     blurRadius: 8,
        //     offset: const Offset(0, 3),
        //   ),
        // ],
      ),
      child: Column(
        children: [
          _buildSummaryRow("Subtotal", "\$${subtotal.toStringAsFixed(2)}"),
          const SizedBox(height: 8),
          _buildSummaryRow("Shipping", "\$${shipping.toStringAsFixed(2)}"),
          const Divider(height: 25, thickness: 1),
          _buildSummaryRow(
            "Total Cost",
            "\$${total.toStringAsFixed(2)}",
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.black54,
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isBold ? Colors.black : Colors.black87,
          ),
        ),
      ],
    );
  }
}
