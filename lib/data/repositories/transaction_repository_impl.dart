import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/mock_api_service.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final MockApiService _service;

  final Map<String, List<Transaction>> _cache = {};

  TransactionRepositoryImpl(this._service);

  String _getCacheKey({
    required int page,
    required int limit,
    String? category,
    String? type,
    String? searchQuery,
  }) {
    return 'page:$page|limit:$limit|cat:$category|type:$type|search:$searchQuery';
  }

  @override
  Future<List<Transaction>> getTransactions({
    int page = 1,
    int limit = 20,
    String? category,
    String? type,
    String? searchQuery,
  }) async {
    final cacheKey = _getCacheKey(
      page: page,
      limit: limit,
      category: category,
      type: type,
      searchQuery: searchQuery,
    );

    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final transactions = await _service.getTransactions(
      page: page,
      limit: limit,
      category: category,
      type: type,
      searchQuery: searchQuery,
    );

    _cache[cacheKey] = transactions;
    return transactions;
  }

  @override
  Future<void> addTransaction(Transaction transaction) async {
    _cache.clear();
    return _service.addTransaction(transaction);
  }

  @override
  Future<void> updateTransaction(String id, Transaction transaction) async {
    _cache.clear();
    return _service.updateTransaction(id, transaction);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    _cache.clear();
    return _service.deleteTransaction(id);
  }
}
