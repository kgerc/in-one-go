import 'package:equatable/equatable.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

/// Move to next page
class OnboardingNextPageEvent extends OnboardingEvent {
  const OnboardingNextPageEvent();
}

/// Move to previous page
class OnboardingPreviousPageEvent extends OnboardingEvent {
  const OnboardingPreviousPageEvent();
}

/// Skip onboarding
class OnboardingSkipEvent extends OnboardingEvent {
  const OnboardingSkipEvent();
}

/// Complete onboarding
class OnboardingCompleteEvent extends OnboardingEvent {
  final bool enableLocalStorage;
  final bool enableEmailNotifications;
  final bool enableMessengerNotifications;

  const OnboardingCompleteEvent({
    this.enableLocalStorage = true,
    this.enableEmailNotifications = false,
    this.enableMessengerNotifications = false,
  });

  @override
  List<Object?> get props => [
        enableLocalStorage,
        enableEmailNotifications,
        enableMessengerNotifications,
      ];
}

/// Request microphone permission
class OnboardingRequestMicrophonePermissionEvent extends OnboardingEvent {
  const OnboardingRequestMicrophonePermissionEvent();
}

/// Connect Google Calendar
class OnboardingConnectGoogleCalendarEvent extends OnboardingEvent {
  const OnboardingConnectGoogleCalendarEvent();
}
