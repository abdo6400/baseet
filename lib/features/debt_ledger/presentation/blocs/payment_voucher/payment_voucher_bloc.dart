import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baseet/core/extensions/translation_extension.dart';
import 'package:baseet/core/utils/strings_manager.dart';
import 'package:baseet/features/debt_ledger/domain/usecases/add_payment_voucher_usecase.dart';
import 'package:baseet/features/debt_ledger/domain/usecases/get_customers_usecase.dart';
import 'payment_voucher_event.dart';
import 'payment_voucher_state.dart';

class PaymentVoucherBloc extends Bloc<PaymentVoucherEvent, PaymentVoucherState> {
  final AddPaymentVoucherUseCase addPaymentVoucherUseCase;
  final GetCustomersUseCase getCustomersUseCase;

  PaymentVoucherBloc({
    required this.addPaymentVoucherUseCase,
    required this.getCustomersUseCase,
  }) : super(const PaymentVoucherState()) {
    on<SelectVoucherCustomerEvent>(_onSelectCustomer);
    on<SetVoucherAmountEvent>((event, emit) => emit(state.copyWith(amount: event.amount)));
    on<SubmitPaymentVoucherEvent>(_onSubmit);
  }

  Future<void> _onSelectCustomer(
    SelectVoucherCustomerEvent event,
    Emitter<PaymentVoucherState> emit,
  ) async {
    final result = await getCustomersUseCase(const GetCustomersParams(searchQuery: null));
    result.fold(
      (l) => null,
      (customers) {
        final cust = customers.firstWhere((c) => c.id == event.customerId);
        emit(state.copyWith(selectedCustomer: cust));
      },
    );
  }

  Future<void> _onSubmit(
    SubmitPaymentVoucherEvent event,
    Emitter<PaymentVoucherState> emit,
  ) async {
    if (event.amount <= 0) {
      emit(state.copyWith(
        status: PaymentVoucherStatus.error,
        errorMessage: StringsManager.voucherErrorInvalidAmount.lang,
      ));
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
