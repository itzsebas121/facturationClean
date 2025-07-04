class Product {
  final int productId;
  final int categoryId;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String imageUrl;

  Product({
    required this.productId,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.imageUrl,
  });  factory Product.fromJson(Map<String, dynamic> json) {
    // Buscar el campo Stock con diferentes variaciones posibles
    dynamic stockValue;
    if (json.containsKey('Stock')) {
      stockValue = json['Stock'];
    } else if (json.containsKey('stock')) {
      stockValue = json['stock'];
    } else if (json.containsKey('Stoc')) {
      stockValue = json['Stoc'];
    } else if (json.containsKey('tock')) {
      stockValue = json['tock'];
    } else {
      stockValue = 0;
    }
    
    // Buscar el campo Price con diferentes variaciones posibles
    dynamic priceValue;
    if (json.containsKey('Price')) {
      priceValue = json['Price'];
    } else if (json.containsKey('P ice')) {
      priceValue = json['P ice'];
    } else if (json.containsKey('Pri e')) {
      priceValue = json['Pri e'];
    } else if (json.containsKey('price')) {
      priceValue = json['price'];
    } else {
      priceValue = 0.0;
    }
    
    return Product(
      productId: json['ProductId'] as int,
      categoryId: json['CategoryId'] as int,
      name: json['Name'] ?? '',
      description: json['Description'] ?? '',      price: (priceValue is num) ? priceValue.toDouble() : 0.0,
      stock: (stockValue is num) ? stockValue.toInt() : 0,
      imageUrl: json['ImageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ProductId': productId,
      'CategoryId': categoryId,
      'Name': name,
      'Description': description,
      'Price': price,
      'Stock': stock,
      'ImageUrl': imageUrl,
    };
  }
}
