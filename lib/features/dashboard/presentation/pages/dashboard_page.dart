import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
    // Load all required data
    context.read<TransactionBloc>().add(LoadTransactions(1, {}));
    context.read<AnalyticsBloc>().add(LoadAnalytics());
    context.read<CategoryBloc>().add(LoadCategories());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
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
                      ),
                    ),
                    const Spacer(),
                    Stack(
                      children: [
                        const CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white30,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Text(
                              '3',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => SizedBox(
              height: 140,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildFabOption(
                    'Add Income',
                    Icons.arrow_upward,
                    Colors.green,
                    'income',
                    context,
                  ),
                  const SizedBox(height: 12),
                  _buildFabOption(
                    'Add Expense',
                    Icons.arrow_downward,
                    Colors.red,
                    'expense',
                    context,
                  ),
                ],
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // 🔹 GROUP TRANSACTIONS BY DATE
  Map<String, List<Transaction>> _groupTransactionsByDate(
    List<Transaction> transactions,
  ) {
    final map = <String, List<Transaction>>{};
    for (var txn in transactions.take(10)) {
      final key = '${txn.date.day}/${txn.date.month}';
      map.putIfAbsent(key, () => []).add(txn);
    }
    return map;
  }

  // 🔹 SWIPEABLE TRANSACTION ITEM
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<TransactionBloc>(),
          child: AddTransactionPage(transaction: txn),
        ),
      ),
    );
  }

  void _deleteTransaction(String id, BuildContext context) {
    context.read<TransactionBloc>().add(DeleteTransaction(id));
  }

  // 🔹 FAB OPTIONS
  Widget _buildFabOption(
    String label,
    IconData icon,
    Color color,
    String type,
    BuildContext context,
  ) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      icon: Icon(icon),
      label: Text(label),
      onPressed: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider.value(
              value: context.read<TransactionBloc>(),
              child: AddTransactionPage(type: type),
            ),
          ),
        );
      },
    );
  }

  // 🔹 PIE CHART
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
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                  sections: breakdown.map((b) {
                    return PieChartSectionData(
                      value: b.amount,
                      color: Color(
                        int.parse(b.category.color.substring(1), radix: 16) +
                            0xFF000000,
                      ),
                      radius: 50,
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
                  centerSpaceRadius: 60,
                  startDegreeOffset: -90,
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      // Optional: highlight on tap
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Add legend
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

  // 🔹 SHIMMER LOADERS
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

  // 🔹 TRANSACTION GROUPS
  Widget _buildTransactionGroups(
    Map<String, List<Transaction>> grouped,
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
        ...grouped.entries.map((entry) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  entry.key,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ...entry.value.map((txn) => _buildSwipeableItem(txn, context)),
            ],
          );
        }),
        TextButton(
          onPressed: () {
            // 🔹 Get the existing BLoC instance from current context
            final transactionBloc = context.read<TransactionBloc>();

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider.value(
                  value: transactionBloc, // 👈 Reuse existing instance
                  child: const TransactionsPage(),
                ),
              ),
            );
          },
          child: const Text('View All Transactions'),
        ),
      ],
    );
  }
}
