import 'package:baseet/features/reports/domain/entities/report_period.dart';
import 'package:equatable/equatable.dart';

abstract class ReportsEvent extends Equatable {
  const ReportsEvent();

  @override
  List<Object?> get props => [];
}

class LoadReportsSummaryEvent extends ReportsEvent {
  final ReportPeriod period;

  const LoadReportsSummaryEvent({this.period = ReportPeriod.today});

  @override
  List<Object?> get props => [period];
}
