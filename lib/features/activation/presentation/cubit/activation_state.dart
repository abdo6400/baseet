import 'package:equatable/equatable.dart';

enum ActivationStatus { initial, loading, activating, success, error }

class ActivationState extends Equatable {
  final ActivationStatus status;
  final String deviceId;
  final bool isLoadingDevice;
  final bool isExpired;
  final DateTime? expiredAt;
  final bool seedDummyData;
  final String? errorMessage;

  const ActivationState({
    this.status = ActivationStatus.initial,
    this.deviceId = '...',
    this.isLoadingDevice = true,
    this.isExpired = false,
    this.expiredAt,
    this.seedDummyData = true,
    this.errorMessage,
  });

  ActivationState copyWith({
    ActivationStatus? status,
    String? deviceId,
    bool? isLoadingDevice,
    bool? isExpired,
    DateTime? expiredAt,
    bool? seedDummyData,
    String? errorMessage,
  }) {
    return ActivationState(
      status: status ?? this.status,
      deviceId: deviceId ?? this.deviceId,
      isLoadingDevice: isLoadingDevice ?? this.isLoadingDevice,
      isExpired: isExpired ?? this.isExpired,
      expiredAt: expiredAt ?? this.expiredAt,
      seedDummyData: seedDummyData ?? this.seedDummyData,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        deviceId,
        isLoadingDevice,
        isExpired,
        expiredAt,
        seedDummyData,
        errorMessage,
      ];
}
