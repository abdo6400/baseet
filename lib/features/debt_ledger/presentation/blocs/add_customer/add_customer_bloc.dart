import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baseet/features/debt_ledger/domain/usecases/add_customer_usecase.dart';
import 'add_customer_event.dart';
import 'add_customer_state.dart';

class AddCustomerBloc extends Bloc<AddCustomerEvent, AddCustomerState> {
  final AddCustomerUseCase addCustomerUseCase;

  AddCustomerBloc({required this.addCustomerUseCase}) : super(const AddCustomerState()) {
    on<SubmitAddCustomerEvent>(_onSubmit);
  }

  Future<void> _onSubmit(SubmitAddCustomerEvent event, Emitter<AddCustomerState> emit) async {
    emit(state.copyWith(status: AddCustomerStatus.submitting));

    final result = await addCustomerUseCase(AddCustomerParams(event.customer));

    result.fold(
      (failure) => emit(state.copyWith(
        status: AddCustomerStatus.error,
        errorMessage: failure.message,
      )),
      (customer) => emit(state.copyWith(
        status: AddCustomerStatus.success,
        createdCustomer: customer,
      )),
    );
  }
}
