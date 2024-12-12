import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:e_commerce/Models/Product.dart';
import 'package:e_commerce/Models/Category.dart';

class ApiService {
  final String productBaseUrl = 'https://fakestoreapi.com/products';
  final String categoryBaseUrl = 'https://fakestoreapi.com/products/categories';

  // Fetch all categories
  Future<List<Category>> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse(categoryBaseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        return data.map((categoryName) {
          return Category(
            id: categoryName,
            name: categoryName,
          );
        }).toList();
      } else {
        throw Exception('Failed to fetch categories: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error in fetchCategories: $e');
      rethrow;
    }
  }

  // Fetch all products
  Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse(productBaseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        return data.map((productJson) => Product.fromJson(productJson)).toList();
      } else {
        throw Exception('Failed to fetch products: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error in fetchProducts: $e');
      rethrow;
    }
  }

  // Fetch products by category
  Future<List<Product>> fetchProductsByCategory(String category) async {
    try {
      final url = '$productBaseUrl/category/$category';
      print('Fetching products from URL: $url');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        return data.map((productJson) => Product.fromJson(productJson)).toList();
      } else {
        throw Exception('Failed to fetch products for category "$category": ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error in fetchProductsByCategory: $e');
      rethrow;
    }
  }

  // Search products by query
  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await http.get(Uri.parse(productBaseUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // Apply search filtering to only include products whose title matches the query
        return data
            .map((productJson) => Product.fromJson(productJson))
            .where((product) => product.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      } else {
        throw Exception('Failed to fetch products: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error in searchProducts: $e');
      rethrow;
    }
  }


}
