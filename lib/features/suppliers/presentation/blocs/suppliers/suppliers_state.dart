import 'package:equatable/equatable.dart';
import '../../../domain/entities/supplier_entity.dart';

enum SuppliersStatus { initial, loading, loaded, error }

class SuppliersState extends Equatable {
  final SuppliersStatus status;
  final List<SupplierEntity> suppliers;
  final double totalDebt;
  final String searchQuery;
  final String? errorMessage;

  const SuppliersState({
    this.status = SuppliersStatus.initial,
    this.suppliers = const [],
    this.totalDebt = 0.0,
    this.searchQuery = '',
    this.errorMessage,
  });

  SuppliersState copyWith({
    SuppliersStatus? status,
    List<SupplierEntity>? suppliers,
    double? totalDebt,
    String? searchQuery,
    String? errorMessage,
  }) {
    return SuppliersState(
      status: status ?? this.status,
      suppliers: suppliers ?? this.suppliers,
      totalDebt: totalDebt ?? this.totalDebt,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, suppliers, totalDebt, searchQuery, errorMessage];
}
