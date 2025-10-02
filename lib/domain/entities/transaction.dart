import 'category.dart';

class Transaction {
  final String id;
  final String title;
  final double amount;
  final String type; // 'income' | 'expense'
  final Category category;
  final DateTime date;
  final String? description;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.description,
  });
}
