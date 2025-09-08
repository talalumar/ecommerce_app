import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

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
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart, size: 80, color: Colors.blue),
                  const SizedBox(height: 20),
                  const Text(
                    "Welcome to Ecommerce App!",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text("You are successfully logged in."),
                  const SizedBox(height: 30),

                  // Example button (navigate to products later)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      // TODO: navigate to products list
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Navigate to Products Page")),
                      );
                    },
                    child: const Text("Browse Products"),
                  ),
                ],
              ),
            ),
          );
        }
  }