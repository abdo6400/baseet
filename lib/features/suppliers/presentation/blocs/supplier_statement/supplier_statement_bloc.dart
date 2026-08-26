import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/add_supplier_invoice_usecase.dart';
import '../../../domain/usecases/get_supplier_invoices_usecase.dart';
import 'supplier_statement_event.dart';
import 'supplier_statement_state.dart';

class SupplierStatementBloc extends Bloc<SupplierStatementEvent, SupplierStatementState> {
  final GetSupplierInvoicesUseCase getSupplierInvoicesUseCase;
  final AddSupplierInvoiceUseCase addSupplierInvoiceUseCase;

  SupplierStatementBloc({
    required this.getSupplierInvoicesUseCase,
    required this.addSupplierInvoiceUseCase,
  }) : super(const SupplierStatementState()) {
    on<LoadSupplierStatementEvent>(_onLoadStatement);
    on<AddInvoiceToStatementEvent>(_onAddInvoice);
  }

  Future<void> _onLoadStatement(
    LoadSupplierStatementEvent event,
    Emitter<SupplierStatementState> emit,
  ) async {
    emit(state.copyWith(status: SupplierStatementStatus.loading));

    final result = await getSupplierInvoicesUseCase(event.supplierId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: SupplierStatementStatus.error,
        errorMessage: failure.message,
      )),
      (invoices) => emit(state.copyWith(
        status: SupplierStatementStatus.loaded,
        invoices: invoices,
      )),
    );
  }

  Future<void> _onAddInvoice(
    AddInvoiceToStatementEvent event,
    Emitter<SupplierStatementState> emit,
  ) async {
    emit(state.copyWith(status: SupplierStatementStatus.loading));

    final result = await addSupplierInvoiceUseCase(event.invoice);

    result.fold(
      (failure) => emit(state.copyWith(
        status: SupplierStatementStatus.error,
        errorMessage: failure.message,
      )),
      (invoice) {
        final updatedList = [invoice, ...state.invoices];
        emit(state.copyWith(
          status: SupplierStatementStatus.loaded,
          invoices: updatedList,
        ));
      },
    );
  }
}
