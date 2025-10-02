import '../entities/analytics.dart';

abstract class AnalyticsRepository {
  // Matches spec: GET /api/analytics?startDate={date}&endDate={date}
  Future<AnalyticsData> getAnalytics({DateTime? startDate, DateTime? endDate});
}
