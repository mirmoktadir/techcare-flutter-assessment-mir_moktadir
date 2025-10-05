import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/utils/number_formatter.dart';
import '../../../../domain/entities/analytics.dart';
import '../../../../domain/entities/transaction.dart';
import '../../../analytics/bloc/analytics_bloc.dart';
import '../../../analytics/bloc/analytics_event.dart';
import '../../../analytics/bloc/analytics_state.dart';
import '../../../categories/bloc/category_bloc.dart';
import '../../../categories/bloc/category_event.dart';
import '../../../transactions/bloc/transaction_bloc.dart';
import '../../../transactions/bloc/transaction_event.dart';
import '../../../transactions/bloc/transaction_state.dart';
import '../../../transactions/presentation/pages/add_transaction_page.dart';
import '../../../transactions/presentation/pages/transaction_details_page.dart';
import '../../../transactions/presentation/pages/transactions_page.dart';
import '../widgets/balance_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _showBalance = true;

  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(LoadTransactions(1, {}, limit: 10));
    context.read<AnalyticsBloc>().add(LoadAnalytics());
    context.read<CategoryBloc>().add(LoadCategories());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<TransactionBloc>().add(LoadTransactions(1, {}));
            context.read<AnalyticsBloc>().add(LoadAnalytics());
          },
          child: CustomScrollView(
            slivers: [
              // 🔹 Header with Parallax
              SliverAppBar(
                pinned: true,
                expandedHeight: 100,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.all(16),
                  title: Row(
                    children: [
                      const Text(
                        'Finance Tracker',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        height: 40,
                        width: 100,
                        child: Stack(
                          children: [
                            Positioned(
                              bottom: 0,
                              right: 2,
                              child: const CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.white30,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Text(
                                  '3',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF10A1D9), Color(0xFF9EF3E8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              ),

              // 🔹 Balance Card
              SliverToBoxAdapter(
                child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
                  builder: (context, state) {
                    if (state is AnalyticsLoaded) {
                      return BalanceCard(
                        balance: state.data.summary.netBalance,
                        income: state.data.summary.totalIncome,
                        expense: state.data.summary.totalExpense,
                        showBalance: _showBalance,
                        onToggle: () =>
                            setState(() => _showBalance = !_showBalance),
                      );
                    } else if (state is AnalyticsLoading) {
                      return _buildBalanceShimmer();
                    } else {
                      return _buildErrorCard('Failed to load balance');
                    }
                  },
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // 🔹 Spending Pie Chart
              SliverToBoxAdapter(
                child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
                  builder: (context, state) {
                    if (state is AnalyticsLoaded) {
                      final breakdown = state.data.categoryBreakdown
                          .where(
                            (b) =>
                                b.category.id != 'cat_income' &&
                                b.category.id != 'cat_freelance',
                          )
                          .toList();
                      return _buildPieChart(breakdown);
                    } else if (state is AnalyticsLoading) {
                      return _buildChartShimmer();
                    } else {
                      return _buildErrorCard('Failed to load spending data');
                    }
                  },
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // 🔹 Recent Transactions
              SliverToBoxAdapter(
                child: BlocBuilder<TransactionBloc, TransactionState>(
                  builder: (context, state) {
                    if (state is TransactionLoaded) {
                      final grouped = _groupTransactionsByDate(
                        state.transactions,
                      );
                      return _buildTransactionGroups(grouped, context);
                    } else if (state is TransactionLoading) {
                      return _buildTransactionListShimmer();
                    } else {
                      return _buildErrorCard('Failed to load transactions');
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        onPressed: () {
          final bloc = context.read<TransactionBloc>(); // get existing instance
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

  Map<DateTime, List<Transaction>> _groupTransactionsByDate(
    List<Transaction> transactions,
  ) {
    final map = <DateTime, List<Transaction>>{};
    for (var txn in transactions.take(10)) {
      final date = DateTime(txn.date.year, txn.date.month, txn.date.day);
      map.putIfAbsent(date, () => []).add(txn);
    }

    final sortedKeys = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return {for (var key in sortedKeys) key: map[key]!};
  }

  Widget _buildSwipeableItem(Transaction txn, BuildContext context) {
    return Slidable(
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _editTransaction(txn, context),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _deleteTransaction(txn.id, context),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: ListTile(
        onTap: () {
          final transactionBloc = context.read<TransactionBloc>();

          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return BlocProvider.value(
                value: transactionBloc,
                child: TransactionDetailsPage(
                  transaction: txn,
                  heroTag: 'amount_${txn.id}',
                ),
              );
            },
          );
        },
        leading: CircleAvatar(
          backgroundColor: txn.type == 'income'
              ? Colors.green.withValues(alpha: 0.2)
              : Colors.red.withValues(alpha: 0.2),
          child: Icon(
            txn.type == 'income' ? Icons.arrow_upward : Icons.arrow_downward,
            color: txn.type == 'income' ? Colors.green : Colors.red,
          ),
        ),
        title: Text(txn.title),
        subtitle: Text(txn.category.name),
        trailing: Text(NumberFormatter.format(txn.amount)),
      ),
    );
  }

  void _editTransaction(Transaction txn, BuildContext context) {
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

  void _deleteTransaction(String id, BuildContext context) async {
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
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      if (context.mounted) {
        context.read<TransactionBloc>().add(DeleteTransaction(id));
      }
    }
  }

  Widget _buildPieChart(List<CategoryBreakdown> breakdown) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Spending Overview',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            AspectRatio(
              aspectRatio: 1.15,
              child: PieChart(
                PieChartData(
                  sections: breakdown.map((b) {
                    return PieChartSectionData(
                      value: b.amount,
                      color: Color(
                        int.parse(b.category.color.substring(1), radix: 16) +
                            0xFF000000,
                      ),
                      radius: 60,
                      title: '${b.percentage.toStringAsFixed(1)}%',
                      titleStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      showTitle: true,
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 45,
                  startDegreeOffset: -90,
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: breakdown.map((b) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Color(
                          int.parse(b.category.color.substring(1), radix: 16) +
                              0xFF000000,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(b.category.name, style: const TextStyle(fontSize: 12)),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceShimmer() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(height: 180, padding: const EdgeInsets.all(20)),
      ),
    );
  }

  Widget _buildChartShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 250,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildTransactionListShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Recent Transactions',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
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
        ),
      ],
    );
  }

  Widget _buildErrorCard(String message) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(child: Text(message)),
      ),
    );
  }

  Widget _buildTransactionGroups(
    Map<DateTime, List<Transaction>> grouped,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Recent Transactions',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        const SizedBox(height: 8),

        SizedBox(
          height: 400,
          child: CustomScrollView(
            slivers: [
              for (int index = 0; index < grouped.length; index++)
                SliverStickyHeader(
                  header: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: Colors.grey[200],
                    child: Text(
                      _formatDate(grouped.keys.elementAt(index)),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      grouped.values
                          .elementAt(index)
                          .map((txn) => _buildSwipeableItem(txn, context))
                          .toList(),
                    ),
                  ),
                ),
            ],
          ),
        ),
        TextButton(
          onPressed: () {
            final transactionBloc = context.read<TransactionBloc>();

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider.value(
                  value: transactionBloc,
                  child: const TransactionsPage(),
                ),
              ),
            );
          },
          child: const Text(
            'View All Transactions',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMMM d, yyyy').format(date);
  }
}
