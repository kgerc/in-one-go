import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_settings_entity.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

/// Loading settings
class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

/// Settings loaded
class SettingsLoaded extends SettingsState {
  final UserSettingsEntity settings;

  const SettingsLoaded({required this.settings});

  @override
  List<Object?> get props => [settings];
}

/// Settings error
class SettingsError extends SettingsState {
  final String message;

  const SettingsError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Google Calendar sign-in in progress
class SettingsGoogleSignInInProgress extends SettingsState {
  const SettingsGoogleSignInInProgress();
}

/// Google Calendar signed in successfully
class SettingsGoogleSignedIn extends SettingsState {
  final String email;

  const SettingsGoogleSignedIn({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Google Calendar sign-out in progress
class SettingsGoogleSignOutInProgress extends SettingsState {
  const SettingsGoogleSignOutInProgress();
}

/// Google Calendar signed out successfully
class SettingsGoogleSignedOut extends SettingsState {
  const SettingsGoogleSignedOut();
}
