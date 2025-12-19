import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user_settings_entity.dart';

abstract class ISettingsRepository {
  /// Get user settings
  Future<Either<Failure, UserSettingsEntity>> getSettings();

  /// Update user settings
  Future<Either<Failure, void>> updateSettings(UserSettingsEntity settings);

  /// Update specific settings fields
  Future<Either<Failure, void>> updateSettingsFields({
    bool? enableLocalStorage,
    bool? enableEmailNotifications,
    bool? enableMessengerNotifications,
    bool? isGoogleCalendarConnected,
    bool? isFacebookConnected,
    String? googleAccountEmail,
    String? facebookUserId,
    bool? hasCompletedOnboarding,
  });

  /// Mark onboarding as completed
  Future<Either<Failure, void>> markOnboardingCompleted();

  /// Connect Google Calendar
  Future<Either<Failure, void>> connectGoogleCalendar(String email);

  /// Disconnect Google Calendar
  Future<Either<Failure, void>> disconnectGoogleCalendar();

  /// Watch user settings (stream)
  Stream<Either<Failure, UserSettingsEntity>> watchSettings();
}
