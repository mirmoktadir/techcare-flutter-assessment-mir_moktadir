import 'dart:math';

import '../../domain/entities/analytics.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/transaction.dart';

class MockApiService {
  final Random _random = Random();

  // Full sample data from spec
  static final List<Transaction> _transactions = [
    Transaction(
      id: "txn_001",
      title: "Salary",
      amount: 85000.00,
      type: "income",
      category: Category(
        id: "cat_income",
        name: "Salary",
        icon: "payments",
        color: "#00C853",
        budget: 0,
      ),
      date: DateTime.parse("2025-10-01T00:00:00Z"),
      description: "Monthly salary deposit",
    ),
    Transaction(
      id: "txn_002",
      title: "Grocery Shopping",
      amount: 2500.00,
      type: "expense",
      category: Category(
        id: "cat_001",
        name: "Food & Dining",
        icon: "restaurant",
        color: "#FF6B6B",
        budget: 20000,
      ),
      date: DateTime.parse("2025-10-01T10:30:00Z"),
      description: "Weekly groceries from Shwapno",
    ),
    Transaction(
      id: "txn_003",
      title: "Uber Ride",
      amount: 350.00,
      type: "expense",
      category: Category(
        id: "cat_002",
        name: "Transportation",
        icon: "directions_car",
        color: "#4ECDC4",
        budget: 15000,
      ),
      date: DateTime.parse("2025-10-01T14:15:00Z"),
      description: "Ride to office",
    ),
    Transaction(
      id: "txn_004",
      title: "Netflix Subscription",
      amount: 800.00,
      type: "expense",
      category: Category(
        id: "cat_004",
        name: "Entertainment",
        icon: "movie",
        color: "#95E1D3",
        budget: 8000,
      ),
      date: DateTime.parse("2025-09-30T08:00:00Z"),
      description: "Monthly subscription",
    ),
    Transaction(
      id: "txn_005",
      title: "Electricity Bill",
      amount: 3200.00,
      type: "expense",
      category: Category(
        id: "cat_005",
        name: "Bills & Utilities",
        icon: "receipt",
        color: "#F38181",
        budget: 12000,
      ),
      date: DateTime.parse("2025-09-28T16:45:00Z"),
      description: "September electricity bill",
    ),
    Transaction(
      id: "txn_006",
      title: "Online Shopping",
      amount: 4500.00,
      type: "expense",
      category: Category(
        id: "cat_003",
        name: "Shopping",
        icon: "shopping_bag",
        color: "#FFD93D",
        budget: 10000,
      ),
      date: DateTime.parse("2025-09-27T20:30:00Z"),
      description: "Clothing from Daraz",
    ),
    Transaction(
      id: "txn_007",
      title: "Restaurant Dinner",
      amount: 1800.00,
      type: "expense",
      category: Category(
        id: "cat_001",
        name: "Food & Dining",
        icon: "restaurant",
        color: "#FF6B6B",
        budget: 20000,
      ),
      date: DateTime.parse("2025-09-26T19:00:00Z"),
      description: "Dinner at The Kabab Factory",
    ),
    Transaction(
      id: "txn_008",
      title: "Freelance Project",
      amount: 15000.00,
      type: "income",
      category: Category(
        id: "cat_freelance",
        name: "Freelance",
        icon: "work",
        color: "#00C853",
        budget: 0,
      ),
      date: DateTime.parse("2025-09-25T12:00:00Z"),
      description: "Payment for mobile app project",
    ),
    Transaction(
      id: "txn_009",
      title: "Internet Bill",
      amount: 1500.00,
      type: "expense",
      category: Category(
        id: "cat_005",
        name: "Bills & Utilities",
        icon: "receipt",
        color: "#F38181",
        budget: 12000,
      ),
      date: DateTime.parse("2025-09-24T11:00:00Z"),
      description: "Monthly broadband bill",
    ),
    Transaction(
      id: "txn_010",
      title: "Coffee Shop",
      amount: 450.00,
      type: "expense",
      category: Category(
        id: "cat_001",
        name: "Food & Dining",
        icon: "restaurant",
        color: "#FF6B6B",
        budget: 20000,
      ),
      date: DateTime.parse("2025-09-23T09:30:00Z"),
      description: "Morning coffee at Barista",
    ),
  ];

