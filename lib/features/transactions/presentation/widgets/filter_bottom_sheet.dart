import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FilterBottomSheet extends StatefulWidget {
  final Map<String, dynamic> initialFilters;
  final List<String> categories;
  final Function(Map<String, dynamic>) onApply;

  const FilterBottomSheet({
    super.key,
    required this.initialFilters,
    required this.categories,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  // 🔹 Date Range
  String? _selectedPreset;
  DateTimeRange? _customRange;

  // 🔹 Categories
  Set<String> _selectedCategories = {};

  // 🔹 Amount Range
  RangeValues _amountRange = const RangeValues(0, 50000);

  // 🔹 Type
  String? _type;

  @override
  void initState() {
    super.initState();
    _initializeFilters();
  }

  void _initializeFilters() {
    final filters = widget.initialFilters;

    // Date
    if (filters['datePreset'] != null) {
      _selectedPreset = filters['datePreset'];
    }
    if (filters['customRange'] != null) {
      _customRange = filters['customRange'];
    }

    // Categories
    if (filters['categories'] is List) {
      _selectedCategories = Set<String>.from(filters['categories']);
    }

    // Amount
    if (filters['amountMin'] != null && filters['amountMax'] != null) {
      _amountRange = RangeValues(
        filters['amountMin'].toDouble(),
        filters['amountMax'].toDouble(),
      );
    }

    // Type
    _type = filters['type'];
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (_selectedPreset != null || _customRange != null) count++;
    if (_selectedCategories.isNotEmpty) count++;
    if (_amountRange.start > 0 || _amountRange.end < 50000) count++;
    if (_type != null) count++;
    return count;
  }

  // 🔹 Date Presets Logic
  void _applyDatePreset(String preset) {
    setState(() {
      _selectedPreset = preset;
      _customRange = null;
    });
  }

  DateTimeRange _getDateRangeFromPreset(String preset) {
    final now = DateTime.now();
    switch (preset) {
      case 'Today':
        return DateTimeRange(start: now, end: now);
      case 'This Week':
        final start = now.subtract(Duration(days: now.weekday - 1));
        return DateTimeRange(start: start, end: now);
      case 'This Month':
        return DateTimeRange(start: DateTime(now.year, now.month, 1), end: now);
      case 'Last 3 Months':
        final start = DateTime(now.year, now.month - 2, 1);
        return DateTimeRange(start: start, end: now);
      default:
        return DateTimeRange(start: now, end: now);
    }
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
          // 🔹 Header with active filter count
          Row(
            children: [
              const Text(
                'Filters',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_getActiveFilterCount()} active',
                  style: const TextStyle(color: Colors.blue, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 🔹 Date Range
          const Text(
            'Date Range',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildDateChip('Today', 'Today'),
              _buildDateChip('This Week', 'This Week'),
              _buildDateChip('This Month', 'This Month'),
              _buildDateChip('Last 3 Months', 'Last 3 Months'),
              ChoiceChip(
                label: const Text('Custom'),
                selected: _selectedPreset == null && _customRange != null,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedPreset = null;
                      // Open date range picker (simplified: use current range or today)
                      _customRange = DateTimeRange(
                        start: DateTime.now().subtract(
                          const Duration(days: 30),
                        ),
                        end: DateTime.now(),
                      );
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 🔹 Categories
          const Text(
            'Categories',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.categories.map((category) {
              return FilterChip(
                label: Text(category),
                selected: _selectedCategories.contains(category),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedCategories.add(category);
                    } else {
                      _selectedCategories.remove(category);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // 🔹 Amount Range
          const Text(
            'Amount Range',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          RangeSlider(
            values: _amountRange,
            min: 0,
            max: 100000,
            divisions: 100,
            labels: RangeLabels(
              NumberFormat.simpleCurrency(
                locale: 'bn-BD',
              ).format(_amountRange.start),
              NumberFormat.simpleCurrency(
                locale: 'bn-BD',
              ).format(_amountRange.end),
            ),
            onChanged: (values) {
              setState(() {
                _amountRange = values;
              });
            },
          ),
          const SizedBox(height: 16),

          // 🔹 Transaction Type
          const Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              _buildTypeChip('All', null),
              _buildTypeChip('Income', 'income'),
              _buildTypeChip('Expense', 'expense'),
            ],
          ),
          const SizedBox(height: 16),

          // 🔹 Apply / Reset
          Row(
            children: [
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    final filters = <String, dynamic>{};

                    // Date
                    if (_selectedPreset != null) {
                      filters['datePreset'] = _selectedPreset;
                      filters['dateRange'] = _getDateRangeFromPreset(
                        _selectedPreset!,
                      );
                    } else if (_customRange != null) {
                      filters['customRange'] = _customRange;
                    }

                    // Categories
                    if (_selectedCategories.isNotEmpty) {
                      filters['categories'] = _selectedCategories.toList();
                    }

                    // Amount
                    filters['amountMin'] = _amountRange.start;
                    filters['amountMax'] = _amountRange.end;

                    // Type
                    if (_type != null) {
                      filters['type'] = _type;
                    }

                    widget.onApply(filters);
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _selectedPreset = null;
                      _customRange = null;
                      _selectedCategories = {};
                      _amountRange = const RangeValues(0, 50000);
                      _type = null;
                    });
                  },
                  child: const Text('Reset'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDateChip(String label, String value) {
    final isSelected = _selectedPreset == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) _applyDatePreset(value);
      },
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
          if (selected) {
            setState(() => _type = value);
          } else if (_type == value) {
            setState(() => _type = null);
          }
        },
      ),
    );
  }
}
