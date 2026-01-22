import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import 'editProduct_screen.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ProductProvider>().fetchProducts();
    });
  }

  Future<void> _deleteProduct(String productId) async {
    final productProvider = context.read<ProductProvider>();
    final success = await productProvider.deleteProduct(productId);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🗑️ Product deleted successfully")),
      );
    } else {
      final error = productProvider.errorMessage ?? "Delete failed";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Manage Products", style: TextStyle(fontWeight: FontWeight.w600),),
        backgroundColor: Colors.grey[100],
        foregroundColor: Colors.black,
        // elevation: 3,
        shadowColor: Colors.blueAccent.withOpacity(0.4),
      ),
      body: productProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : productProvider.products.isEmpty
          ? const Center(child: Text("No products available"))
          : RefreshIndicator(
        onRefresh: () async {
          await context.read<ProductProvider>().fetchProducts();
        },
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: productProvider.products.length,
          itemBuilder: (context, index) {
            final product = productProvider.products[index];
            return Card(
              color: Colors.grey[100],
              margin:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    product["imageUrl"],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported, size: 40),
                  ),
                ),
                title: Text(
                  product["name"],
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16),
                ),
                subtitle: Text(
                  "Price: \$${product["price"].toString()}",
                  style: const TextStyle(color: Colors.black54),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.grey),
                      tooltip: "Edit Product",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditProductScreen(product: product),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon:
                      const Icon(Icons.delete, color: Colors.black),
                      tooltip: "Delete Product",
                      onPressed: () => _deleteProduct(product["_id"]),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
