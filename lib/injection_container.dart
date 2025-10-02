import 'package:get_it/get_it.dart';

// Data source
import 'data/datasources/mock_api_service.dart';
import 'data/repositories/analytics_repository_impl.dart';
import 'data/repositories/category_repository_impl.dart';
// Repositories
import 'data/repositories/transaction_repository_impl.dart';
import 'domain/repositories/analytics_repository.dart';
import 'domain/repositories/category_repository.dart';
// Domain interfaces
import 'domain/repositories/transaction_repository.dart';
import 'features/analytics/bloc/analytics_bloc.dart';
import 'features/categories/bloc/category_bloc.dart'; // ← will create below
// BLoCs
import 'features/transactions/bloc/transaction_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // 🔹 Register MockApiService (NO Dio!)
  sl.registerLazySingleton<MockApiService>(() => MockApiService());

  // 🔹 Repositories depend on MockApiService
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(sl<MockApiService>()),
  );
  sl.registerLazySingleton<AnalyticsRepository>(
    () => AnalyticsRepositoryImpl(sl<MockApiService>()),
  );
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(sl<MockApiService>()),
  );

  // 🔹 BLoCs
  sl.registerFactory<TransactionBloc>(
    () => TransactionBloc(sl<TransactionRepository>()),
  );
  sl.registerFactory<AnalyticsBloc>(
    () => AnalyticsBloc(sl<AnalyticsRepository>()),
  );
  sl.registerFactory<CategoryBloc>(
    () => CategoryBloc(sl<CategoryRepository>()),
  );
}
