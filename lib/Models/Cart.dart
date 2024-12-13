import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String productId;
  final String title;
  final double price;
  final String image;
  final int quantity;

  CartItem({
    required this.productId,
    required this.title,
    required this.price,
    required this.image,
    required this.quantity,
  });

  // Factory constructor to create CartItem from Firestore document
  factory CartItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return CartItem(
      productId: data['productId'] ?? '',
      title: data['title'] ?? 'Unknown Product',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      image: data['image'] ?? '',
      quantity: data['quantity'] is int ? data['quantity'] : 1,
    );
  }

  // Method to convert CartItem to a map (for storing in Firestore)
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'title': title,
      'price': price,
      'image': image,
      'quantity': quantity,
    };
  }
}
