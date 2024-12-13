import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Models/Product.dart';
import '../Models/Category.dart';
import '../Models/UserProfile.dart';
import '../Models/Cart.dart';

class ApiService {
  final String productBaseUrl = 'https://fakestoreapi.com/products';
  final String categoryBaseUrl = 'https://fakestoreapi.com/products/categories';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ---------------------------------------------
  // Profile Operations
  // ---------------------------------------------

  // Fetch user profile data
  // Fetch user profile data or create a new profile if it doesn't exist
  Future<UserProfile?> getUserProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('profiles').doc(user.uid).get();
      if (doc.exists) {
        return UserProfile.fromFirestore(doc);
      } else {
        // If no profile exists, create a default one
        final newUserProfile = UserProfile(
          name: user.displayName ?? 'User', // Default value if no displayName
          email: user.email ?? 'email@example.com',
          birthday: DateTime.now(), // Default birthday
        );
        // Save the new profile in Firestore
        await _firestore.collection('profiles').doc(user.uid).set(newUserProfile.toMap());
        return newUserProfile;
      }
    }
    return null;
  }


  // Save or update user profile data
  Future<void> saveUserProfile(UserProfile profile) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('profiles').doc(user.uid).set(profile.toMap());
    }
  }

  // ---------------------------------------------
  // Category Operations
  // ---------------------------------------------

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

  // ---------------------------------------------
  // Product Operations
  // ---------------------------------------------

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

  // ---------------------------------------------
  // Cart Operations
  // ---------------------------------------------

  // Add item to the cart
  Future<void> addToCart(Product product) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        final cartCollection = _firestore.collection('carts').doc(user.uid).collection('items');
        final productId = product.id.toString();

        final cartQuery = await cartCollection.where('productId', isEqualTo: productId).get();

        if (cartQuery.docs.isEmpty) {
          // Add product to cart if it's not already in the cart
          await cartCollection.doc(productId).set({
            'productId': productId,
            'title': product.title,
            'price': product.price,
            'image': product.image,
            'quantity': 1,
          });
        } else {
          // Update quantity if already in the cart
          final cartDoc = cartQuery.docs.first;
          await cartDoc.reference.update({
            'quantity': FieldValue.increment(1),
          });
        }
      } catch (e) {
        print('Error adding product to cart: $e');
      }
    } else {
      print("User is not authenticated");
    }
  }

  // Remove item from the cart
  Future<void> removeFromCart(String productId) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('carts').doc(user.uid).collection('items').doc(productId).delete();
      } catch (e) {
        print("Error removing item from cart: $e");
      }
    } else {
      print("User not authenticated.");
    }
  }

  // Update product quantity in the cart
  Future<void> updateQuantity(String productId, int quantity) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore
            .collection('carts')
            .doc(user.uid)
            .collection('items')
            .doc(productId)
            .update({'quantity': quantity});
      } catch (e) {
        print("Error updating quantity: $e");
      }
    } else {
      print("User not authenticated.");
    }
  }

  // Fetch all items in the cart
  Stream<List<CartItem>> getCartItems() {
    User? user = _auth.currentUser;
    if (user != null) {
      return _firestore
          .collection('carts')
          .doc(user.uid)
          .collection('items')
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => CartItem.fromFirestore(doc)).toList());
    } else {
      print("No user authenticated");
      return Stream.value([]);
    }
  }

  // Calculate total price of cart
  Future<double> calculateTotal() async {
    User? user = _auth.currentUser;
    double total = 0.0;
    if (user != null) {
      QuerySnapshot snapshot = await _firestore.collection('carts').doc(user.uid).collection('items').get();
      for (var doc in snapshot.docs) {
        CartItem cartItem = CartItem.fromFirestore(doc);
        total += cartItem.price * cartItem.quantity;
      }
    }
    return total;
  }
}
