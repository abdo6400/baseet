import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baseet/features/debt_ledger/domain/usecases/get_customer_statement_usecase.dart';
import 'customer_statement_event.dart';
import 'customer_statement_state.dart';

class CustomerStatementBloc extends Bloc<CustomerStatementEvent, CustomerStatementState> {
  final GetCustomerStatementUseCase getCustomerStatementUseCase;

  CustomerStatementBloc({required this.getCustomerStatementUseCase})
      : super(const CustomerStatementState()) {
    on<LoadCustomerStatementEvent>(_onLoadStatement);
  }

  Future<void> _onLoadStatement(
    LoadCustomerStatementEvent event,
    Emitter<CustomerStatementState> emit,
  ) async {
    emit(state.copyWith(status: CustomerStatementStatus.loading));

    final result = await getCustomerStatementUseCase(GetCustomerStatementParams(event.customerId));

    result.fold(
      (failure) => emit(state.copyWith(
        status: CustomerStatementStatus.error,
        errorMessage: failure.message,
      )),
      (data) => emit(state.copyWith(
        status: CustomerStatementStatus.loaded,
        customer: data.customer,
        transactions: data.transactions,
      )),
    );
  }
}
