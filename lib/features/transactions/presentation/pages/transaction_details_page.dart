import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/number_formatter.dart';
import '../../../../domain/entities/category.dart';
import '../../../../domain/entities/transaction.dart';
import '../../bloc/transaction_bloc.dart';
import '../../bloc/transaction_event.dart';
import '../../bloc/transaction_state.dart';
import 'add_transaction_page.dart';

class TransactionDetailsPage extends StatelessWidget {
  final Transaction transaction;
  final String heroTag;

  const TransactionDetailsPage({
    super.key,
    required this.transaction,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is TransactionOperationSuccess) {
          Navigator.pop(context); // Close modal on success
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            // 🔹 Amount (Hero)
            Hero(
              tag: heroTag,
              child: Text(
                NumberFormatter.format(transaction.amount),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTypeBadge(transaction.type),
                const SizedBox(width: 12),
                _buildCategoryBadge(transaction.category),
              ],
            ),
            const SizedBox(height: 16),
            // 🔹 Date
            Text(
              '${_formatDate(transaction.date)} at ${_formatTime(transaction.date)}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            if (transaction.description != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  transaction.description!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildEditButton(context),
                _buildDeleteButton(context),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeBadge(String type) {
    final isIncome = type == 'income';
    return Chip(
      label: Text(isIncome ? 'Income' : 'Expense'),
      backgroundColor: isIncome
          ? Colors.green.withValues(alpha: 0.2)
          : Colors.red.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: isIncome ? Colors.green : Colors.red,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildCategoryBadge(Category category) {
    return Chip(
      avatar: Icon(_getIconData(category.icon), size: 16),
      label: Text(category.name),
      backgroundColor: Color(
        int.parse(category.color.substring(1), radix: 16),
      ).withValues(alpha: 0.2),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        Navigator.pop(context); // Close modal
        final bloc = context.read<TransactionBloc>();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider.value(
              value: bloc,
              child: AddTransactionPage(transaction: transaction),
            ),
          ),
        );
      },
      icon: const Icon(Icons.edit),
      label: const Text('Edit'),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Transaction'),
            content: const Text(
              'Are you sure you want to delete this transaction?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
        if (confirm == true) {
          if (context.mounted) {
            context.read<TransactionBloc>().add(
              DeleteTransaction(transaction.id),
            );
          }
        }
      },
      icon: const Icon(Icons.delete, color: Colors.red),
      label: const Text('Delete', style: TextStyle(color: Colors.red)),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  IconData _getIconData(String icon) {
    switch (icon) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'movie':
        return Icons.movie;
      case 'receipt':
        return Icons.receipt;
      case 'payments':
        return Icons.payments;
      case 'work':
        return Icons.work;
      default:
        return Icons.category;
    }
  }
}
