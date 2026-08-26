import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baseet/features/reports/domain/usecases/get_report_summary_usecase.dart';
import 'reports_event.dart';
import 'reports_state.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final GetReportSummaryUseCase getReportSummaryUseCase;

  ReportsBloc({required this.getReportSummaryUseCase}) : super(const ReportsState()) {
    on<LoadReportsSummaryEvent>(_onLoadSummary);
  }

  Future<void> _onLoadSummary(LoadReportsSummaryEvent event, Emitter<ReportsState> emit) async {
    emit(state.copyWith(status: ReportsStatus.loading, period: event.period));

    final result = await getReportSummaryUseCase(GetReportSummaryParams(event.period));

    result.fold(
      (failure) => emit(state.copyWith(
        status: ReportsStatus.error,
        errorMessage: failure.message,
      )),
      (summary) => emit(state.copyWith(
        status: ReportsStatus.loaded,
        summary: summary,
      )),
    );
  }
}
