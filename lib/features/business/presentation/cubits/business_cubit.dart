import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/business_data.dart';
import '../../domain/usecases/business_usecases.dart';

class BusinessState {
  final BusinessData data;
  final bool loading;
  final String? error;
  const BusinessState(
      {this.data = const BusinessData(), this.loading = false, this.error});
}

class BusinessCubit extends Cubit<BusinessState> {
  final LoadBusinessUseCase loadBusiness;
  BusinessCubit(this.loadBusiness) : super(const BusinessState());
  Future<void> load() async {
    if (state.loading) return;
    emit(BusinessState(data: state.data, loading: true));
    final result = await loadBusiness();
    if (isClosed) return;
    result.fold(
        (failure) =>
            emit(BusinessState(data: state.data, error: failure.message)),
        (data) => emit(BusinessState(data: data)));
  }
}
