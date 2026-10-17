import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baseet/features/more_settings/domain/usecases/clear_data_usecase.dart';
import 'package:baseet/features/more_settings/domain/usecases/restore_demo_data_usecase.dart';

enum DataAction { clear, restoreDemo }

enum DataManagementStatus { initial, loading, success, error }

class DataManagementEvent extends Equatable {
  final DataAction action;
  const DataManagementEvent(this.action);
  @override
  List<Object?> get props => [action];
}

class DataManagementState extends Equatable {
  final DataManagementStatus status;
  final DataAction? action;
  final String? error;
  const DataManagementState(
      {this.status = DataManagementStatus.initial, this.action, this.error});
  @override
  List<Object?> get props => [status, action, error];
}

class DataManagementBloc
    extends Bloc<DataManagementEvent, DataManagementState> {
  final ClearDataUseCase clear;
  final RestoreDemoDataUseCase restore;
  DataManagementBloc(this.clear, this.restore)
      : super(const DataManagementState()) {
    on<DataManagementEvent>((event, emit) async {
      if (state.status == DataManagementStatus.loading) return;
      emit(DataManagementState(
          status: DataManagementStatus.loading, action: event.action));
      final result =
          await (event.action == DataAction.clear ? clear() : restore());
      result.fold(
          (failure) => emit(DataManagementState(
              status: DataManagementStatus.error,
              action: event.action,
              error: failure.message)),
          (_) => emit(DataManagementState(
              status: DataManagementStatus.success, action: event.action)));
    });
  }
}
