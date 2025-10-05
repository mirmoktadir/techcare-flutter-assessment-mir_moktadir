import '../../domain/entities/analytics.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../datasources/mock_api_service.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final MockApiService _service;

  AnalyticsRepositoryImpl(this._service);

  @override
  Future<AnalyticsData> getAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return _service.getAnalytics(startDate: startDate, endDate: endDate);
  }
}
