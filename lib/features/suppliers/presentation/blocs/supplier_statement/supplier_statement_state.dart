import 'package:equatable/equatable.dart';
import '../../../domain/entities/supplier_invoice_entity.dart';

enum SupplierStatementStatus { initial, loading, loaded, error }

class SupplierStatementState extends Equatable {
  final SupplierStatementStatus status;
  final List<SupplierInvoiceEntity> invoices;
  final String? errorMessage;

  const SupplierStatementState({
    this.status = SupplierStatementStatus.initial,
    this.invoices = const [],
    this.errorMessage,
  });

  SupplierStatementState copyWith({
    SupplierStatementStatus? status,
    List<SupplierInvoiceEntity>? invoices,
    String? errorMessage,
  }) {
    return SupplierStatementState(
      status: status ?? this.status,
      invoices: invoices ?? this.invoices,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, invoices, errorMessage];
}
