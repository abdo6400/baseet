import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_suppliers_usecase.dart';
import '../../../domain/usecases/get_total_supplier_debt_usecase.dart';
import 'suppliers_event.dart';
import 'suppliers_state.dart';

class SuppliersBloc extends Bloc<SuppliersEvent, SuppliersState> {
  final GetSuppliersUseCase getSuppliersUseCase;
  final GetTotalSupplierDebtUseCase getTotalSupplierDebtUseCase;

  SuppliersBloc({
    required this.getSuppliersUseCase,
    required this.getTotalSupplierDebtUseCase,
  }) : super(const SuppliersState()) {
    on<LoadSuppliersEvent>(_onLoadSuppliers);
    on<SearchSuppliersEvent>(_onSearchSuppliers);
  }

  Future<void> _onLoadSuppliers(
    LoadSuppliersEvent event,
    Emitter<SuppliersState> emit,
  ) async {
    emit(state.copyWith(status: SuppliersStatus.loading));

    final totalDebtResult = await getTotalSupplierDebtUseCase();
    final totalDebt = totalDebtResult.fold((l) => 0.0, (r) => r);

    final suppliersResult = await getSuppliersUseCase(GetSuppliersParams(
      searchQuery: event.searchQuery ?? state.searchQuery,
    ));

    suppliersResult.fold(
      (failure) => emit(state.copyWith(
        status: SuppliersStatus.error,
        errorMessage: failure.message,
      )),
      (suppliers) => emit(state.copyWith(
        status: SuppliersStatus.loaded,
        suppliers: suppliers,
        totalDebt: totalDebt,
      )),
    );
  }

  Future<void> _onSearchSuppliers(
    SearchSuppliersEvent event,
    Emitter<SuppliersState> emit,
  ) async {
    emit(state.copyWith(searchQuery: event.query));
    add(LoadSuppliersEvent(searchQuery: event.query));
  }
}
