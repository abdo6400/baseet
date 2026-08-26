import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baseet/features/inventory/domain/usecases/add_product_usecase.dart';
import 'add_product_event.dart';
import 'add_product_state.dart';

class AddProductBloc extends Bloc<AddProductEvent, AddProductState> {
  final AddProductUseCase addProductUseCase;

  AddProductBloc({required this.addProductUseCase}) : super(const AddProductState()) {
    on<SubmitAddProductEvent>(_onSubmit);
  }

  Future<void> _onSubmit(SubmitAddProductEvent event, Emitter<AddProductState> emit) async {
    emit(state.copyWith(status: AddProductStatus.submitting));

    final result = await addProductUseCase(AddProductParams(event.product));

    result.fold(
      (failure) => emit(state.copyWith(
        status: AddProductStatus.error,
        errorMessage: failure.message,
      )),
      (product) => emit(state.copyWith(
        status: AddProductStatus.success,
        createdProduct: product,
      )),
    );
  }
}
