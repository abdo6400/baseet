import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/add_supplier_usecase.dart';
import 'add_supplier_event.dart';
import 'add_supplier_state.dart';

class AddSupplierBloc extends Bloc<AddSupplierEvent, AddSupplierState> {
  final AddSupplierUseCase addSupplierUseCase;

  AddSupplierBloc({required this.addSupplierUseCase}) : super(const AddSupplierState()) {
    on<SubmitAddSupplierEvent>(_onSubmitAddSupplier);
  }

  Future<void> _onSubmitAddSupplier(
    SubmitAddSupplierEvent event,
    Emitter<AddSupplierState> emit,
  ) async {
    emit(state.copyWith(status: AddSupplierStatus.loading));

    final result = await addSupplierUseCase(event.supplier);

    result.fold(
      (failure) => emit(state.copyWith(
        status: AddSupplierStatus.error,
        errorMessage: failure.message,
      )),
      (supplier) => emit(state.copyWith(
        status: AddSupplierStatus.success,
        createdSupplier: supplier,
      )),
    );
  }
}
