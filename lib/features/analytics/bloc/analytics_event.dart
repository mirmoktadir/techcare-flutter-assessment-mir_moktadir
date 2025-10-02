import 'package:equatable/equatable.dart';

abstract class AnalyticsEvent extends Equatable {}

class LoadAnalytics extends AnalyticsEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  LoadAnalytics({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}
