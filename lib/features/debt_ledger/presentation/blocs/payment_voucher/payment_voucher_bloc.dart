import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baseet/features/debt_ledger/domain/usecases/add_payment_voucher_usecase.dart';
import 'package:baseet/features/debt_ledger/domain/usecases/get_customers_usecase.dart';
import 'package:baseet/features/debt_ledger/presentation/blocs/payment_voucher/payment_voucher_event.dart';
import 'package:baseet/features/debt_ledger/presentation/blocs/payment_voucher/payment_voucher_state.dart';

class PaymentVoucherBloc
    extends Bloc<PaymentVoucherEvent, PaymentVoucherState> {
  final AddPaymentVoucherUseCase addPaymentVoucherUseCase;
  final GetCustomersUseCase getCustomersUseCase;

  PaymentVoucherBloc({
    required this.addPaymentVoucherUseCase,
    required this.getCustomersUseCase,
  }) : super(const PaymentVoucherState()) {
    on<SelectVoucherCustomerEvent>(_onSelectCustomer);
    on<SetVoucherAmountEvent>(
        (event, emit) => emit(state.copyWith(amount: event.amount)));
    on<SubmitPaymentVoucherEvent>(_onSubmit);
  }

  Future<void> _onSelectCustomer(
    SelectVoucherCustomerEvent event,
    Emitter<PaymentVoucherState> emit,
  ) async {
    final result =
        await getCustomersUseCase(const GetCustomersParams(searchQuery: null));
    result.fold(
      (failure) => emit(state.copyWith(
          status: PaymentVoucherStatus.error, errorMessage: failure.message)),
      (customers) {
        final matches = customers.where((c) => c.id == event.customerId);
        if (matches.isEmpty) {
          emit(state.copyWith(
              status: PaymentVoucherStatus.error,
              errorMessage: 'validation.customer_missing'));
          return;
        }
        final cust = matches.first;
        emit(state.copyWith(selectedCustomer: cust));
      },
    );
  }

  Future<void> _onSubmit(
    SubmitPaymentVoucherEvent event,
    Emitter<PaymentVoucherState> emit,
  ) async {
    if (state.status == PaymentVoucherStatus.submitting ||
        state.status == PaymentVoucherStatus.success) {
      return;
    }

    emit(state.copyWith(status: PaymentVoucherStatus.submitting));

    final result = await addPaymentVoucherUseCase(AddPaymentVoucherParams(
      customerId: event.customerId,
      amount: event.amount,
      notes: event.notes,
      receiptPath: event.receiptPath,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: PaymentVoucherStatus.error,
        errorMessage: failure.message,
      )),
      (tx) => emit(state.copyWith(
        status: PaymentVoucherStatus.success,
        completedTransaction: tx,
      )),
    );
  }
}
