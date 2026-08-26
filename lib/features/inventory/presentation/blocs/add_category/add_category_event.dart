import 'package:equatable/equatable.dart';
import 'package:baseet/features/inventory/domain/entities/category_entity.dart';

abstract class AddCategoryEvent extends Equatable {
  const AddCategoryEvent();

  @override
  List<Object?> get props => [];
}

class SubmitAddCategoryEvent extends AddCategoryEvent {
  final CategoryEntity category;

  const SubmitAddCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}
