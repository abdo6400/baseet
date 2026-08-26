import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../config/database/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/report_summary_entity.dart';
import '../repositories/reports_repository.dart';

class GetReportSummaryParams extends Equatable {
  final String period;

  const GetReportSummaryParams(this.period);

  @override
  List<Object?> get props => [period];
}

class GetReportSummaryUseCase extends ParamsUseCase<ReportSummaryEntity, GetReportSummaryParams> {
  final ReportsRepository repository;

  GetReportSummaryUseCase(this.repository);

  @override
  Future<Either<Failure, ReportSummaryEntity>> call(GetReportSummaryParams params) {
    return repository.getReportSummary(params.period);
  }
}
