import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user_settings_entity.dart';
import '../../domain/repositories/i_settings_repository.dart';
import '../data_sources/local/app_database.dart';
import '../models/user_settings_model.dart';

class SettingsRepository implements ISettingsRepository {
  final AppDatabase database;

  SettingsRepository({required this.database});

  @override
  Future<Either<Failure, UserSettingsEntity>> getSettings() async {
    try {
      var settings = await database.getUserSettings();

      // If no settings exist, initialize default settings
      if (settings == null) {
        await database.initializeSettings();
        settings = await database.getUserSettings();
      }

      if (settings == null) {
        return const Left(
          CacheFailure(message: 'Failed to initialize settings'),
        );
      }

      return Right(settings.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Failed to get settings: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateSettings(
    UserSettingsEntity settings,
  ) async {
    try {
      await database.updateSettings(settings.toModel());
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Failed to update settings: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateSettingsFields({
    bool? enableLocalStorage,
    bool? enableEmailNotifications,
    bool? enableMessengerNotifications,
    bool? isGoogleCalendarConnected,
    bool? isFacebookConnected,
    String? googleAccountEmail,
    String? facebookUserId,
    bool? hasCompletedOnboarding,
  }) async {
    try {
      await database.updateSettingsFields(
        enableLocalStorage: enableLocalStorage,
        enableEmailNotifications: enableEmailNotifications,
        enableMessengerNotifications: enableMessengerNotifications,
        isGoogleCalendarConnected: isGoogleCalendarConnected,
        isFacebookConnected: isFacebookConnected,
        googleAccountEmail: googleAccountEmail,
        facebookUserId: facebookUserId,
        hasCompletedOnboarding: hasCompletedOnboarding,
      );
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
        UnexpectedFailure(message: 'Failed to update settings fields: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> markOnboardingCompleted() async {
    try {
      await database.markOnboardingCompleted();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
        UnexpectedFailure(message: 'Failed to mark onboarding completed: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> connectGoogleCalendar(String email) async {
    try {
      await database.connectGoogleCalendar(email);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
        UnexpectedFailure(message: 'Failed to connect Google Calendar: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> disconnectGoogleCalendar() async {
    try {
      await database.disconnectGoogleCalendar();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
        UnexpectedFailure(message: 'Failed to disconnect Google Calendar: $e'),
      );
    }
  }

  @override
  Stream<Either<Failure, UserSettingsEntity>> watchSettings() {
    try {
      return database.watchUserSettings().map((settings) {
        if (settings == null) {
          return const Left<Failure, UserSettingsEntity>(
            CacheFailure(message: 'Settings not found'),
          );
        }
        return Right<Failure, UserSettingsEntity>(settings.toEntity());
      });
    } catch (e) {
      return Stream.value(
        Left(UnexpectedFailure(message: 'Failed to watch settings: $e')),
      );
    }
  }
}
