import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/transaction.dart';
import '../../../domain/repositories/transaction_repository.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository _repository;

  TransactionBloc(this._repository) : super(TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<AddTransaction>(_onAddTransaction);
    on<UpdateTransaction>(_onUpdateTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
    on<TransactionOperationComplete>(_onOperationComplete);
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(
      TransactionLoading(
        transactions: state is TransactionLoaded
            ? (state as TransactionLoaded).transactions
            : null,
      ),
    );

    try {
      final newTransactions = await _repository.getTransactions(
        page: event.page,
        type: event.filters['type'],
        limit: event.limit,
        category: event.filters['category'],
        searchQuery: event.searchQuery,
      );

      if (event.page == 1) {
        final hasMore = newTransactions.length == event.limit;
        emit(TransactionLoaded(newTransactions, hasMore));
      } else {
        if (state is TransactionLoaded) {
          final currentState = state as TransactionLoaded;
          final updatedList = List<Transaction>.from(currentState.transactions)
            ..addAll(newTransactions);
          emit(
            currentState.copyWith(
              transactions: updatedList,
              hasMore: newTransactions.length == 20,
            ),
          );
        } else {
          emit(
            TransactionLoaded(
              newTransactions,
              newTransactions.length == event.limit,
            ),
          );
        }
      }
    } catch (e) {
      emit(TransactionError('Failed to load transactions: $e'));
    }
  }

  Future<void> _onAddTransaction(
    AddTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionOperationInProgress());
    try {
      // 1. Save to repo
      await _repository.addTransaction(event.transaction);

      // 2. RELOAD page 1 (this triggers _onLoadTransactions)
      add(LoadTransactions(1, {}));

      emit(TransactionOperationSuccess('Transaction added!'));
    } catch (e) {
      emit(TransactionError('Failed to add: $e'));
    }
  }

  Future<void> _onUpdateTransaction(
    UpdateTransaction event,
    Emitter emit,
  ) async {
    emit(TransactionOperationInProgress());
    try {
      await _repository.updateTransaction(event.id, event.transaction);
      add(LoadTransactions(1, {}));
      emit(TransactionOperationSuccess('Updated!'));
    } catch (e) {
      emit(TransactionError('Update failed: $e'));
    }
  }

  Future<void> _onDeleteTransaction(
    DeleteTransaction event,
    Emitter emit,
  ) async {
    emit(TransactionOperationInProgress());
    try {
      await _repository.deleteTransaction(event.id);
      add(LoadTransactions(1, {}));
      emit(TransactionOperationSuccess('Deleted!'));
    } catch (e) {
      emit(TransactionError('Delete failed: $e'));
    }
  }

  void _onOperationComplete(
    TransactionOperationComplete event,
    Emitter<TransactionState> emit,
  ) {
    // Reset to initial or loaded state after showing success
    if (state is TransactionLoaded) {
      emit(state);
    } else {
      emit(TransactionInitial());
    }
  }
}
