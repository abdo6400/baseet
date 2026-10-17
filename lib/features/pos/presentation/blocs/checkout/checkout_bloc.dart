import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baseet/features/pos/domain/usecases/process_checkout_usecase.dart';
import 'package:baseet/features/pos/presentation/blocs/checkout/checkout_event.dart';
import 'package:baseet/features/pos/presentation/blocs/checkout/checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final ProcessCheckoutUseCase processCheckoutUseCase;

  CheckoutBloc({required this.processCheckoutUseCase})
      : super(const CheckoutState()) {
    on<SetPaymentMethodEvent>((event, emit) {
      emit(state.copyWith(paymentMethod: event.method));
    });

    on<SelectCustomerForDebtEvent>((event, emit) {
      emit(state.copyWith(
        customerId: event.customerId,
        customerName: event.customerName,
      ));
    });

    on<SetPaidAmountEvent>((event, emit) {
      emit(state.copyWith(paidAmount: event.amount));
    });

    on<SubmitCheckoutEvent>(_onSubmitCheckout);
  }

  Future<void> _onSubmitCheckout(
      SubmitCheckoutEvent event, Emitter<CheckoutState> emit) async {
    if (state.status == CheckoutStatus.submitting ||
        state.status == CheckoutStatus.success) {
      return;
    }
    emit(state.copyWith(status: CheckoutStatus.submitting));
    final result = await processCheckoutUseCase(ProcessCheckoutParams(
        items: event.items,
        paymentMethod: state.paymentMethod,
        paidAmount: state.paidAmount,
        customerId: state.customerId,
        customerName: state.customerName,
        notes: event.notes,
        receiptPath: event.receiptPath));

    result.fold(
      (failure) => emit(state.copyWith(
        status: CheckoutStatus.error,
        errorMessage: failure.message,
      )),
      (completed) => emit(state.copyWith(
        status: CheckoutStatus.success,
        completedOrder: completed,
      )),
    );
  }
}
