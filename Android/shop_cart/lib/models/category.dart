class Category {
  final int id;
  final String name;

  Category({
    required this.id,
    required this.name,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['CategoryId'],
      name: json['CategoryName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CategoryId': id,
      'CategoryName': name,
    };
  }
}
