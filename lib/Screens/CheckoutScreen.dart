import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Models/Cart.dart';

class CheckoutScreen extends StatelessWidget {
  final List<CartItem> cartItems;
  final double totalPrice;

  CheckoutScreen({required this.cartItems, required this.totalPrice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Checkout Confirmation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Summary', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return ListTile(
                    leading: Image.network(item.image, width: 50, height: 50),
                    title: Text(item.title),
                    subtitle: Text('\$${item.price} x ${item.quantity}'),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Text('Total: \$${totalPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _confirmOrder(context);
              },
              child: Text('Confirm Order'),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmOrder(BuildContext context) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      try {
        // Save the order to Firestore
        await firestore.collection('orders').add({
          'userId': user.uid,
          'items': cartItems.map((item) => item.toMap()).toList(),
          'totalPrice': totalPrice,
          'timestamp': Timestamp.now(),
        });

        // Clear the cart in Firestore
        final cartCollection = firestore.collection('carts').doc(user.uid).collection('items');
        final cartSnapshot = await cartCollection.get();
        for (var doc in cartSnapshot.docs) {
          await doc.reference.delete();
        }

        // Show confirmation message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order confirmed! It will be shipped soon.')));

        // Navigate back to the main screen
        Navigator.of(context).popUntil((route) => route.isFirst);
      } catch (e) {
        print('Error confirming order: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to confirm the order.')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User is not authenticated.')));
    }
  }
}
