import 'package:flutter/material.dart'; // 👈 provides DateTimeRange
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/analytics_repository.dart';
import '../bloc/analytics_event.dart';
import '../bloc/analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final AnalyticsRepository _repository;

  AnalyticsBloc(this._repository) : super(AnalyticsInitial()) {
    on<LoadAnalytics>(_onLoadAnalytics);
  }

  Future<void> _onLoadAnalytics(
    LoadAnalytics event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoading());

    try {
      // 🔹 Convert period to actual date range
      final range = _getDateRangeFromPeriod(event.period, event.customRange);

      // 🔹 Fetch data (your repository uses startDate/endDate)
      final data = await _repository.getAnalytics(
        startDate: range.start,
        endDate: range.end,
      );

      emit(AnalyticsLoaded(data));
    } catch (e) {
      emit(AnalyticsError('Failed to load analytics: $e'));
    }
  }

  DateTimeRange _getDateRangeFromPeriod(
    String period,
    DateTimeRange? customRange,
  ) {
    final now = DateTime.now();
    switch (period) {
      case 'today':
        return DateTimeRange(start: now, end: now);
      case 'week':
        final start = now.subtract(Duration(days: now.weekday - 1));
        return DateTimeRange(start: start, end: now);
      case '3months':
        final start = DateTime(now.year, now.month - 2, 1);
        return DateTimeRange(start: start, end: now);
      case 'custom':
        return customRange ??
            DateTimeRange(
              start: now.subtract(const Duration(days: 30)),
              end: now,
            );
      default: // 'month'
        return DateTimeRange(start: DateTime(now.year, now.month, 1), end: now);
    }
  }
}
