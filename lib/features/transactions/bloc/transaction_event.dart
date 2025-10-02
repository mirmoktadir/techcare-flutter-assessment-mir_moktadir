import 'package:equatable/equatable.dart';

import '../../../domain/entities/transaction.dart';

abstract class TransactionEvent extends Equatable {}

class LoadTransactions extends TransactionEvent {
  final int page;
  final Map<String, dynamic> filters;

  LoadTransactions(this.page, this.filters);

  @override
  List<Object?> get props => [page, filters];
}

class AddTransaction extends TransactionEvent {
  final Transaction transaction;

  AddTransaction(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class UpdateTransaction extends TransactionEvent {
  final String id;
  final Transaction transaction;
  UpdateTransaction(this.id, this.transaction);
  @override
  List<Object?> get props => [id, transaction];
}

class DeleteTransaction extends TransactionEvent {
  final String id;
  DeleteTransaction(this.id);
  @override
  List<Object?> get props => [id];
}

class TransactionOperationComplete extends TransactionEvent {
  @override
  List<Object?> get props => [];
}
