import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/mock_api_service.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final MockApiService _service;

  TransactionRepositoryImpl(this._service);

  @override
  Future<List<Transaction>> getTransactions({
    int page = 1,
    int limit = 20,
    String? category,
    String? type,
  }) async {
    return _service.getTransactions(
      page: page,
      limit: limit,
      category: category,
      type: type,
    );
  }

  @override
  Future<void> addTransaction(Transaction transaction) async {
    return _service.addTransaction(transaction);
  }

  @override
  Future<void> updateTransaction(String id, Transaction transaction) async {
    return _service.updateTransaction(id, transaction); // ✅ delegated
  }

  @override
  Future<void> deleteTransaction(String id) async {
    return _service.deleteTransaction(id); // ✅ delegated
  }
}
