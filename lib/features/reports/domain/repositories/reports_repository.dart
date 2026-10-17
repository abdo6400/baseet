import 'package:baseet/features/reports/domain/entities/report_period.dart';
import 'package:dartz/dartz.dart';
import 'package:baseet/core/error/failures.dart';
import 'package:baseet/features/reports/domain/entities/report_summary_entity.dart';

abstract class ReportsRepository {
  Future<Either<Failure, ReportSummaryEntity>> getReportSummary(
      ReportPeriod period);
}
