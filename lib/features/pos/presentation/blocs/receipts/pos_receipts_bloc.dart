import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baseet/features/pos/domain/repositories/pos_repository.dart';
import 'pos_receipts_event.dart';
import 'pos_receipts_state.dart';

class PosReceiptsBloc extends Bloc<PosReceiptsEvent, PosReceiptsState> {
  final PosRepository repository;

  PosReceiptsBloc({required this.repository}) : super(const PosReceiptsState()) {
    on<LoadReceiptsEvent>(_onLoadReceipts);
    on<FilterReceiptsByDateEvent>(_onFilterByDate);
    on<SearchReceiptsEvent>(_onSearch);
    on<DeleteReceiptEvent>(_onDelete);
    on<UpdateReceiptEvent>(_onUpdate);
  }

  (DateTime?, DateTime?) _calculateDateRange(
    ReceiptDateFilter filter, {
    DateTime? customStart,
    DateTime? customEnd,
  }) {
    final now = DateTime.now();
    switch (filter) {
      case ReceiptDateFilter.all:
        return (null, null);
      case ReceiptDateFilter.today:
        final start = DateTime(now.year, now.month, now.day);
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        return (start, end);
      case ReceiptDateFilter.yesterday:
        final yest = now.subtract(const Duration(days: 1));
        final start = DateTime(yest.year, yest.month, yest.day);
        final end = DateTime(yest.year, yest.month, yest.day, 23, 59, 59);
        return (start, end);
      case ReceiptDateFilter.thisWeek:
        final start = now.subtract(Duration(days: now.weekday % 7));
        final startOfWeek = DateTime(start.year, start.month, start.day);
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        return (startOfWeek, end);
      case ReceiptDateFilter.thisMonth:
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        return (start, end);
      case ReceiptDateFilter.custom:
        return (customStart, customEnd);
    }
  }

  Future<void> _onLoadReceipts(
    LoadReceiptsEvent event,
    Emitter<PosReceiptsState> emit,
  ) async {
    emit(state.copyWith(status: PosReceiptsStatus.loading));

    final effectiveFilter = event.dateFilter ?? state.dateFilter;
    final (start, end) = _calculateDateRange(
      effectiveFilter,
      customStart: event.startDate ?? state.startDate,
      customEnd: event.endDate ?? state.endDate,
    );
    final effectiveQuery = event.searchQuery ?? state.searchQuery;

    final result = await repository.getOrders(
      searchQuery: effectiveQuery,
      startDate: start,
      endDate: end,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: PosReceiptsStatus.error,
        errorMessage: failure.message,
      )),
      (orders) => emit(state.copyWith(
        status: PosReceiptsStatus.success,
        orders: orders,
        searchQuery: effectiveQuery,
        dateFilter: effectiveFilter,
        startDate: start,
        endDate: end,
      )),
    );
  }

  Future<void> _onFilterByDate(
    FilterReceiptsByDateEvent event,
    Emitter<PosReceiptsState> emit,
  ) async {
    add(LoadReceiptsEvent(
      dateFilter: event.filter,
      startDate: event.customStartDate,
      endDate: event.customEndDate,
      searchQuery: state.searchQuery,
    ));
  }

  Future<void> _onSearch(
    SearchReceiptsEvent event,
    Emitter<PosReceiptsState> emit,
  ) async {
    add(LoadReceiptsEvent(
      searchQuery: event.query,
      dateFilter: state.dateFilter,
      startDate: state.startDate,
      endDate: state.endDate,
    ));
  }

  Future<void> _onDelete(
    DeleteReceiptEvent event,
    Emitter<PosReceiptsState> emit,
  ) async {
    emit(state.copyWith(status: PosReceiptsStatus.loading));

    final result = await repository.deleteOrder(event.orderId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: PosReceiptsStatus.error,
        errorMessage: failure.message,
      )),
      (_) {
        add(LoadReceiptsEvent(
          searchQuery: state.searchQuery,
          dateFilter: state.dateFilter,
          startDate: state.startDate,
          endDate: state.endDate,
        ));
      },
    );
  }

  Future<void> _onUpdate(
    UpdateReceiptEvent event,
    Emitter<PosReceiptsState> emit,
  ) async {
    emit(state.copyWith(status: PosReceiptsStatus.loading));

    final result = await repository.updateOrder(event.order);

    result.fold(
      (failure) => emit(state.copyWith(
        status: PosReceiptsStatus.error,
        errorMessage: failure.message,
      )),
      (_) {
        add(LoadReceiptsEvent(
          searchQuery: state.searchQuery,
          dateFilter: state.dateFilter,
          startDate: state.startDate,
          endDate: state.endDate,
        ));
      },
    );
  }
}
