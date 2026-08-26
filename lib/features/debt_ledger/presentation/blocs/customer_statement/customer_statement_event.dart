import 'package:equatable/equatable.dart';

abstract class CustomerStatementEvent extends Equatable {
  const CustomerStatementEvent();

  @override
  List<Object?> get props => [];
}

class LoadCustomerStatementEvent extends CustomerStatementEvent {
  final String customerId;

  const LoadCustomerStatementEvent(this.customerId);

  @override
  List<Object?> get props => [customerId];
}
