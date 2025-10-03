import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/utils/number_formatter.dart';
import '../../../../domain/entities/transaction.dart';
import '../../bloc/transaction_bloc.dart';
import '../../bloc/transaction_event.dart';
import '../../bloc/transaction_state.dart';
import '../widgets/filter_bottom_sheet.dart';
import 'add_transaction_page.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Map<String, dynamic> _filters = {};
  bool _isSearching = false;
  late StreamController<String> _searchStreamController;
  StreamSubscription? _searchSubscription;
  @override
  void initState() {
    super.initState();
    _searchStreamController = StreamController<String>();
    _searchSubscription = _searchStreamController.stream
        .debounceTime(const Duration(milliseconds: 300))
        .listen((query) {
          _loadTransactions(searchQuery: query);
        });
    _loadTransactions();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchStreamController.close();
    _searchSubscription?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadTransactions({String? searchQuery}) {
    context.read<TransactionBloc>().add(
      LoadTransactions(1, _filters, searchQuery: searchQuery),
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      final state = context.read<TransactionBloc>().state;
      if (state is TransactionLoaded && state.hasMore) {
        final nextPage = (state.transactions.length / 20).ceil() + 1;
        context.read<TransactionBloc>().add(
          LoadTransactions(
            nextPage,
            _filters,
            searchQuery: _isSearching ? _searchController.text : null,
          ),
        );
      }
    }
  }

  int _getActiveFilterCount() {
    return _filters.entries.where((e) => e.value != null).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search transactions...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  _searchStreamController.add(value);
                },
                onSubmitted: (value) => _loadTransactions(searchQuery: value),
              )
            : const Text('Transactions'),
        actions: [
          if (!_isSearching)
            IconButton(
              onPressed: () => setState(() => _isSearching = true),
              icon: const Icon(Icons.search),
            ),
          if (_isSearching)
            IconButton(
              onPressed: () {
                _searchController.clear();
                setState(() => _isSearching = false);
                _loadTransactions();
              },
              icon: const Icon(Icons.close),
            ),
        ],
      ),
      body: Column(
        children: [
          // 🔹 Filter Chip
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Chip(
                  label: Text(
                    'Filters ${_getActiveFilterCount() > 0 ? '(${_getActiveFilterCount()})' : ''}',
                  ),
                  onDeleted: _getActiveFilterCount() > 0
                      ? () {
                          setState(() {
                            _filters = {};
                          });
                          _loadTransactions();
                        }
                      : null,
                  deleteIcon: _getActiveFilterCount() > 0
                      ? const Icon(Icons.filter_alt_off)
                      : null,
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => FilterBottomSheet(
                        initialFilters: _filters,
                        onApply: (newFilters) {
                          setState(() {
                            _filters = newFilters;
                          });
                          Navigator.pop(context);
                          _loadTransactions();
                        },
                      ),
                    );
                  },
                  child: const Text('Filter'),
                ),
              ],
            ),
          ),
          // 🔹 Transaction List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _loadTransactions(),
              child: BlocBuilder<TransactionBloc, TransactionState>(
                builder: (context, state) {
                  if (state is TransactionLoading &&
                      state.transactions == null) {
                    return _buildShimmerList();
                  } else if (state is TransactionLoaded) {
                    if (state.transactions.isEmpty) {
                      return const Center(child: Text('No transactions found'));
                    }
                    return _buildTransactionList(state.transactions);
                  } else if (state is TransactionError) {
                    return Center(child: Text('Error: ${state.message}'));
                  } else {
                    return const Center(child: Text('No data'));
                  }
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        onPressed: () {
          final bloc = context.read<TransactionBloc>();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider.value(
                value: bloc,
                child: const AddTransactionPage(),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: 10,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: const ListTile(
          leading: CircleAvatar(),
          title: SizedBox(height: 16, width: 120),
          subtitle: SizedBox(height: 14, width: 80),
          trailing: SizedBox(height: 16, width: 60),
        ),
      ),
    );
  }

  Widget _buildTransactionList(List<Transaction> transactions) {
    // Group by date
    final grouped = _groupTransactionsByDate(transactions);

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        for (int i = 0; i < grouped.length; i++)
          SliverStickyHeader(
            header: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey[200],
              child: Text(_formatDate(grouped.keys.elementAt(i))),
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final txn = grouped.values.elementAt(i)[index];
                return Slidable(
                  startActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) => _editTransaction(txn),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        icon: Icons.edit,
                      ),
                    ],
                  ),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) => _deleteTransaction(txn.id),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: txn.type == 'income'
                          ? Colors.green.withValues(alpha: 0.2)
                          : Colors.red.withValues(alpha: 0.2),
                      child: Icon(
                        txn.type == 'income'
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color: txn.type == 'income' ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text(txn.title),
                    subtitle: Text(
                      '${txn.category.name} • ${_formatTime(txn.date)}',
                    ),
                    trailing: Text(NumberFormatter.format(txn.amount)),
                  ),
                );
              }, childCount: grouped.values.elementAt(i).length),
            ),
          ),
      ],
    );
  }

  Map<DateTime, List<Transaction>> _groupTransactionsByDate(
    List<Transaction> transactions,
  ) {
    final map = <DateTime, List<Transaction>>{};
    for (var txn in transactions) {
      final date = DateTime(txn.date.year, txn.date.month, txn.date.day);
      map.putIfAbsent(date, () => []).add(txn);
    }
    final sortedKeys = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return {for (var key in sortedKeys) key: map[key]!};
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _editTransaction(Transaction txn) {
    final bloc = context.read<TransactionBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: bloc,
          child: AddTransactionPage(transaction: txn),
        ),
      ),
    );
  }

  void _deleteTransaction(String id) {
    context.read<TransactionBloc>().add(DeleteTransaction(id));
  }
}
