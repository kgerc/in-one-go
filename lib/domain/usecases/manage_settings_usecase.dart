import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user_settings_entity.dart';
import '../repositories/i_settings_repository.dart';

class ManageSettingsUseCase {
  final ISettingsRepository repository;

  ManageSettingsUseCase({required this.repository});

  Future<Either<Failure, UserSettingsEntity>> getSettings() {
    return repository.getSettings();
  }

  Future<Either<Failure, void>> updateSettings(UserSettingsEntity settings) {
    return repository.updateSettings(settings);
  }

  Future<Either<Failure, void>> updateSettingsFields({
    bool? enableLocalStorage,
    bool? enableEmailNotifications,
    bool? enableMessengerNotifications,
  }) {
    return repository.updateSettingsFields(
      enableLocalStorage: enableLocalStorage,
      enableEmailNotifications: enableEmailNotifications,
      enableMessengerNotifications: enableMessengerNotifications,
    );
  }

  Future<Either<Failure, void>> markOnboardingCompleted() {
    return repository.markOnboardingCompleted();
  }

  Stream<Either<Failure, UserSettingsEntity>> watchSettings() {
    return repository.watchSettings();
  }
}
