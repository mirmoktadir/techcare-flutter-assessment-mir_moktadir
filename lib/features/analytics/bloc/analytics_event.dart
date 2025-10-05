import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class AnalyticsEvent extends Equatable {}

class LoadAnalytics extends AnalyticsEvent {
  final String period; // 'week', 'month', '3months', 'custom'
  final DateTimeRange? customRange;

  LoadAnalytics({this.period = 'month', this.customRange});

  @override
  List<Object?> get props => [period, customRange];
}
