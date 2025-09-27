import 'package:flutter/material.dart';
import '../services/cart_service.dart';

class CartProvider with ChangeNotifier {
  List<dynamic> _cartItems = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _message;


  List<dynamic> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get message => _message;

  int get totalItems {
    int total = 0;
    for (var item in _cartItems) {
      total += (item['quantity'] as int? ?? 0);
    }
    return total;
  }

  double get totalAmount {
    double total = 0.0;
    for (var item in _cartItems) {
      final product = item['product'] ?? item['productId'] ?? {};
      final price = (product is Map && product['price'] != null)
          ? (product['price'] as num).toDouble()
          : (item['price'] as num?)?.toDouble() ?? 0.0;
      final qty = (item['quantity'] as int?) ?? 0;
      total += price * qty;
    }
    return total;
  }


  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String? msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  void _setMessage(String? msg) {
    _message = msg;
    notifyListeners();
  }


  /// Fetch cart for current user.
  /// Returns true on success.
  Future<bool> fetchCart(String token) async {
    _setLoading(true);
    _setError(null);
    _setMessage(null);

    try {
      final res = await CartService.fetchCart(token);

      // robust parsing: several possible response shapes
      List<dynamic> items = [];

      if (res == null) {
        items = [];
      } else if (res is Map<String, dynamic>) {
        if (res['success'] == true) {
          final data = res['data'] ?? res['cart'] ?? res['items'];
          if (data is List) items = data;
          else if (data is Map && data['items'] is List) items = data['items'];
          else if (res['cart'] is List) items = res['cart'];
          else items = [];
        } else {
          // backend returned an error
          _setError(res['message'] ?? "Failed to fetch cart");
          _setLoading(false);
          return false;
        }
      } else if (res is List) {
        items = res;
      } else {
        items = [];
      }

      _cartItems = items;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError("Error fetching cart: $e");
      _setLoading(false);
      return false;
    }
  }

  /// Add product to cart.
  /// - token: JWT access token (pass from AuthProvider)
  /// - productId: backend product id
  /// - quantity: number to add (>=1)
  /// Returns true if added (and refreshes cart).
  Future<bool> addProductToCart(String token, String productId, int quantity) async {
    _setLoading(true);
    _setError(null);
    _setMessage(null);

    try {
      final res = await CartService.addToCart(token, productId, quantity);

      if (res == null) {
        _setError("Empty response from server");
        _setLoading(false);
        return false;
      }

      // If backend returns success boolean
      if (res is Map<String, dynamic> && res['success'] == true) {
        // refresh cart
        await fetchCart(token);
        _setMessage(res['message'] ?? "Added to cart");
        return true;
      }

      // fallback: if returned data shape is direct
      // try to refresh cart and assume success
      await fetchCart(token);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError("Error adding to cart: $e");
      _setLoading(false);
      return false;
    }
  }

  /// Update cart item quantity (set to a specific quantity)
  Future<bool> updateCartItem(String token, String cartItemId, int quantity) async {
    _setLoading(true);
    _setError(null);
    _setMessage(null);

    try {
      final res = await CartService.updateCartItem(token, cartItemId, quantity);

      if (res is Map<String, dynamic> && res['success'] == true) {
        await fetchCart(token);
        _setMessage(res['message'] ?? "Cart updated");
        return true;
      }

      // fallback: keep local unchanged but refresh
      await fetchCart(token);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError("Error updating cart: $e");
      _setLoading(false);
      return false;
    }
  }

  /// Remove an item from cart
  Future<bool> removeFromCart(String token, String cartItemId) async {
    _setLoading(true);
    _setError(null);
    _setMessage(null);

    try {
      final res = await CartService.removeFromCart(token, cartItemId);

      if (res is Map<String, dynamic> && res['success'] == true) {
        await fetchCart(token);
        _setMessage(res['message'] ?? "Item removed");
        return true;
      }

      // fallback: refresh cart anyway
      await fetchCart(token);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError("Error removing item: $e");
      _setLoading(false);
      return false;
    }
  }

  /// Clear local cart (does not call backend). Useful after logout.
  void clearLocalCart() {
    _cartItems = [];
    _message = null;
    _errorMessage = null;
    notifyListeners();
  }
}
