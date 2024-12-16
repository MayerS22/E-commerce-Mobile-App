import 'package:flutter/material.dart';
import 'package:e_commerce/Models/Product.dart';
import '../components/product_card.dart';  // Import the ProductCard widget

class SearchResultScreen extends StatelessWidget {
  final List<Product> results;

  const SearchResultScreen({Key? key, required this.results}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Results'),
        centerTitle: true,
        backgroundColor: const Color(0xFF4A4E69),
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
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          shrinkWrap: true,
          physics: AlwaysScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: 1.4,
          ),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final product = results[index];
            return ProductCard(product: product);
          },
        ),
      ),
    );
  }
}
