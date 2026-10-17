import 'package:baseet/features/reports/domain/entities/report_period.dart';
import 'package:equatable/equatable.dart';
import 'package:baseet/features/reports/domain/entities/report_summary_entity.dart';

enum ReportsStatus { initial, loading, loaded, error }

class ReportsState extends Equatable {
  final ReportsStatus status;
  final ReportPeriod period;
  final ReportSummaryEntity? summary;
  final String? errorMessage;

  const ReportsState({
    this.status = ReportsStatus.initial,
    this.period = ReportPeriod.today,
    this.summary,
    this.errorMessage,
  });

  ReportsState copyWith({
    ReportsStatus? status,
    ReportPeriod? period,
    ReportSummaryEntity? summary,
    String? errorMessage,
  }) {
    return ReportsState(
      status: status ?? this.status,
      period: period ?? this.period,
      summary: summary ?? this.summary,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, period, summary, errorMessage];
}
