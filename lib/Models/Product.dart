class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final String image;
  final String category;
  final Map<String, dynamic>? rating; // Nullable rating map

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.image,
    required this.category,
    this.rating,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      image: json['image'],
      category: json['category'],
      rating: json['rating'] != null ? Map<String, dynamic>.from(json['rating']) : null,
    );
  }

  double get ratingRate => rating?['rate']?.toDouble() ?? 0.0;
  int get ratingCount => rating?['count']?.toInt() ?? 0;
}
