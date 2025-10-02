import '../../domain/entities/category.dart';

class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final String color;
  final double budget;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.budget,
  });

  Category toEntity() =>
      Category(id: id, name: name, icon: icon, color: color, budget: budget);

  static CategoryModel fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      color: json['color'],
      budget: json['budget'].toDouble(),
    );
  }
}
