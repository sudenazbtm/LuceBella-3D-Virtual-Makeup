class Product {
  final int id;
  final String name;
  final String brand;
  final String platform;
  final String category;
  final double price;
  final String priceText;
  final String color;
  final String colorCode;
  final String image;
  final double rating;
  final int reviews;
  final bool isNew;

  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.platform,
    required this.category,
    required this.price,
    required this.priceText,
    required this.color,
    required this.colorCode,
    required this.image,
    required this.rating,
    required this.reviews,
    required this.isNew,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'brand': brand,
        'platform': platform,
        'category': category,
        'price': price,
        'priceText': priceText,
        'color': color,
        'colorCode': colorCode,
        'image': image,
        'rating': rating,
        'reviews': reviews,
        'isNew': isNew,
      };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'],
        name: json['name'],
        brand: json['brand'],
        platform: json['platform'],
        category: json['category'],
        price: json['price'].toDouble(),
        priceText: json['priceText'],
        color: json['color'],
        colorCode: json['colorCode'],
        image: json['image'],
        rating: json['rating'].toDouble(),
        reviews: json['reviews'],
        isNew: json['isNew'] ?? false,
      );
}
