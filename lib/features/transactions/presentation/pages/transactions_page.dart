import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/transaction_bloc.dart';
import '../../bloc/transaction_event.dart';
import '../../bloc/transaction_state.dart';
import '../widgets/transaction_list_item.dart';
import 'add_transaction_page.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  late ScrollController _scrollController;
  int _page = 1;
  final Map<String, dynamic> _filters = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    context.read<TransactionBloc>().add(LoadTransactions(_page, _filters));
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      final bloc = context.read<TransactionBloc>();
      if (bloc.state is TransactionLoaded) {
        final loaded = bloc.state as TransactionLoaded;
        if (loaded.hasMore) {
          setState(() {
            _page++;
          });
          bloc.add(LoadTransactions(_page, _filters));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TransactionLoaded) {
            return ListView.builder(
              controller: _scrollController,
              itemCount: state.transactions.length,
              itemBuilder: (context, index) {
                return TransactionListItem(
                  transaction: state.transactions[index],
                );
              },
            );
          } else if (state is TransactionError) {
            return Center(child: Text('Error: ${state.message}'));
          } else {
            return const Center(child: Text('No data'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
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
}
