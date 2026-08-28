import 'package:equatable/equatable.dart';
import 'package:baseet/features/pos/domain/entities/order_entity.dart';
import 'pos_receipts_event.dart';

enum PosReceiptsStatus { initial, loading, success, error }

class PosReceiptsState extends Equatable {
  final PosReceiptsStatus status;
  final List<OrderEntity> orders;
  final String searchQuery;
  final ReceiptDateFilter dateFilter;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? errorMessage;
  final String? actionSuccessMessage;

  const PosReceiptsState({
    this.status = PosReceiptsStatus.initial,
    this.orders = const [],
    this.searchQuery = '',
    this.dateFilter = ReceiptDateFilter.all,
    this.startDate,
    this.endDate,
    this.errorMessage,
    this.actionSuccessMessage,
  });

  double get totalSales =>
      orders.fold(0.0, (sum, order) => sum + order.totalAmount);

  int get totalCount => orders.length;

  PosReceiptsState copyWith({
    PosReceiptsStatus? status,
    List<OrderEntity>? orders,
    String? searchQuery,
    ReceiptDateFilter? dateFilter,
    DateTime? startDate,
    DateTime? endDate,
    String? errorMessage,
    String? actionSuccessMessage,
  }) {
    return PosReceiptsState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      searchQuery: searchQuery ?? this.searchQuery,
      dateFilter: dateFilter ?? this.dateFilter,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      errorMessage: errorMessage,
      actionSuccessMessage: actionSuccessMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        orders,
        searchQuery,
        dateFilter,
        startDate,
        endDate,
        errorMessage,
        actionSuccessMessage,
      ];
}
