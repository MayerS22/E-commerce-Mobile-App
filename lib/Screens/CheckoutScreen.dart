import 'package:flutter/material.dart';
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
              onPressed: () {
                // Logic to clear the cart and save order data
                _saveOrderData();
                Navigator.of(context).popUntil((route) => route.isFirst); // Go back to the main screen
              },
              child: Text('Confirm Order'),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
            ),
          ],
        ),
      ),
    );
  }

  void _saveOrderData() {
    // Save order data to the database
    print('Order data saved.');
    // Add logic to save to Firestore or any backend.
  }
}
