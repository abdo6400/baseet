import 'package:equatable/equatable.dart';
import 'package:baseet/features/debt_ledger/domain/entities/customer_entity.dart';

abstract class AddCustomerEvent extends Equatable {
  const AddCustomerEvent();

  @override
  List<Object?> get props => [];
}

class SubmitAddCustomerEvent extends AddCustomerEvent {
  final CustomerEntity customer;

  const SubmitAddCustomerEvent(this.customer);

  @override
  List<Object?> get props => [customer];
}
