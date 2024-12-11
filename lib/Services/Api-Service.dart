import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:e_commerce/Models/Product.dart';


class ApiService {
  final String baseUrl = 'https://fakestoreapi.com/products';

  // Fetch products from the API
  Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        // If the response is successful, parse the data
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Product.fromJson(item)).toList();
      } else {
        // If the server did not return a 200 OK response, throw an exception
        throw Exception('Failed to load products');
      }
    } catch (e) {
      // Catch any errors that occur during the HTTP request
      print('Error fetching products: $e');
      throw Exception('Error fetching products: $e');
    }
  }

  // Search products by query (you can extend this further based on category)
  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl?title_like=$query'));

      if (response.statusCode == 200) {
        // If the response is successful, parse the data
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => Product.fromJson(item)).toList();
      } else {
        // If the server did not return a 200 OK response, throw an exception
        throw Exception('Failed to search products');
      }
    } catch (e) {
      // Catch any errors that occur during the HTTP request
      print('Error searching products: $e');
      throw Exception('Error searching products: $e');
    }
  }
}
