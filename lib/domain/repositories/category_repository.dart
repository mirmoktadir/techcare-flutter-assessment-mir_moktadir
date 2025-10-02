import '../entities/category.dart';

// Must be 'abstract class', not mixin
abstract class CategoryRepository {
  Future<List<Category>> getCategories();
}
