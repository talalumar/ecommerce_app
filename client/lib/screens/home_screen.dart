import 'package:client/screens/product_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  void _logout() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.logoutUser();

    if (success) {
      Navigator.pushReplacementNamed(context, "/login");
    } else {
      final error = auth.errorMessage ?? "Logout failed";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ProductProvider>().fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Ecommerce App"),
              backgroundColor: Colors.blue.shade700,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    _logout();
                  },
                ),
              ],
            ),

            // This adds the left-side drawer
            drawer: SizedBox(
              width: MediaQuery.of(context).size.width * 0.65,
              child: Drawer(
                  child: Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        final userRole = auth.userRole;
                        return ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            DrawerHeader(
                              decoration: BoxDecoration(
                                color: Colors.blue.shade700,
                              ),
                              child: const Text(
                                "Menu",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 24),
                              ),
                            ),
                            ListTile(
                              leading: const Icon(Icons.home),
                              title: const Text("Home"),
                              onTap: () {
                                Navigator.pop(context); // close drawer
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.shopping_bag),
                              title: const Text("Products"),
                              onTap: () {
                                Navigator.pop(context);
                              },
                            ),

                            if (userRole == "admin")
                              ListTile(
                              leading: const Icon(Icons.add_box),
                              title: const Text("Add Product"),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.pushNamed(context, "/addProduct");
                              },
                            ),
                            if (userRole == "admin")
                            ListTile(
                              leading: const Icon(Icons.info),
                              title: const Text("Product Details"),
                              onTap: () {
                                Navigator.pushNamed(context, "/productDetails");
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.settings),
                              title: const Text("Settings"),
                              onTap: () {
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.logout),
                              title: const Text("Logout"),
                              onTap: () {
                                Navigator.pop(context);
                                _logout(); // your existing logout function
                              },
                            ),
                          ],
                        );
                      },
              ),
            ),
            ),


            body: Consumer<ProductProvider>(
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

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: productProvider.products.length,
                  itemBuilder: (context, index) {
                    final product = productProvider.products[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductScreen(product: product),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: Image.network(
                            product["imageUrl"] ?? "",
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                          ),
                          title: Text(product["name"] ?? "No name"),
                          subtitle: Text("\$${product["price"] ?? 0}"),
                        ),
                      ),
                    );
                  },
                );
              },
            ),

          );
        }
  }