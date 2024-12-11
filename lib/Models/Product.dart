class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final String image;
  final String category;
  final Map<String, dynamic> rating; // rating as a map

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.image,
    required this.category,
    required this.rating,
  });

  // Factory method to create a Product from JSON data
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: json['price'].toDouble(),
      image: json['image'],
      category: json['category'],
      rating: json['rating'],  // rating should be fetched as a map from the JSON
    );
  }

  // Safely get the rating and count values
  double get ratingRate => rating['rate'] ?? 0.0;
  int get ratingCount => rating['count'] ?? 0;
}
