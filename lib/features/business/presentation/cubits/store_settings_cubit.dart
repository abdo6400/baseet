import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/business_usecases.dart';

class StoreSettingsState {
  final bool busy, saved;
  final String? error;
  const StoreSettingsState({this.busy = false, this.saved = false, this.error});
}

class StoreSettingsCubit extends Cubit<StoreSettingsState> {
  final SaveStoreUseCase saveStore;
  StoreSettingsCubit(this.saveStore) : super(const StoreSettingsState());
  Future<void> save(String name) async {
    if (state.busy) return;
    emit(const StoreSettingsState(busy: true));
    final result = await saveStore(StoreNameParams(name));
    if (!isClosed) {
      result.fold((f) => emit(StoreSettingsState(error: f.message)),
          (_) => emit(const StoreSettingsState(saved: true)));
    }
  }
}
