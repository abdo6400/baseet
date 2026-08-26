import 'package:dartz/dartz.dart';
import '../../../../config/database/error/failures.dart';
import '../entities/report_summary_entity.dart';

abstract class ReportsRepository {
  Future<Either<Failure, ReportSummaryEntity>> getReportSummary(String period);
}
