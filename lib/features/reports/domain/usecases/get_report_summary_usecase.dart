import 'package:baseet/features/reports/domain/entities/report_period.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:baseet/core/error/failures.dart';
import 'package:baseet/core/usecase/usecase.dart';
import 'package:baseet/features/reports/domain/entities/report_summary_entity.dart';
import 'package:baseet/features/reports/domain/repositories/reports_repository.dart';

class GetReportSummaryParams extends Equatable {
  final ReportPeriod period;

  const GetReportSummaryParams(this.period);

  @override
  List<Object?> get props => [period];
}

class GetReportSummaryUseCase
    extends ParamsUseCase<ReportSummaryEntity, GetReportSummaryParams> {
  final ReportsRepository repository;

  GetReportSummaryUseCase(this.repository);

  @override
  Future<Either<Failure, ReportSummaryEntity>> call(
      GetReportSummaryParams params) {
    return repository.getReportSummary(params.period);
  }
}
