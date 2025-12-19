import 'package:equatable/equatable.dart';

abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

/// Onboarding in progress
class OnboardingInProgress extends OnboardingState {
  final int currentPage;
  final int totalPages;
  final bool microphonePermissionGranted;
  final bool googleCalendarConnected;

  const OnboardingInProgress({
    required this.currentPage,
    this.totalPages = 6,
    this.microphonePermissionGranted = false,
    this.googleCalendarConnected = false,
  });

  bool get isFirstPage => currentPage == 0;
  bool get isLastPage => currentPage == totalPages - 1;

  OnboardingInProgress copyWith({
    int? currentPage,
    bool? microphonePermissionGranted,
    bool? googleCalendarConnected,
  }) {
    return OnboardingInProgress(
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages,
      microphonePermissionGranted:
          microphonePermissionGranted ?? this.microphonePermissionGranted,
      googleCalendarConnected:
          googleCalendarConnected ?? this.googleCalendarConnected,
    );
  }

  @override
  List<Object?> get props => [
        currentPage,
        totalPages,
        microphonePermissionGranted,
        googleCalendarConnected,
      ];
}

/// Onboarding completed
class OnboardingCompleted extends OnboardingState {
  const OnboardingCompleted();
}

/// Onboarding error
class OnboardingError extends OnboardingState {
  final String message;

  const OnboardingError({required this.message});

  @override
  List<Object?> get props => [message];
}
