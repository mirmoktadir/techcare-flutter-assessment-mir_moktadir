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
  bool _showLineChart = false;
  bool _showBarChart = false;

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

    // Load data and start animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsBloc>().add(LoadAnalytics());
      _lineChartController.forward();
      Future.delayed(const Duration(milliseconds: 300), () {
        _barChartController.forward();
      });
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
        // Summary Cards
        Row(
          children: [
            _buildMetricCard('Income', data.summary.totalIncome, Colors.green),
            const SizedBox(width: 12),
            _buildMetricCard('Expense', data.summary.totalExpense, Colors.red),
            const SizedBox(width: 12),
            _buildMetricCard('Balance', data.summary.netBalance, Colors.blue),
          ],
        ),
        const SizedBox(height: 24),

        // Spending Trend Chart
        const Text(
          'Spending Trend (Last 6 Months)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        SizedBox(height: 250, child: _buildLineChart(data.monthlyTrend)),
        const SizedBox(height: 24),

        // Category Breakdown
        const Text(
          'Category Breakdown',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        SizedBox(height: 200, child: _buildBarChart(data.categoryBreakdown)),
        const SizedBox(height: 24),

        // Budget Progress
        const Text(
          'Budget Progress',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 12),
        ...data.categoryBreakdown.map(_buildBudgetProgress).toList(),
      ],
    );
  }

  Widget _buildLineChart(List<MonthlyTrend> trend) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: trend.asMap().entries.map((e) {
              return FlSpot(
                e.key.toDouble(),
                _lineChartController.value * e.value.income,
              );
            }).toList(),
            color: Colors.green,
            barWidth: 2,
            isCurved: true,
            dotData: const FlDotData(show: false),
          ),
          LineChartBarData(
            spots: trend.asMap().entries.map((e) {
              return FlSpot(
                e.key.toDouble(),
                _lineChartController.value * e.value.expense,
              );
            }).toList(),
            color: Colors.red,
            barWidth: 2,
            isCurved: true,
            dotData: const FlDotData(show: false),
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
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildBarChart(List<CategoryBreakdown> breakdown) {
    return BarChart(
      BarChartData(
        barGroups: breakdown.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: _barChartController.value * e.value.amount,
                color: Color(
                  int.parse(e.value.category.color.substring(1), radix: 16) +
                      0xFF000000,
                ),
                width: 20,
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
                if (index >= 0 && index < breakdown.length) {
                  return RotatedBox(
                    quarterTurns: 1,
                    child: Text(breakdown[index].category.name),
                  );
                }
                return const Text('');
              },
              showTitles: true,
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: true),
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
              backgroundColor: getColor().withOpacity(0.2),
              child: Icon(_getIconData(item.category.icon), color: getColor()),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.category.name),
                  const SizedBox(height: 4),
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

  Widget _buildMetricCard(String label, double value, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                NumberFormatter.format(value),
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
