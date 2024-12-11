import 'package:flutter/material.dart';
import 'CategoryListScreen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CategoryListScreen()),
            );
          },
          child: const Text('View Categories'),
        ),
      ),
    );
  }
}
