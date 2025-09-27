import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:client/services/storage_service.dart';
import '../config/config.dart';

class ProductService {
  // Add Product
  static Future<Map<String, dynamic>> addProductApi({
    required String name,
    required String description,
    required double price,
    required int quantity,
    required File imageFile,
  }) async {
    try {
      final token = await StorageService.getAccessToken();
      final url = Uri.parse(addProduct); // from config.dart

      final request = http.MultipartRequest("POST", url)
        ..headers["Authorization"] = "Bearer $token"
        ..fields["name"] = name
        ..fields["description"] = description
        ..fields["price"] = price.toString()
        ..fields["quantity"] = quantity.toString()
        ..files.add(await http.MultipartFile.fromPath(
          "imageFile", // make sure field name matches backend schema
          imageFile.path,
        ));

      final response = await request.send();
      final resBody = await http.Response.fromStream(response);
      final data = jsonDecode(resBody.body);

      if (resBody.statusCode == 201) {
        return {"success": true, "data": data};
      } else {
        return {
          "success": false,
          "message": data["message"] ?? "Failed to add product"
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }


  // Get All Products
  static Future<Map<String, dynamic>> fetchProductsApi() async {
    try {
      final token = await StorageService.getAccessToken(); // get stored token
      final url = Uri.parse(getProducts); // from config.dart

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "data": data["data"]};
      } else {
        return {
          "success": false,
          "message": data["message"] ?? "Failed to fetch products"
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }


  // Update Product
  static Future<Map<String, dynamic>> updateProductApi({
    required String productId,
    required String name,
    required String description,
    required double price,
    File? imagePath,
  }) async {
    try {
      final token = await StorageService.getAccessToken();
      final url = Uri.parse("$updateProduct/$productId");

      final request = http.MultipartRequest("PUT", url)
        ..headers["Authorization"] = "Bearer $token"
        ..fields["name"] = name
        ..fields["description"] = description
        ..fields["price"] = price.toString();

      if (imagePath != null) {
        request.files.add(await http.MultipartFile.fromPath("imageFile", imagePath.path));
      }

      final response = await request.send();
      final resBody = await http.Response.fromStream(response);
      final data = jsonDecode(resBody.body);

      if (resBody.statusCode == 200) {
        return {"success": true, "data": data};
      } else {
        return {"success": false, "message": data["message"] ?? "Failed to update product"};
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  // Delete Product
  static Future<Map<String, dynamic>> deleteProductApi(String productId) async {
    try {
      final token = await StorageService.getAccessToken();
      final url = Uri.parse("$deleteProduct/$productId");

      final response = await http.delete(
        url,
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "message": data["message"] ?? "Product deleted"};
      } else {
        return {"success": false, "message": data["message"] ?? "Failed to delete product"};
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }
}
