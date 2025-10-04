import 'package:client/config/config.dart';

import 'providers/product_provider.dart';
import 'package:client/screens/wrapper_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/verify_otp_screen.dart';
import 'screens/home_screen.dart';
import 'screens/forgotPassword_screen.dart';
import 'screens/resetPassword_screen.dart';
import 'screens/addProduct_screen.dart';
import 'screens/manageProducts_screen.dart';
import 'screens/cart_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authProvider = AuthProvider();
  await authProvider.loadUserFromStorage();

  Stripe.publishableKey = stripePublisedKey;
  await Stripe.instance.applySettings();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authProvider),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ecommerce App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const Wrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/verify-otp': (context) => const VerifyOtpScreen(otpType: '',),
        '/home': (context) => const HomeScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/reset-password': (context) => const ResetPasswordScreen(),
        "/addProduct": (context) => const AddProductScreen(),
        "/manageProducts": (_) => const ManageProductsScreen(),
        "/cart": (_) => const CartScreen(),
      },
    );
  }
}