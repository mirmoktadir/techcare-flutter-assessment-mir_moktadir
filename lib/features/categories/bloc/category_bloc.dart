import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/category_repository.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository _repository;

  CategoryBloc(this._repository) : super(CategoryInitial()) {
    on<LoadCategories>((event, emit) async {
      emit(CategoryLoading());
      try {
        final categories = await _repository.getCategories();
        emit(CategoryLoaded(categories));
      } catch (e) {
        emit(CategoryError(e.toString()));
      }
    });
  }
}
