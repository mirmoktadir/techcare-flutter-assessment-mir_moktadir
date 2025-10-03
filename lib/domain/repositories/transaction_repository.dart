import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<List<Transaction>> getTransactions({
    int page,
    String? category,
    String? type,
    int limit,
    String? searchQuery,
  });
  Future<void> addTransaction(Transaction transaction);
  Future<void> updateTransaction(String id, Transaction transaction);
  Future<void> deleteTransaction(String id);
}
