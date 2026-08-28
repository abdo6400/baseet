import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baseet/features/inventory/domain/usecases/add_category_usecase.dart';
import 'package:baseet/features/inventory/domain/usecases/delete_category_usecase.dart';
import 'add_category_event.dart';
import 'add_category_state.dart';

class AddCategoryBloc extends Bloc<AddCategoryEvent, AddCategoryState> {
  final AddCategoryUseCase addCategoryUseCase;
  final DeleteCategoryUseCase deleteCategoryUseCase;

  AddCategoryBloc({
    required this.addCategoryUseCase,
    required this.deleteCategoryUseCase,
  }) : super(const AddCategoryState()) {
    on<SubmitAddCategoryEvent>(_onSubmit);
    on<DeleteCategoryEvent>(_onDelete);
  }

  Future<void> _onSubmit(SubmitAddCategoryEvent event, Emitter<AddCategoryState> emit) async {
    emit(state.copyWith(status: AddCategoryStatus.submitting));

    final result = await addCategoryUseCase(AddCategoryParams(event.category));

    result.fold(
      (failure) => emit(state.copyWith(
        status: AddCategoryStatus.error,
        errorMessage: failure.message,
      )),
      (cat) => emit(state.copyWith(
        status: AddCategoryStatus.success,
        createdCategory: cat,
      )),
    );
  }

  Future<void> _onDelete(DeleteCategoryEvent event, Emitter<AddCategoryState> emit) async {
    emit(state.copyWith(status: AddCategoryStatus.submitting));

    final result = await deleteCategoryUseCase(DeleteCategoryParams(event.id));

    result.fold(
      (failure) => emit(state.copyWith(
        status: AddCategoryStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        status: AddCategoryStatus.success,
      )),
    );
  }
}
