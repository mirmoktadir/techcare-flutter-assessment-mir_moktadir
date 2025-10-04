import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../domain/entities/category.dart';
import '../../../../domain/entities/transaction.dart';
import '../../bloc/transaction_bloc.dart';
import '../../bloc/transaction_event.dart';
import '../../bloc/transaction_state.dart';

class AddTransactionPage extends StatefulWidget {
  final String? type;
  final Transaction? transaction;

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
    super.initState();
    if (widget.transaction != null) {
      final txn = widget.transaction!;
      _type = txn.type;
      _titleController.text = txn.title;
      _amountController.text = txn.amount.toString();
      _descriptionController.text = txn.description ?? '';
      _selectedDate = txn.date;
      _selectedCategory = txn.category.id;
    } else {
      _type = widget.type ?? 'expense';
      _selectedDate = DateTime.now();
    }
  }

  Category _getCategoryById(String id) {
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

  List<Category> _getCategories() {
    return [
      _getCategoryById('cat_001'),
      _getCategoryById('cat_002'),
      _getCategoryById('cat_003'),
      _getCategoryById('cat_004'),
      _getCategoryById('cat_005'),
      if (_type == 'income') _getCategoryById('cat_income'),
      if (_type == 'income') _getCategoryById('cat_freelance'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.transaction != null ? 'Edit Transaction' : 'Add Transaction',
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Amount',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      prefixText: '৳ ',
                      border: OutlineInputBorder(),
                      hintText: '0.00',
                    ),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      final num = double.tryParse(value);
                      if (num == null || num <= 0) {
                        return 'Must be greater than 0';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  _buildTypeButton('Income', 'income'),
                  const SizedBox(width: 16),
                  _buildTypeButton('Expense', 'expense'),
                ],
              ),
              const SizedBox(height: 16),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Category',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _getCategories().length,
                      itemBuilder: (context, index) {
                        final category = _getCategories()[index];
                        final isSelected = _selectedCategory == category.id;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_getIconData(category.icon), size: 16),
                                const SizedBox(width: 4),
                                Text(category.name),
                              ],
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedCategory = category.id);
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                maxLength: 100,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLength: 500,
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              ListTile(
                title: const Text('Date'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
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
              const SizedBox(height: 24),

              BlocListener<TransactionBloc, TransactionState>(
                listener: (context, state) {
                  if (state is TransactionOperationSuccess) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.message)));
                    Navigator.pop(context);
                  } else if (state is TransactionError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: BlocBuilder<TransactionBloc, TransactionState>(
                  builder: (context, state) {
                    return Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: state is TransactionOperationInProgress
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      if (_selectedCategory == null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Please select a category',
                                            ),
                                          ),
                                        );
                                        return;
                                      }
                                      final amount = double.parse(
                                        _amountController.text,
                                      );
                                      final category = _getCategoryById(
                                        _selectedCategory!,
                                      );
                                      final transaction = Transaction(
                                        id:
                                            widget.transaction?.id ??
                                            'txn_${DateTime.now().millisecondsSinceEpoch}',
                                        title: _titleController.text.trim(),
                                        amount: amount,
                                        type: _type,
                                        category: category,
                                        date: _selectedDate,
                                        description: _descriptionController.text
                                            .trim(),
                                      );

                                      final bloc = context
                                          .read<TransactionBloc>();
                                      if (widget.transaction != null) {
                                        bloc.add(
                                          UpdateTransaction(
                                            transaction.id,
                                            transaction,
                                          ),
                                        );
                                      } else {
                                        bloc.add(AddTransaction(transaction));
                                      }
                                    }
                                  },
                            child: state is TransactionOperationInProgress
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text('Save'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
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
              ? (value == 'income'
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1))
              : null,
          side: BorderSide(
            color: value == 'income' ? Colors.green : Colors.red,
            width: isSelected ? 2 : 1,
          ),
        ),
        onPressed: () => setState(() => _type = value),
        child: Text(
          label,
          style: TextStyle(
            color: value == 'income' ? Colors.green : Colors.red,
            fontWeight: isSelected ? FontWeight.bold : null,
          ),
        ),
      ),
    );
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
