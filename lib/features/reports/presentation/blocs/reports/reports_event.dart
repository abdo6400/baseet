import 'package:equatable/equatable.dart';

abstract class ReportsEvent extends Equatable {
  const ReportsEvent();

  @override
  List<Object?> get props => [];
}

class LoadReportsSummaryEvent extends ReportsEvent {
  final String period;

  const LoadReportsSummaryEvent({this.period = 'today'});

  @override
  List<Object?> get props => [period];
}
