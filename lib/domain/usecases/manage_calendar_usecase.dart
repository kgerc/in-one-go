import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../repositories/i_calendar_repository.dart';
import '../repositories/i_settings_repository.dart';

class ManageCalendarUseCase {
  final ICalendarRepository calendarRepository;
  final ISettingsRepository settingsRepository;

  ManageCalendarUseCase({
    required this.calendarRepository,
    required this.settingsRepository,
  });

  Future<Either<Failure, void>> initialize() {
    return calendarRepository.initialize();
  }

  Future<Either<Failure, String>> signInToGoogleCalendar() async {
    final signInResult = await calendarRepository.signIn();

    return await signInResult.fold(
      (failure) => Left(failure),
      (email) async {
        // Update settings to reflect connection
        final updateResult = await settingsRepository.connectGoogleCalendar(email);

        return updateResult.fold(
          (failure) => Left(failure),
          (_) => Right(email),
        );
      },
    );
  }

  Future<Either<Failure, void>> signOutFromGoogleCalendar() async {
    final signOutResult = await calendarRepository.signOut();

    return await signOutResult.fold(
      (failure) => Left(failure),
      (_) async {
        // Update settings to reflect disconnection
        final updateResult = await settingsRepository.disconnectGoogleCalendar();

        return updateResult.fold(
          (failure) => Left(failure),
          (_) => const Right(null),
        );
      },
    );
  }

  bool get isSignedIn => calendarRepository.isSignedIn;

  String? get currentUserEmail => calendarRepository.currentUserEmail;
}
