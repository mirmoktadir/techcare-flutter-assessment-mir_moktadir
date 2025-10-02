import 'category.dart';

class AnalyticsData {
  final AnalyticsSummary summary;
  final List<CategoryBreakdown> categoryBreakdown;
  final List<MonthlyTrend> monthlyTrend;

  AnalyticsData({
    required this.summary,
    required this.categoryBreakdown,
    required this.monthlyTrend,
  });
}

class AnalyticsSummary {
  final double totalIncome;
  final double totalExpense;
  final double netBalance;
  final double savingsRate; // ← required

  AnalyticsSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.netBalance,
    required this.savingsRate, // ← must be passed
  });
}

class CategoryBreakdown {
  final Category category;
  final double amount;
  final double percentage;
  final int transactionCount;
  final double budget;
  final double budgetUtilization;

  CategoryBreakdown({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.transactionCount,
    required this.budget,
    required this.budgetUtilization,
  });
}

class MonthlyTrend {
  final String month;
  final double income;
  final double expense;

  MonthlyTrend({
    required this.month,
    required this.income,
    required this.expense,
  });
}
