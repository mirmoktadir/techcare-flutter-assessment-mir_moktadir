import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/mock_api_service.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final MockApiService _service;

  CategoryRepositoryImpl(this._service); // ← MockApiService

  @override
  Future<List<Category>> getCategories() async {
    return _service.getCategories();
  }
}
