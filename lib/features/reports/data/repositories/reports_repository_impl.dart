import 'package:dartz/dartz.dart';
import '../../../../config/database/error/failures.dart';
import '../../domain/entities/report_summary_entity.dart';
import '../../domain/repositories/reports_repository.dart';
import '../datasources/reports_local_datasource.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsLocalDataSource localDataSource;

  ReportsRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, ReportSummaryEntity>> getReportSummary(String period) {
    return Failure.handleCall(() => localDataSource.getReportSummary(period));
  }
}
