import 'package:equatable/equatable.dart';

import '../../../domain/entities/category.dart';

abstract class CategoryState extends Equatable {}

class CategoryInitial extends CategoryState {
  @override
  List<Object?> get props => [];
}

class CategoryLoading extends CategoryState {
  @override
  List<Object?> get props => [];
}

class CategoryLoaded extends CategoryState {
  final List<Category> categories;
  CategoryLoaded(this.categories);
  @override
  List<Object?> get props => [categories];
}

class CategoryError extends CategoryState {
  final String message;
  CategoryError(this.message);
  @override
  List<Object?> get props => [message];
}
