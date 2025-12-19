import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Load settings
class LoadSettingsEvent extends SettingsEvent {
  const LoadSettingsEvent();
}

/// Toggle local storage
class ToggleLocalStorageEvent extends SettingsEvent {
  final bool enabled;

  const ToggleLocalStorageEvent({required this.enabled});

  @override
  List<Object?> get props => [enabled];
}

/// Toggle email notifications
class ToggleEmailNotificationsEvent extends SettingsEvent {
  final bool enabled;

  const ToggleEmailNotificationsEvent({required this.enabled});

  @override
  List<Object?> get props => [enabled];
}

/// Toggle messenger notifications
class ToggleMessengerNotificationsEvent extends SettingsEvent {
  final bool enabled;

  const ToggleMessengerNotificationsEvent({required this.enabled});

  @override
  List<Object?> get props => [enabled];
}

/// Sign in to Google Calendar
class SignInToGoogleCalendarEvent extends SettingsEvent {
  const SignInToGoogleCalendarEvent();
}

/// Sign out from Google Calendar
class SignOutFromGoogleCalendarEvent extends SettingsEvent {
  const SignOutFromGoogleCalendarEvent();
}
