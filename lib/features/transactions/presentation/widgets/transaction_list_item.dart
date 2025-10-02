import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../domain/entities/transaction.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;

  const TransactionListItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: transaction.type == 'income'
              ? AppColors.income.withValues(alpha: 0.2)
              : AppColors.expense.withValues(alpha: 0.2),
          child: Icon(
            Icons.arrow_upward,
            color: transaction.type == 'income'
                ? AppColors.income
                : AppColors.expense,
          ),
        ),
        title: Text(transaction.title),
        subtitle: Text(
          '${transaction.category.name} • ${transaction.date.day}/${transaction.date.month}',
        ),
        trailing: Text(
          '৳${transaction.amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: transaction.type == 'income'
                ? AppColors.income
                : AppColors.expense,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
