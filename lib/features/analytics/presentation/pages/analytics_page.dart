import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/number_formatter.dart';
import '../../../../domain/entities/analytics.dart';
import '../../bloc/analytics_bloc.dart';
import '../../bloc/analytics_event.dart';
import '../../bloc/analytics_state.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage>
    with TickerProviderStateMixin {
  late final AnimationController _lineChartController;
  late final AnimationController _barChartController;
  String _selectedPeriod = 'month';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _lineChartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _barChartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _loadData();
  }

  void _loadData() {
    context.read<AnalyticsBloc>().add(LoadAnalytics(period: _selectedPeriod));
    _lineChartController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _barChartController.forward();
    });
  }

  @override
  void dispose() {
    _lineChartController.dispose();
    _barChartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: BlocBuilder<AnalyticsBloc, AnalyticsState>(
        builder: (context, state) {
          if (state is AnalyticsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AnalyticsLoaded) {
            return _buildContent(state.data);
          } else if (state is AnalyticsError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('Load analytics...'));
        },
      ),
    );
  }

  Widget _buildContent(AnalyticsData data) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Wrap(
          spacing: 8,
          children: [
            _buildPeriodChip('This Week', 'week'),
            _buildPeriodChip('This Month', 'month'),
            _buildPeriodChip('Last 3 Months', '3months'),
            _buildPeriodChip('Custom', 'custom'),
          ],
        ),
        const SizedBox(height: 24),

        Row(
          children: [
            _buildMetricCard(
              'Income',
              data.summary.totalIncome,
              Colors.green,
              '+2.3%',
            ),
            const SizedBox(width: 12),
            _buildMetricCard(
              'Expense',
              data.summary.totalExpense,
              Colors.red,
              '-1.1%',
            ),
            const SizedBox(width: 12),
            _buildMetricCard(
              'Balance',
              data.summary.netBalance,
              Colors.blue,
              '+5.2%',
            ),
          ],
        ),
        const SizedBox(height: 24),

        const Text(
          'Spending Trend',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(height: 250, child: _buildLineChart(data)),
        const SizedBox(height: 24),

        // Category Breakdown
        const Text(
          'Category Breakdown',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(height: 300, child: _buildBarChart(data.categoryBreakdown)),
        const SizedBox(height: 24),

        // Budget Progress
        const Text(
          'Budget Progress',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...data.categoryBreakdown.map(_buildBudgetProgress),
      ],
    );
  }

  Widget _buildPeriodChip(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedPeriod = value);
          _loadData();
        }
      },
    );
  }

  Widget _buildLineChart(AnalyticsData data) {
    final trend = _selectedCategory != null
        ? data.categoryTrends[_selectedCategory] ?? []
        : data.monthlyTrend;

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: trend.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value.income);
            }).toList(),
            color: Colors.green,
            barWidth: 2,
            isCurved: true,
            dotData: const FlDotData(show: true),
          ),
          LineChartBarData(
            spots: trend.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value.expense);
            }).toList(),
            color: Colors.red,
            barWidth: 2,
            isCurved: true,
            dotData: const FlDotData(show: true),
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < trend.length) {
                  return Text(trend[index].month.split('-').last);
                }
                return const Text('');
              },
              showTitles: true,
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              getTitlesWidget: (value, meta) {
                final formatted = _formatAsK(value); // e.g., 85000 → "85K"
                return Text(formatted);
              },
              showTitles: true,
            ),
          ),
        ),
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(enabled: true),
      ),
    );
  }

  String _formatAsK(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toInt()}K';
    }
    return value.toInt().toString();
  }

  Widget _buildBarChart(List<CategoryBreakdown> breakdown) {
    final sorted = List<CategoryBreakdown>.from(breakdown)
      ..sort((a, b) => b.amount.compareTo(a.amount));

    return BarChart(
      BarChartData(
        barGroups: sorted.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.amount,
                color: Color(
                  int.parse(e.value.category.color.substring(1), radix: 16) +
                      0xFF000000,
                ),
                width: 24,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < sorted.length) {
                  return RotatedBox(
                    quarterTurns: 1,
                    child: Container(
                      width: 70,
                      alignment: Alignment.center,
                      child: Text(
                        sorted[index].category.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
              showTitles: true,
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ), // 👈 HIDE LEFT AXIS
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              getTitlesWidget: (value, meta) {
                final formatted = _formatAsK(value);
                return Text(formatted);
              },
              showTitles: true,
            ),
          ),
        ),
        barTouchData: BarTouchData(enabled: true),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: true),
      ),
    );
  }

  Widget _buildMetricCard(
    String label,
    double value,
    Color color,
    String change,
  ) {
    return Expanded(
      child: Card(
        color: color.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: value),
                duration: const Duration(milliseconds: 800),
                builder: (context, val, child) => Text(
                  NumberFormatter.format(val),
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                change,
                style: TextStyle(
                  color: change.startsWith('+') ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetProgress(CategoryBreakdown item) {
    final utilization = item.budgetUtilization;
    Color getColor() {
      if (utilization <= 70) return Colors.green;
      if (utilization <= 90) return Colors.orange;
      return Colors.red;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: getColor().withValues(alpha: 0.2),
              child: Icon(_getIconData(item.category.icon), color: getColor()),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.category.name),
                  LinearProgressIndicator(
                    value: utilization / 100,
                    backgroundColor: Colors.grey[300],
                    color: getColor(),
                    minHeight: 6,
                  ),
                ],
              ),
            ),
            Text(
              '${NumberFormatter.format(item.amount)} / ${NumberFormatter.format(item.budget)}',
              style: TextStyle(color: getColor()),
            ),
          ],
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
