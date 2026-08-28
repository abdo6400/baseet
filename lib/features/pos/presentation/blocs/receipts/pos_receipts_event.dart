import 'package:equatable/equatable.dart';
import 'package:baseet/features/pos/domain/entities/order_entity.dart';

enum ReceiptDateFilter {
  all,
  today,
  yesterday,
  thisWeek,
  thisMonth,
  custom,
}

abstract class PosReceiptsEvent extends Equatable {
  const PosReceiptsEvent();

  @override
  List<Object?> get props => [];
}

class LoadReceiptsEvent extends PosReceiptsEvent {
  final String? searchQuery;
  final ReceiptDateFilter? dateFilter;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadReceiptsEvent({
    this.searchQuery,
    this.dateFilter,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [searchQuery, dateFilter, startDate, endDate];
}

class FilterReceiptsByDateEvent extends PosReceiptsEvent {
  final ReceiptDateFilter filter;
  final DateTime? customStartDate;
  final DateTime? customEndDate;

  const FilterReceiptsByDateEvent({
    required this.filter,
    this.customStartDate,
    this.customEndDate,
  });

  @override
  List<Object?> get props => [filter, customStartDate, customEndDate];
}

class SearchReceiptsEvent extends PosReceiptsEvent {
  final String query;

  const SearchReceiptsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class DeleteReceiptEvent extends PosReceiptsEvent {
  final String orderId;

  const DeleteReceiptEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class UpdateReceiptEvent extends PosReceiptsEvent {
  final OrderEntity order;

  const UpdateReceiptEvent(this.order);

  @override
  List<Object?> get props => [order];
}
