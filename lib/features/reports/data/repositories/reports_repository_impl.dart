import 'package:baseet/features/reports/domain/entities/report_period.dart';
import 'package:baseet/core/error/repository_call.dart';
import 'package:dartz/dartz.dart';
import 'package:baseet/core/error/failures.dart';
import 'package:baseet/features/reports/domain/entities/report_summary_entity.dart';
import 'package:baseet/features/reports/domain/repositories/reports_repository.dart';
import 'package:baseet/features/reports/data/datasources/reports_local_datasource.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsLocalDataSource localDataSource;

  ReportsRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, ReportSummaryEntity>> getReportSummary(
      ReportPeriod period) {
    return repositoryCall(() => localDataSource.getReportSummary(period));
  }
}
