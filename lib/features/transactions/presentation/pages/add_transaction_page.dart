import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/category.dart';
import '../../../../domain/entities/transaction.dart';
import '../../bloc/transaction_bloc.dart';
import '../../bloc/transaction_event.dart';

class AddTransactionPage extends StatefulWidget {
  final String? type; // 'income' or 'expense'
  final Transaction? transaction; // for editing

  const AddTransactionPage({super.key, this.type, this.transaction});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  late String _type;
  String? _selectedCategory;
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  late DateTime _selectedDate;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Initialize from existing transaction (edit mode)
    if (widget.transaction != null) {
      final txn = widget.transaction!;
      _type = txn.type;
      _titleController.text = txn.title;
      _amountController.text = txn.amount.toString();
      _descriptionController.text = txn.description ?? '';
      _selectedDate = txn.date;
      _selectedCategory = txn.category.id;
    } else {
      // New transaction
      _type = widget.type ?? 'expense';
      _selectedDate = DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Amount
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '৳ ',
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  final val = double.tryParse(v);
                  if (val == null || val <= 0) return 'Must be > 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Type Toggle
              Row(
                children: [
                  _buildTypeButton('Income', 'income'),
                  const SizedBox(width: 16),
                  _buildTypeButton('Expense', 'expense'),
                ],
              ),
              const SizedBox(height: 16),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                maxLength: 100,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Date
              ListTile(
                title: const Text('Date'),
                subtitle: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) setState(() => _selectedDate = date);
                },
              ),

              // Save Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final category = _getCategoryById(
                      _selectedCategory ??
                          (_type == 'income' ? 'cat_income' : 'cat_001'),
                    );

                    final transaction = Transaction(
                      id:
                          widget.transaction?.id ??
                          'txn_${DateTime.now().millisecondsSinceEpoch}',
                      title: _titleController.text.trim(),
                      amount: double.parse(_amountController.text),
                      type: _type,
                      category: category,
                      date: _selectedDate,
                      description: _descriptionController.text.trim(),
                    );

                    final bloc = context.read<TransactionBloc>();
                    if (widget.transaction != null) {
                      bloc.add(UpdateTransaction(transaction.id, transaction));
                    } else {
                      bloc.add(AddTransaction(transaction));
                    }
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton(String label, String value) {
    final isSelected = _type == value;
    return Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected
              ? (_type == 'income'
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1))
              : null,
          side: BorderSide(
            color: _type == 'income' ? Colors.green : Colors.red,
            width: isSelected ? 2 : 1,
          ),
        ),
        onPressed: () => setState(() => _type = value),
        child: Text(
          label,
          style: TextStyle(
            color: _type == 'income' ? Colors.green : Colors.red,
            fontWeight: isSelected ? FontWeight.bold : null,
          ),
        ),
      ),
    );
  }

  Category _getCategoryById(String id) {
    // In real app, load from CategoryBloc
    // For now, hardcode
    switch (id) {
      case 'cat_income':
        return Category(
          id: 'cat_income',
          name: 'Salary',
          icon: 'payments',
          color: '#00C853',
          budget: 0,
        );
      case 'cat_freelance':
        return Category(
          id: 'cat_freelance',
          name: 'Freelance',
          icon: 'work',
          color: '#00C853',
          budget: 0,
        );
      case 'cat_001':
        return Category(
          id: 'cat_001',
          name: 'Food & Dining',
          icon: 'restaurant',
          color: '#FF6B6B',
          budget: 20000,
        );
      case 'cat_002':
        return Category(
          id: 'cat_002',
          name: 'Transportation',
          icon: 'directions_car',
          color: '#4ECDC4',
          budget: 15000,
        );
      case 'cat_003':
        return Category(
          id: 'cat_003',
          name: 'Shopping',
          icon: 'shopping_bag',
          color: '#FFD93D',
          budget: 10000,
        );
      case 'cat_004':
        return Category(
          id: 'cat_004',
          name: 'Entertainment',
          icon: 'movie',
          color: '#95E1D3',
          budget: 8000,
        );
      case 'cat_005':
        return Category(
          id: 'cat_005',
          name: 'Bills & Utilities',
          icon: 'receipt',
          color: '#F38181',
          budget: 12000,
        );
      default:
        return Category(
          id: 'cat_001',
          name: 'Food & Dining',
          icon: 'restaurant',
          color: '#FF6B6B',
          budget: 20000,
        );
    }
  }
}
