import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/analytics_repository.dart';
import 'analytics_event.dart';
import 'analytics_state.dart';

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
      final data = await _repository.getAnalytics(
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(AnalyticsLoaded(data));
    } catch (e) {
      emit(AnalyticsError(e.toString()));
    }
  }
}
