import 'package:equatable/equatable.dart';
import '../../../domain/entities/supplier_entity.dart';

abstract class AddSupplierEvent extends Equatable {
  const AddSupplierEvent();

  @override
  List<Object?> get props => [];
}

class SubmitAddSupplierEvent extends AddSupplierEvent {
  final SupplierEntity supplier;

  const SubmitAddSupplierEvent(this.supplier);

  @override
  List<Object?> get props => [supplier];
}
