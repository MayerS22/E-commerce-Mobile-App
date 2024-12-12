import 'package:flutter/material.dart';
import 'package:e_commerce/Models/Product.dart';

class SearchResultScreen extends StatelessWidget {
  final List<Product> results;

  const SearchResultScreen({Key? key, required this.results}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Results'),
      ),
      body: results.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.search_off,
              size: 60,
              color: Colors.grey,
            ),
            SizedBox(height: 10),
            Text(
              'No results found.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          final product = results[index];
          return ListTile(
            title: Text(product.title),
            subtitle: Text('\$${product.price}'),
            leading: Image.network(product.image),
          );
        },
      ),
    );
  }
}
