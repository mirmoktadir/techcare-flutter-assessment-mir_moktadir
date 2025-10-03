import 'package:equatable/equatable.dart';

import '../../../domain/entities/transaction.dart';

abstract class TransactionState extends Equatable {}

class TransactionInitial extends TransactionState {
  @override
  List<Object?> get props => [];
}

class TransactionLoading extends TransactionState {
  late final List<Transaction>? transactions;
  TransactionLoading({this.transactions});
  @override
  List<Object?> get props => [transactions];
}

class TransactionLoaded extends TransactionState {
  final List<Transaction> transactions;
  final bool hasMore;

  TransactionLoaded(this.transactions, this.hasMore);

  @override
  List<Object?> get props => [transactions, hasMore];

  TransactionLoaded copyWith({List<Transaction>? transactions, bool? hasMore}) {
    return TransactionLoaded(
      transactions ?? this.transactions,
      hasMore ?? this.hasMore,
    );
  }
}

class TransactionOperationInProgress extends TransactionState {
  @override
  List<Object?> get props => [];
}

class TransactionOperationSuccess extends TransactionState {
  final String message;

  TransactionOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class TransactionError extends TransactionState {
  final String message;

  TransactionError(this.message);

  @override
  List<Object?> get props => [message];
}
