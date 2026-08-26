import 'package:equatable/equatable.dart';
import 'package:baseet/features/inventory/domain/entities/category_entity.dart';

enum AddCategoryStatus { initial, submitting, success, error }

class AddCategoryState extends Equatable {
  final AddCategoryStatus status;
  final CategoryEntity? createdCategory;
  final String? errorMessage;

  const AddCategoryState({
    this.status = AddCategoryStatus.initial,
    this.createdCategory,
    this.errorMessage,
  });

  AddCategoryState copyWith({
    AddCategoryStatus? status,
    CategoryEntity? createdCategory,
    String? errorMessage,
  }) {
    return AddCategoryState(
      status: status ?? this.status,
      createdCategory: createdCategory ?? this.createdCategory,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, createdCategory, errorMessage];
}
