import 'package:equatable/equatable.dart';
import 'package:baseet/features/debt_ledger/domain/entities/customer_entity.dart';

enum AddCustomerStatus { initial, submitting, success, error }

class AddCustomerState extends Equatable {
  final AddCustomerStatus status;
  final CustomerEntity? createdCustomer;
  final String? errorMessage;

  const AddCustomerState({
    this.status = AddCustomerStatus.initial,
    this.createdCustomer,
    this.errorMessage,
  });

  AddCustomerState copyWith({
    AddCustomerStatus? status,
    CustomerEntity? createdCustomer,
    String? errorMessage,
  }) {
    return AddCustomerState(
      status: status ?? this.status,
      createdCustomer: createdCustomer ?? this.createdCustomer,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, createdCustomer, errorMessage];
}
