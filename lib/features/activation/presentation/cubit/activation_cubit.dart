import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/database/local/app_database.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/services/device_id_service.dart';
import '../../../../core/services/license_service.dart';
import '../../../../core/utils/strings_manager.dart';
import 'activation_state.dart';

class ActivationCubit extends Cubit<ActivationState> {
  final DeviceIdService _deviceIdService;
  final LicenseService _licenseService;
  final AppDatabase _appDatabase;

  ActivationCubit({
    required DeviceIdService deviceIdService,
    required LicenseService licenseService,
    required AppDatabase appDatabase,
    bool isExpiredInitial = false,
  })  : _deviceIdService = deviceIdService,
        _licenseService = licenseService,
        _appDatabase = appDatabase,
        super(ActivationState(isExpired: isExpiredInitial));

  Future<void> loadDeviceAndLicense({bool isExpiredInitial = false}) async {
    emit(state.copyWith(isLoadingDevice: true));

    final id = await _deviceIdService.getDeviceId();
    final status = await _licenseService.checkLicense();
    final licenseInfo = _licenseService.currentLicense;

    final isExpired = status == LicenseStatus.expired || isExpiredInitial;
    final expiredAt = isExpired ? licenseInfo?.expiresAt : null;

    emit(state.copyWith(
      deviceId: id,
      isLoadingDevice: false,
      isExpired: isExpired,
      expiredAt: expiredAt,
    ));
  }

  void toggleSeedDummyData(bool value) {
    emit(state.copyWith(seedDummyData: value));
  }

  Future<void> activate(String key) async {
    final inputKey = key.trim();
    if (inputKey.isEmpty) {
      emit(state.copyWith(
        status: ActivationStatus.error,
        errorMessage: StringsManager.activationErrorInvalidKey.lang,
      ));
      return;
    }

    emit(state.copyWith(status: ActivationStatus.activating));

    final result = await _licenseService.activateKey(inputKey);

    if (result.isSuccess) {
      if (state.seedDummyData && !state.isExpired) {
        await _appDatabase.seedDummyData();
      }
      emit(state.copyWith(status: ActivationStatus.success));
    } else {
      String errorMessage;
      switch (result.error) {
        case ActivationError.deviceMismatch:
          errorMessage = StringsManager.activationErrorDeviceMismatch.lang;
          break;
        case ActivationError.alreadyExpired:
          errorMessage = StringsManager.activationErrorExpired.lang;
          break;
        case ActivationError.clockTampered:
          errorMessage = StringsManager.activationErrorClock.lang;
          break;
        case ActivationError.invalidSignature:
        case ActivationError.invalidFormat:
        default:
          errorMessage = StringsManager.activationErrorInvalidKey.lang;
          break;
      }

      emit(state.copyWith(
        status: ActivationStatus.error,
        errorMessage: errorMessage,
      ));
    }
  }
}
