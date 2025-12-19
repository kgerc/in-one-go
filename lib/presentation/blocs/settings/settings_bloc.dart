import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/manage_settings_usecase.dart';
import '../../../domain/usecases/manage_calendar_usecase.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final ManageSettingsUseCase manageSettingsUseCase;
  final ManageCalendarUseCase manageCalendarUseCase;

  SettingsBloc({
    required this.manageSettingsUseCase,
    required this.manageCalendarUseCase,
  }) : super(const SettingsInitial()) {
    on<LoadSettingsEvent>(_onLoadSettings);
    on<ToggleLocalStorageEvent>(_onToggleLocalStorage);
    on<ToggleEmailNotificationsEvent>(_onToggleEmailNotifications);
    on<ToggleMessengerNotificationsEvent>(_onToggleMessengerNotifications);
    on<SignInToGoogleCalendarEvent>(_onSignInToGoogleCalendar);
    on<SignOutFromGoogleCalendarEvent>(_onSignOutFromGoogleCalendar);
  }

  Future<void> _onLoadSettings(
    LoadSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());

    final result = await manageSettingsUseCase.getSettings();

    result.fold(
      (failure) => emit(SettingsError(message: failure.message)),
      (settings) => emit(SettingsLoaded(settings: settings)),
    );
  }

  Future<void> _onToggleLocalStorage(
    ToggleLocalStorageEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final result = await manageSettingsUseCase.updateSettingsFields(
      enableLocalStorage: event.enabled,
    );

    result.fold(
      (failure) => emit(SettingsError(message: failure.message)),
      (_) => add(const LoadSettingsEvent()),
    );
  }

  Future<void> _onToggleEmailNotifications(
    ToggleEmailNotificationsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final result = await manageSettingsUseCase.updateSettingsFields(
      enableEmailNotifications: event.enabled,
    );

    result.fold(
      (failure) => emit(SettingsError(message: failure.message)),
      (_) => add(const LoadSettingsEvent()),
    );
  }

  Future<void> _onToggleMessengerNotifications(
    ToggleMessengerNotificationsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final result = await manageSettingsUseCase.updateSettingsFields(
      enableMessengerNotifications: event.enabled,
    );

    result.fold(
      (failure) => emit(SettingsError(message: failure.message)),
      (_) => add(const LoadSettingsEvent()),
    );
  }

  Future<void> _onSignInToGoogleCalendar(
    SignInToGoogleCalendarEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsGoogleSignInInProgress());

    final result = await manageCalendarUseCase.signInToGoogleCalendar();

    result.fold(
      (failure) {
        emit(SettingsError(message: failure.message));
        // Return to settings loaded after error
        Future.delayed(const Duration(seconds: 2), () {
          add(const LoadSettingsEvent());
        });
      },
      (email) {
        emit(SettingsGoogleSignedIn(email: email));
        // Reload settings to show updated connection status
        Future.delayed(const Duration(seconds: 1), () {
          add(const LoadSettingsEvent());
        });
      },
    );
  }

  Future<void> _onSignOutFromGoogleCalendar(
    SignOutFromGoogleCalendarEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsGoogleSignOutInProgress());

    final result = await manageCalendarUseCase.signOutFromGoogleCalendar();

    result.fold(
      (failure) {
        emit(SettingsError(message: failure.message));
        // Return to settings loaded after error
        Future.delayed(const Duration(seconds: 2), () {
          add(const LoadSettingsEvent());
        });
      },
      (_) {
        emit(const SettingsGoogleSignedOut());
        // Reload settings to show updated connection status
        Future.delayed(const Duration(seconds: 1), () {
          add(const LoadSettingsEvent());
        });
      },
    );
  }
}
