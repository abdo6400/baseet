import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baseet/features/catalog/domain/entities/category_entity.dart';
import 'package:baseet/features/catalog/domain/usecases/get_categories_usecase.dart';
import 'package:baseet/features/debt_ledger/domain/entities/customer_entity.dart';
import 'package:baseet/features/debt_ledger/domain/usecases/get_customers_usecase.dart';

class ProcessLookupsState extends Equatable {
  final List<CategoryEntity> categories;
  final List<CustomerEntity> customers;
  final bool loading;
  final String? error;
  const ProcessLookupsState(
      {this.categories = const [],
      this.customers = const [],
      this.loading = false,
      this.error});
  @override
  List<Object?> get props => [categories, customers, loading, error];
}

class ProcessLookupsCubit extends Cubit<ProcessLookupsState> {
  final GetCategoriesUseCase getCategories;
  final GetCustomersUseCase getCustomers;
  ProcessLookupsCubit(this.getCategories, this.getCustomers)
      : super(const ProcessLookupsState());
  Future<void> load({bool categories = false, bool customers = false}) async {
    emit(const ProcessLookupsState(loading: true));
    var cats = <CategoryEntity>[];
    var people = <CustomerEntity>[];
    String? error;
    if (categories) {
      (await getCategories())
          .fold((failure) => error = failure.message, (value) => cats = value);
    }
    if (customers) {
      (await getCustomers(const GetCustomersParams())).fold(
          (failure) => error = failure.message, (value) => people = value);
    }
    if (!isClosed) {
      emit(ProcessLookupsState(
          categories: cats, customers: people, error: error));
    }
  }
}
