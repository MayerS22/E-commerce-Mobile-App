import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce/Models/Product.dart';
import 'package:flutter/material.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;

  ProductDetailsScreen({required this.product});

  // Method to add the product to the cart (with quantity management)
  Future<void> _addToCart(Product product) async {
    try {
      final cartCollection = FirebaseFirestore.instance.collection('cart');

      // Check if product already exists in the cart
      final querySnapshot = await cartCollection.where('productId', isEqualTo: product.id).get();

      if (querySnapshot.docs.isEmpty) {
        // Add product to cart if it's not already added
        await cartCollection.add({
          'productId': product.id,
          'title': product.title,
          'price': product.price,
          'image': product.image,
          'category': product.category,
          'description': product.description,
          'quantity': 1, // Default quantity is 1
        });
        print('Product added to cart');
      } else {
        // If product already exists in cart, update the quantity
        final cartDocId = querySnapshot.docs.first.id;
        final cartDocRef = cartCollection.doc(cartDocId);

        await cartDocRef.update({
          'quantity': FieldValue.increment(1), // Increment quantity
        });
        print('Product quantity updated in cart');
      }
    } catch (e) {
      print('Error adding product to cart: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          product.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  product.image,
                  height: 300.0,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 16),

              // Product Title
              Text(
                product.title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),

              // Product Price
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),

              // Product Description
              Text(
                product.description,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),

              // Product Rating
              Row(
                children: [
                  Icon(Icons.star, color: Colors.yellow, size: 20),
                  SizedBox(width: 4),
                  // Null-aware operator to handle missing rating
                  Text(
                    product.rating != null
                        ? '${product.ratingRate} (${product.ratingCount} reviews)'
                        : 'No ratings available',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
              SizedBox(height: 32),

              // Add to Cart Button
              ElevatedButton(
                onPressed: () => _addToCart(product),
                child: Text('Add to Cart'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
