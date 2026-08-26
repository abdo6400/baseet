import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baseet/core/enums/enums.dart';
import 'package:baseet/core/extensions/translation_extension.dart';
import 'package:baseet/core/utils/strings_manager.dart';
import 'package:baseet/core/utils/uuid_generator.dart';
import 'package:baseet/features/pos/domain/entities/order_entity.dart';
import 'package:baseet/features/pos/domain/usecases/process_checkout_usecase.dart';
import 'checkout_event.dart';
import 'checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final ProcessCheckoutUseCase processCheckoutUseCase;

  CheckoutBloc({required this.processCheckoutUseCase}) : super(const CheckoutState()) {
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

  Future<void> _onSubmitCheckout(SubmitCheckoutEvent event, Emitter<CheckoutState> emit) async {
    if (state.paymentMethod == PaymentMethod.debt && state.customerId == null) {
      emit(state.copyWith(
        status: CheckoutStatus.error,
        errorMessage: StringsManager.checkoutErrorSelectCustomer.lang,
      ));
      return;
    }

    emit(state.copyWith(status: CheckoutStatus.submitting));

    final invoiceNumber = UuidGenerator.generate('INV');
    final double remaining = state.paymentMethod == PaymentMethod.debt
        ? (event.totalAmount - state.paidAmount).clamp(0.0, event.totalAmount)
        : 0.0;

    final order = OrderEntity(
      id: invoiceNumber,
      invoiceNumber: invoiceNumber,
      items: event.items,
      totalAmount: event.totalAmount,
      paidAmount: state.paymentMethod == PaymentMethod.debt ? state.paidAmount : event.totalAmount,
      remainingAmount: remaining,
      paymentMethod: state.paymentMethod,
      customerId: state.customerId,
      customerName: state.customerName,
      createdAt: DateTime.now(),
      notes: event.notes,
      receiptPath: event.receiptPath,
    );

    final result = await processCheckoutUseCase(ProcessCheckoutParams(order));

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
