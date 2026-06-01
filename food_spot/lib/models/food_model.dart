class FoodModel {
  String id;
  String name;
  String category;
  String description;
  String image;
  double rating;

  FoodModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.image,
    required this.rating,
  });

  factory FoodModel.fromMap(Map<String, dynamic> data, String id) {
    return FoodModel(
      id: id,
      name: data['name'],
      category: data['category'],
      description: data['description'],
      image: data['image'],
      rating: (data['rating'] ?? 0).toDouble(),
    );
  }
}
