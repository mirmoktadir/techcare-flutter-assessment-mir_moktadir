import 'package:equatable/equatable.dart';

import '../../../domain/entities/analytics.dart';

abstract class AnalyticsState extends Equatable {}

class AnalyticsInitial extends AnalyticsState {
  @override
  List<Object?> get props => [];
}

class AnalyticsLoading extends AnalyticsState {
  @override
  List<Object?> get props => [];
}

class AnalyticsLoaded extends AnalyticsState {
  final AnalyticsData data;
  AnalyticsLoaded(this.data);
  @override
  List<Object?> get props => [data];
}

class AnalyticsError extends AnalyticsState {
  final String message;
  AnalyticsError(this.message);
  @override
  List<Object?> get props => [message];
}
