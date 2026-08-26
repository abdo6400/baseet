import 'package:equatable/equatable.dart';
import '../../../domain/entities/supplier_invoice_entity.dart';

abstract class SupplierStatementEvent extends Equatable {
  const SupplierStatementEvent();

  @override
  List<Object?> get props => [];
}

class LoadSupplierStatementEvent extends SupplierStatementEvent {
  final String supplierId;

  const LoadSupplierStatementEvent(this.supplierId);

  @override
  List<Object?> get props => [supplierId];
}

class AddInvoiceToStatementEvent extends SupplierStatementEvent {
  final SupplierInvoiceEntity invoice;

  const AddInvoiceToStatementEvent(this.invoice);

  @override
  List<Object?> get props => [invoice];
}
