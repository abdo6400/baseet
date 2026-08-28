import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baseet/features/inventory/domain/usecases/add_product_usecase.dart';
import 'package:baseet/features/inventory/domain/usecases/delete_product_usecase.dart';
import 'package:baseet/features/inventory/domain/usecases/update_product_usecase.dart';
import 'add_product_event.dart';
import 'add_product_state.dart';

class AddProductBloc extends Bloc<AddProductEvent, AddProductState> {
  final AddProductUseCase addProductUseCase;
  final UpdateProductUseCase updateProductUseCase;
  final DeleteProductUseCase deleteProductUseCase;

  AddProductBloc({
    required this.addProductUseCase,
    required this.updateProductUseCase,
    required this.deleteProductUseCase,
  }) : super(const AddProductState()) {
    on<SubmitAddProductEvent>(_onSubmitAdd);
    on<SubmitUpdateProductEvent>(_onSubmitUpdate);
    on<SubmitDeleteProductEvent>(_onSubmitDelete);
  }

  Future<void> _onSubmitAdd(SubmitAddProductEvent event, Emitter<AddProductState> emit) async {
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

  Future<void> _onSubmitUpdate(SubmitUpdateProductEvent event, Emitter<AddProductState> emit) async {
    emit(state.copyWith(status: AddProductStatus.submitting));

    final result = await updateProductUseCase(event.product);

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

  Future<void> _onSubmitDelete(SubmitDeleteProductEvent event, Emitter<AddProductState> emit) async {
    emit(state.copyWith(status: AddProductStatus.submitting));

    final result = await deleteProductUseCase(event.productId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: AddProductStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        status: AddProductStatus.success,
      )),
    );
  }
}
