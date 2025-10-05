import '../../domain/entities/analytics.dart';
import 'category_model.dart';

class AnalyticsResponseModel {
  final AnalyticsDataModel data;

  AnalyticsResponseModel({required this.data});

  AnalyticsData toEntity() => AnalyticsData(
    summary: data.summary.toEntity(),
    categoryBreakdown: data.categoryBreakdown
        .map((cb) => cb.toEntity())
        .toList(),
    monthlyTrend: data.monthlyTrend.map((mt) => mt.toEntity()).toList(),
    categoryTrends: {
      for (var entry in data.categoryTrends.entries)
        entry.key: entry.value.map((t) => t.toEntity()).toList(),
    },
  );

  factory AnalyticsResponseModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsResponseModel(
      data: AnalyticsDataModel.fromJson(json['data']),
    );
  }
}

// Model for "data" object
class AnalyticsDataModel {
  final AnalyticsSummaryModel summary;
  final List<CategoryBreakdownModel> categoryBreakdown;
  final List<MonthlyTrendModel> monthlyTrend;
  final Map<String, List<MonthlyTrendModel>> categoryTrends;

  AnalyticsDataModel({
    required this.summary,
    required this.categoryBreakdown,
    required this.monthlyTrend,
    required this.categoryTrends,
  });

  factory AnalyticsDataModel.fromJson(Map<String, dynamic> json) {
    final summary = AnalyticsSummaryModel.fromJson(json['summary']);
    final breakdown = (json['categoryBreakdown'] as List)
        .map((item) => CategoryBreakdownModel.fromJson(item))
        .toList();
    final trend = (json['monthlyTrend'] as List)
        .map((item) => MonthlyTrendModel.fromJson(item))
        .toList();
    final trendsMap = <String, List<MonthlyTrendModel>>{};
    final trendsJson = json['categoryTrends'] as Map<String, dynamic>?;
    if (trendsJson != null) {
      trendsJson.forEach((key, value) {
        final list = (value as List)
            .map((e) => MonthlyTrendModel.fromJson(e))
            .toList();
        trendsMap[key] = list;
      });
    }

    return AnalyticsDataModel(
      summary: summary,
      categoryBreakdown: breakdown,
      monthlyTrend: trend,
      categoryTrends: trendsMap,
    );
  }
}

class AnalyticsSummaryModel {
  final double totalIncome;
  final double totalExpense;
  final double netBalance;
  final double savingsRate;

  AnalyticsSummaryModel({
    required this.totalIncome,
    required this.totalExpense,
    required this.netBalance,
    required this.savingsRate,
  });

  AnalyticsSummary toEntity() => AnalyticsSummary(
    totalIncome: totalIncome,
    totalExpense: totalExpense,
    netBalance: netBalance,
    savingsRate: savingsRate,
  );

  factory AnalyticsSummaryModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsSummaryModel(
      totalIncome: (json['totalIncome'] as num?)?.toDouble() ?? 0.0,
      totalExpense: (json['totalExpense'] as num?)?.toDouble() ?? 0.0,
      netBalance: (json['netBalance'] as num?)?.toDouble() ?? 0.0,
      savingsRate: (json['savingsRate'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class CategoryBreakdownModel {
  final CategoryModel category;
  final double amount;
  final double percentage;
  final int transactionCount;
  final double budget;
  final double budgetUtilization;

  CategoryBreakdownModel({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.transactionCount,
    required this.budget,
    required this.budgetUtilization,
  });

  CategoryBreakdown toEntity() => CategoryBreakdown(
    category: category.toEntity(),
    amount: amount,
    percentage: percentage,
    transactionCount: transactionCount,
    budget: budget,
    budgetUtilization: budgetUtilization,
  );

  factory CategoryBreakdownModel.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdownModel(
      category: CategoryModel.fromJson(json['category']),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      transactionCount: json['transactionCount'] as int? ?? 0,
      budget: (json['budget'] as num?)?.toDouble() ?? 0.0,
      budgetUtilization: (json['budgetUtilization'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class MonthlyTrendModel {
  final String month;
  final double income;
  final double expense;

  MonthlyTrendModel({
    required this.month,
    required this.income,
    required this.expense,
  });

  MonthlyTrend toEntity() =>
      MonthlyTrend(month: month, income: income, expense: expense);

  factory MonthlyTrendModel.fromJson(Map<String, dynamic> json) {
    return MonthlyTrendModel(
      month: json['month'] as String? ?? '',
      income: (json['income'] as num?)?.toDouble() ?? 0.0,
      expense: (json['expense'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