  static final List<Category> _categories = [
    Category(
      id: "cat_001",
      name: "Food & Dining",
      icon: "restaurant",
      color: "#FF6B6B",
      budget: 20000,
    ),
    Category(
      id: "cat_002",
      name: "Transportation",
      icon: "directions_car",
      color: "#4ECDC4",
      budget: 15000,
    ),
    Category(
      id: "cat_003",
      name: "Shopping",
      icon: "shopping_bag",
      color: "#FFD93D",
      budget: 10000,
    ),
    Category(
      id: "cat_004",
      name: "Entertainment",
      icon: "movie",
      color: "#95E1D3",
      budget: 8000,
    ),
    Category(
      id: "cat_005",
      name: "Bills & Utilities",
      icon: "receipt",
      color: "#F38181",
      budget: 12000,
    ),
    Category(
      id: "cat_income",
      name: "Salary",
      icon: "payments",
      color: "#00C853",
      budget: 0,
    ),
    Category(
      id: "cat_freelance",
      name: "Freelance",
      icon: "work",
      color: "#00C853",
      budget: 0,
    ),
  ];

  static final AnalyticsData _analytics = AnalyticsData(
    summary: AnalyticsSummary(
      totalIncome: 85000.00,
      totalExpense: 52000.00,
      netBalance: 33000.00,
      savingsRate: 38.8,
    ),
    categoryBreakdown: [
      CategoryBreakdown(
        category: Category(
          id: "cat_001",
          name: "Food & Dining",
          icon: "restaurant",
          color: "#FF6B6B",
          budget: 20000,
        ),
        amount: 18000.00,
        percentage: 34.6,
        transactionCount: 45,
        budget: 20000.00,
        budgetUtilization: 90.0,
      ),
      CategoryBreakdown(
        category: Category(
          id: "cat_002",
          name: "Transportation",
          icon: "directions_car",
          color: "#4ECDC4",
          budget: 15000,
        ),
        amount: 12000.00,
        percentage: 23.1,
        transactionCount: 28,
        budget: 15000.00,
        budgetUtilization: 80.0,
      ),
      CategoryBreakdown(
        category: Category(
          id: "cat_003",
          name: "Shopping",
          icon: "shopping_bag",
          color: "#FFD93D",
          budget: 10000,
        ),
        amount: 4500.00,
        percentage: 8.7,
        transactionCount: 12,
        budget: 10000.00,
        budgetUtilization: 45.0,
      ),
      CategoryBreakdown(
        category: Category(
          id: "cat_004",
          name: "Entertainment",
          icon: "movie",
          color: "#95E1D3",
          budget: 8000,
        ),
        amount: 800.00,
        percentage: 1.5,
        transactionCount: 3,
        budget: 8000.00,
        budgetUtilization: 10.0,
      ),
      CategoryBreakdown(
        category: Category(
          id: "cat_005",
          name: "Bills & Utilities",
          icon: "receipt",
          color: "#F38181",
          budget: 12000,
        ),
        amount: 4700.00,
        percentage: 9.0,
        transactionCount: 8,
        budget: 12000.00,
        budgetUtilization: 39.2,
      ),
    ],
    monthlyTrend: [
      MonthlyTrend(month: "2025-04", income: 78000.00, expense: 45000.00),
      MonthlyTrend(month: "2025-05", income: 80000.00, expense: 48000.00),
      MonthlyTrend(month: "2025-06", income: 82000.00, expense: 51000.00),
      MonthlyTrend(month: "2025-07", income: 85000.00, expense: 52000.00),
      MonthlyTrend(month: "2025-08", income: 83000.00, expense: 49000.00),
      MonthlyTrend(month: "2025-09", income: 85000.00, expense: 52000.00),
    ],
  );

  Future<List<Transaction>> getTransactions({
    int page = 1,
    int limit = 20,
    String? category,
    String? type,
    String? searchQuery,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (_random.nextInt(10) == 0) throw Exception('Network error');

    final filtered = _transactions.where((t) {
      if (type != null && t.type != type) return false;
      if (category != null && t.category.id != category) return false;
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        if (!t.title.toLowerCase().contains(query) &&
            !(t.description?.toLowerCase().contains(query) ?? false) &&
            !t.category.name.toLowerCase().contains(query)) {
          return false;
        }
      }
      return true;
    }).toList();

    final start = (page - 1) * limit;
    final end = start + limit;
    return filtered.skip(start).take(end).toList();
  }

  Future<List<Category>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _categories;
  }

  Future<AnalyticsData> getAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _analytics;
  }

  Future<void> addTransaction(Transaction transaction) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _transactions.insert(0, transaction);
    // In real app: add to list
  }

  Future<void> updateTransaction(
    String id,
    Transaction updatedTransaction,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index != -1) {
      _transactions[index] = updatedTransaction;
    }
  }

  Future<void> deleteTransaction(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _transactions.removeWhere((t) => t.id == id);
  }
}
