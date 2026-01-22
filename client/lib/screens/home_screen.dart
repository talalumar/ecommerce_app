import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:client/screens/cart_screen.dart';
import 'package:client/screens/products_screen.dart';
import 'package:client/screens/account_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final NotchBottomBarController _notchController =
  NotchBottomBarController(index: 0);

  final List<Widget> _screens = const [
    ProductsScreen(),
    CartScreen(),
    AccountScreen(),
  ];

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
      extendBody: true,
      backgroundColor: Colors.grey[100],

      body: _screens[_selectedIndex],

      // Persistent Animated Bottom Bar
      bottomNavigationBar: AnimatedNotchBottomBar(
        notchBottomBarController: _notchController,
        color: Colors.white,
        showLabel: true,
        notchColor: Color(0xFF292526),
        kIconSize: 26.0,
        kBottomRadius: 28.0,
        bottomBarItems: const [
          BottomBarItem(
            inActiveItem: Icon(Icons.home_outlined, color: Colors.grey),
            activeItem: Icon(Icons.home, color: Colors.white),
            itemLabel: 'Home',
          ),
          BottomBarItem(
            inActiveItem: Icon(Icons.shopping_cart_outlined, color: Colors.grey),
            activeItem: Icon(Icons.shopping_cart_outlined, color: Colors.white),
            itemLabel: 'Cart',
          ),
          BottomBarItem(
            inActiveItem: Icon(Icons.account_circle_outlined, color: Colors.grey),
            activeItem: Icon(Icons.account_circle_outlined, color: Colors.white),
            itemLabel: 'Account',
          ),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
