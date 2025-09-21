import 'dart:io';

import 'package:flutter/material.dart';
import '../services/product_service.dart';

class ProductProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  List<dynamic> _products = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<dynamic> get products => _products;

  // Fetch Products
  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await ProductService.fetchProductsApi();

    if (response["success"]) {
      _products = response["data"];
    } else {
      _errorMessage = response["message"];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Add Product
  Future<bool> addProduct({
    required String name,
    required String description,
    required double price,
    required File imageFile,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await ProductService.addProductApi(
      name: name,
      description: description,
      price: price,
      imageFile: imageFile,
    );

    _isLoading = false;

    if (response["success"]) {
      await fetchProducts(); // refresh list
      return true;
    } else {
      _errorMessage = response["message"];
      notifyListeners();
      return false;
    }
  }

  // Update Product
  Future<bool> updateProduct({
    required String productId,
    required String name,
    required String description,
    required double price,
    File? imagePath,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await ProductService.updateProductApi(
      productId: productId,
      name: name,
      description: description,
      price: price,
      imagePath: imagePath,
    );

    _isLoading = false;

    if (response["success"]) {
      await fetchProducts(); // refresh list
      return true;
    } else {
      _errorMessage = response["message"];
      notifyListeners();
      return false;
    }
  }

  // Delete Product
  Future<bool> deleteProduct(String productId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await ProductService.deleteProductApi(productId);

    _isLoading = false;

    if (response["success"]) {
      _products.removeWhere((p) => p["_id"] == productId);
      notifyListeners();
      return true;
    } else {
      _errorMessage = response["message"];
      notifyListeners();
      return false;
    }
  }
}
