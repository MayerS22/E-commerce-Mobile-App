import 'package:e_commerce/Models/Product.dart';
import 'package:flutter/material.dart';
import '../Services/Api-Service.dart';
import '../components/CustomSearchBar.dart';
import '../components/loading_spinner.dart';
import '../components/product_card.dart';
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> _products = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      List<Product> products = (await ApiService().fetchProducts()).cast<Product>();
      setState(() {
        _products = products;
        _isLoading = false;
      });
      print('Fetched products: $_products');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching products: $e');
    }
  }

  Future<void> _searchProducts(String query) async {
    if (query.isEmpty) {
      await _fetchProducts();
    } else {
      try {
        List<Product> products = (await ApiService().searchProducts(query)).cast<Product>();
        setState(() {
          _products = products;
        });
      } catch (e) {
        print('Error searching products: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product List'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.shopping_cart),
          ),
        ],
      ),
      body: Column(
        children: [
          CustomSearchBar(  // Updated usage
            controller: _searchController,
            onSearchChanged: _searchProducts,
          ),
          _isLoading
              ? LoadingSpinner()
              : Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return ProductCard(product: product);
              },
            ),
          ),
        ],
      ),
    );
  }
}
