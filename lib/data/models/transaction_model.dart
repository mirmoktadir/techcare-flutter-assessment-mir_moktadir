import '../../domain/entities/transaction.dart';
import 'category_model.dart';

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final String type;
  final CategoryModel category;
  final DateTime date;
  final String? description;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.description,
  });

  Transaction toEntity() => Transaction(
    id: id,
    title: title,
    amount: amount,
    type: type,
    category: category.toEntity(),
    date: date,
    description: description,
  );

  static TransactionModel fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      title: json['title'],
      amount: json['amount'].toDouble(),
      type: json['type'],
      category: CategoryModel.fromJson(json['category']),
      date: DateTime.parse(json['date']),
      description: json['description'],
    );
  }
}
