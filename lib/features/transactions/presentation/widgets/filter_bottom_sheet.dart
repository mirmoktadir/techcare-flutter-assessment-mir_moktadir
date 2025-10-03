import 'package:flutter/material.dart';

class FilterBottomSheet extends StatefulWidget {
  final Map<String, dynamic> initialFilters;
  final Function(Map<String, dynamic>) onApply;

  const FilterBottomSheet({
    super.key,
    required this.initialFilters,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String? _type;
  late List<String> _selectedCategories;

  @override
  void initState() {
    super.initState();
    _type = widget.initialFilters['type'];
    _selectedCategories = List<String>.from(
      widget.initialFilters['categories'] ?? [],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filters',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Type Toggle
          const Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              _buildTypeChip('All', null),
              _buildTypeChip('Income', 'income'),
              _buildTypeChip('Expense', 'expense'),
            ],
          ),
          const SizedBox(height: 16),

          // Categories (hardcoded for demo)
          const Text(
            'Categories',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildCategoryChip('Food & Dining', 'cat_001'),
              _buildCategoryChip('Transport', 'cat_002'),
              _buildCategoryChip('Shopping', 'cat_003'),
              // ... add all
            ],
          ),
          const SizedBox(height: 16),

          // Apply/Reset
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  widget.onApply({
                    'type': _type,
                    'categories': _selectedCategories,
                  });
                },
                child: const Text('Apply'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _type = null;
                    _selectedCategories = [];
                  });
                },
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String label, String? value) {
    final isSelected = _type == value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            if (selected) {
              _type = value;
            } else if (_type == value) {
              _type = null;
            }
          });
        },
      ),
    );
  }

  Widget _buildCategoryChip(String label, String id) {
    final isSelected = _selectedCategories.contains(id);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedCategories.add(id);
          } else {
            _selectedCategories.remove(id);
          }
        });
      },
    );
  }
}
