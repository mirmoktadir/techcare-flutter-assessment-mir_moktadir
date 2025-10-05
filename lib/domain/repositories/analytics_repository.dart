import '../entities/analytics.dart';

abstract class AnalyticsRepository {
  Future<AnalyticsData> getAnalytics({DateTime? startDate, DateTime? endDate});
}
