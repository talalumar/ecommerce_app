import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  void _logoutUser() async {
    final accessToken = await StorageService.getAccessToken();
   print(accessToken);
    if (accessToken != null) {
      final result = await AuthService.logoutApi(accessToken);

      if (result["success"]) {
        await StorageService.deleteTokens();

        Navigator.pushReplacementNamed(context, "/login");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result["message"])),
        );
      }
    } else {
      Navigator.pushReplacementNamed(context, "/login");
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
              _logoutUser();
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
