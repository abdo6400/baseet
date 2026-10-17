import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baseet/features/catalog/domain/entities/product_entity.dart';
import 'package:baseet/features/inventory/domain/usecases/add_product_usecase.dart';
import '../../domain/usecases/business_usecases.dart';

class ProductEditorState {
  final bool busy, saved;
  final String? error;
  const ProductEditorState({this.busy = false, this.saved = false, this.error});
}

class ProductEditorCubit extends Cubit<ProductEditorState> {
  final AddProductUseCase add;
  final SaveProductUseCase update;
  ProductEditorCubit(this.add, this.update) : super(const ProductEditorState());
  Future<void> save(ProductEntity product, {required bool existing}) async {
    if (state.busy || state.saved) return;
    emit(const ProductEditorState(busy: true));
    final result = existing
        ? await update(SaveProductParams(product))
        : await add(AddProductParams(product));
    if (!isClosed) {
      result.fold((f) => emit(ProductEditorState(error: f.message)),
          (_) => emit(const ProductEditorState(saved: true)));
    }
  }
}
