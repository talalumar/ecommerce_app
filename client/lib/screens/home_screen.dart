import 'package:client/screens/cart_screen.dart';
import 'package:client/screens/manageProducts_screen.dart';
import 'package:client/screens/productDetails_screen.dart';
import 'package:client/screens/products_screen.dart';
import 'package:client/utils/cart_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import 'addProduct_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedPage = 0;

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

  final List<Widget> _pages = [
    const ProductsScreen(),
    const AddProductScreen(),
    const ManageProductsScreen(),
  ];

  void _onDrawerItemTap(int index) {
    setState(() {
      _selectedPage = index;
    });
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    final token = context.read<AuthProvider>().accessToken!;
    Future.microtask(() {
      context.read<ProductProvider>().fetchProducts();
      context.read<CartProvider>().fetchCart(token);
    });
  }

  @override
  Widget build(BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Ecommerce App"),
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              actions: const [
                CartIcon(),
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
                                _onDrawerItemTap(0);
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
                                _onDrawerItemTap(1);
                              },
                            ),
                            if (userRole == "admin")
                            ListTile(
                              leading: const Icon(Icons.info),
                              title: const Text("Manage Products"),
                              onTap: () {
                                _onDrawerItemTap(2);
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
                                _logout();
                              },
                            ),
                          ],
                        );
                      },
              ),
            ),
            ),


            body: _pages[_selectedPage],

          );
        }
  }