import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import '../Models/Product.dart';
import '../Models/Category.dart';
import '../Services/Api-Service.dart';
import 'TransactionReportScreen.dart';
import 'UserFeedbackScreen.dart';

class AdminDashboardScreen extends StatefulWidget {
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final TextEditingController _categoryNameController = TextEditingController();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _logOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  Future<void> _createCategory(String categoryName) async {
    try {
      await _apiService.createCategory(categoryName);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Category created successfully")));
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to create category: $e")));
    }
  }

  Future<void> _createProduct(String productName, double productPrice) async {
    try {
      await _apiService.createProduct(productName, productPrice);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Product created successfully")));
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to create product: $e")));
    }
  }

  Future<List<Category>> _fetchCategories() async {
    try {
      return await _apiService.fetchCategories();
    } catch (e) {
      print("Error fetching categories: $e");
      return [];
    }
  }

  Future<List<Product>> _fetchProducts() async {
    try {
      return await _apiService.fetchProducts();
    } catch (e) {
      print("Error fetching products: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _fetchBestSellingProducts() async {
    try {
      return await _apiService.getBestSellingProducts();
    } catch (e) {
      print("Error fetching best-selling products: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.report),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TransactionReportScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.feedback),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserFeedbackScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _logOut,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Categories"),
            Tab(text: "Products"),
            Tab(text: "Best-Selling Chart"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Categories Tab
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  FutureBuilder<List<Category>>(
                    future: _fetchCategories(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}");
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Text("No categories available");
                      } else {
                        List<Category> categories = snapshot.data!;
                        return Column(
                          children: categories.map((category) {
                            return ListTile(
                              title: Text(category.name),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      _showCategoryDialog(initialCategoryName: category.name, categoryId: category.id);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      _deleteCategory(category.id);
                                    },
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      }
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _showCategoryDialog();
                    },
                    child: Text("Add Category"),
                  ),
                ],
              ),
            ),
          ),

          // Products Tab
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  FutureBuilder<List<Product>>(
                    future: _fetchProducts(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}");
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Text("No products available");
                      } else {
                        List<Product> products = snapshot.data!;
                        return Column(
                          children: products.map((product) {
                            return ListTile(
                              title: Text(product.title),
                              subtitle: Text("\$${product.price}"),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      _showProductDialog(
                                        initialProductName: product.title,
                                        initialProductPrice: product.price,
                                        productId: product.id.toString(),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      _deleteProduct(product.id.toString());
                                    },
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      }
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _showProductDialog();
                    },
                    child: Text("Create Product"),
                  ),
                ],
              ),
            ),
          ),

          // Best-Selling Products Chart Tab
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchBestSellingProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text("No sales data available");
                } else {
                  List<Map<String, dynamic>> bestSellingProducts = snapshot.data!;

                  // Ensure we are working with integer values and find the max value
                  int maxSales = bestSellingProducts
                      .map((e) => e['quantity'] as int) // Explicitly cast quantity to integer
                      .reduce((a, b) => a > b ? a : b); // Get the max quantity

                  return Container(
                    height: 300,
                    padding: EdgeInsets.all(8),
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: maxSales.toDouble(), // maxY needs to be a double, but maxSales is already an integer
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                String productId = bestSellingProducts[value.toInt()]['productId'];
                                return Text(productId, style: TextStyle(fontSize: 10));
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1, // Set interval to 1 to ensure integer values on the Y-axis
                              getTitlesWidget: (value, meta) {
                                // Show integer values on the Y-axis
                                return Text(value.toInt().toString());
                              },
                            ),
                          ),
                          rightTitles: AxisTitles( // Hiding right titles
                            sideTitles: SideTitles(showTitles: false), // Hide right-side titles
                          ),
                        ),
                        gridData: FlGridData(show: true),
                        borderData: FlBorderData(show: true),
                        barGroups: bestSellingProducts.asMap().entries.map((entry) {
                          int index = entry.key;
                          Map<String, dynamic> product = entry.value;
                          int sales = product['quantity'] as int; // Ensure quantity is an integer

                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: sales.toDouble(), 
                                color: Colors.blue,
                                width: 20,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  );
                }
              },
            ),
          ),




        ],
      ),
    );
  }

  void _showCategoryDialog({String? initialCategoryName, String? categoryId}) {
    if (initialCategoryName != null) {
      _categoryNameController.text = initialCategoryName;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(categoryId == null ? 'Add Category' : 'Edit Category'),
          content: TextField(
            controller: _categoryNameController,
            decoration: InputDecoration(labelText: 'Category Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                String categoryName = _categoryNameController.text;
                if (categoryName.isNotEmpty) {
                  if (categoryId == null) {
                    _createCategory(categoryName);
                  } else {
                    _updateCategory(categoryId, categoryName);
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(categoryId == null ? 'Add' : 'Update'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateCategory(String categoryId, String newName) async {
    try {
      await _apiService.updateCategory(categoryId, newName);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Category updated successfully")));
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to update category: $e")));
    }
  }

  Future<void> _deleteCategory(String categoryId) async {
    try {
      await _apiService.deleteCategory(categoryId);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Category deleted successfully")));
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to delete category: $e")));
    }
  }

  void _showProductDialog({String? initialProductName, double? initialProductPrice, String? productId}) {
    if (initialProductName != null) {
      _productNameController.text = initialProductName;
    }
    if (initialProductPrice != null) {
      _productPriceController.text = initialProductPrice.toString();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(productId == null ? 'Add Product' : 'Edit Product'),
          content: Column(
            children: [
              TextField(
                controller: _productNameController,
                decoration: InputDecoration(labelText: 'Product Name'),
              ),
              TextField(
                controller: _productPriceController,
                decoration: InputDecoration(labelText: 'Product Price'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                String productName = _productNameController.text;
                double productPrice = double.tryParse(_productPriceController.text) ?? 0;
                if (productName.isNotEmpty && productPrice > 0) {
                  if (productId == null) {
                    _createProduct(productName, productPrice);
                  } else {
                    _updateProduct(productId, productName, productPrice);
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(productId == null ? 'Add' : 'Update'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateProduct(String productId, String productName, double productPrice) async {
    try {
      await _apiService.updateProduct(productId, productName, productPrice);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Product updated successfully")));
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to update product: $e")));
    }
  }

  Future<void> _deleteProduct(String productId) async {
    try {
      await _apiService.deleteProduct(productId);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Product deleted successfully")));
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to delete product: $e")));
    }
  }
}
