import 'package:equatable/equatable.dart';
import '../../../domain/entities/supplier_entity.dart';

enum AddSupplierStatus { initial, loading, success, error }

class AddSupplierState extends Equatable {
  final AddSupplierStatus status;
  final SupplierEntity? createdSupplier;
  final String? errorMessage;

  const AddSupplierState({
    this.status = AddSupplierStatus.initial,
    this.createdSupplier,
    this.errorMessage,
  });

  AddSupplierState copyWith({
    AddSupplierStatus? status,
    SupplierEntity? createdSupplier,
    String? errorMessage,
  }) {
    return AddSupplierState(
      status: status ?? this.status,
      createdSupplier: createdSupplier ?? this.createdSupplier,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, createdSupplier, errorMessage];
}
