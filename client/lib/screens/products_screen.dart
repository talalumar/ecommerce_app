import 'package:client/screens/productDetails_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        if (productProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (productProvider.errorMessage != null) {
          return Center(child: Text(productProvider.errorMessage!));
        }

        if (productProvider.products.isEmpty) {
          return const Center(child: Text("No products available"));
        }

        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            title: const Text("Home", style: TextStyle(fontWeight: FontWeight.w600),),
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
          ),
          body: Padding(
            padding: const EdgeInsets.only(bottom: 80.0),
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: productProvider.products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // two columns
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.68, // card height ratio
              ),
              itemBuilder: (context, index) {
                final product = productProvider.products[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailsScreen(product: product),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product image
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child: Image.network(
                              product["imageUrl"] ?? "",
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image, size: 48),
                              ),
                            ),
                          ),
                        ),

                        // Product details
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product["name"] ?? "No name",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "\$${product["price"]?.toStringAsFixed(2) ?? '0.00'}",
                                style: TextStyle(
                                  // color: Color(0xFF5B9EE1),
                                  // fontSize: 16,
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                              // const SizedBox(height: 6),
                              // ElevatedButton(
                              //   onPressed: () {
                              //     Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //         builder: (_) =>
                              //             ProductDetailsScreen(product: product),
                              //       ),
                              //     );
                              //   },
                              //   style: ElevatedButton.styleFrom(
                              //     backgroundColor: Color(0xFF292526),
                              //     minimumSize: const Size.fromHeight(38),
                              //     shape: RoundedRectangleBorder(
                              //       borderRadius: BorderRadius.circular(8),
                              //     ),
                              //   ),
                              //   child: const Text(
                              //     "View Details",
                              //     style: TextStyle(fontSize: 14, color: Colors.white),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
