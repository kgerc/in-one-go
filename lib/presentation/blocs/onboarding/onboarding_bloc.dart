import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../domain/usecases/manage_settings_usecase.dart';
import '../../../domain/usecases/manage_calendar_usecase.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final ManageSettingsUseCase manageSettingsUseCase;
  final ManageCalendarUseCase manageCalendarUseCase;

  static const int totalPages = 6;

  OnboardingBloc({
    required this.manageSettingsUseCase,
    required this.manageCalendarUseCase,
  }) : super(const OnboardingInProgress(currentPage: 0)) {
    on<OnboardingNextPageEvent>(_onNextPage);
    on<OnboardingPreviousPageEvent>(_onPreviousPage);
    on<OnboardingSkipEvent>(_onSkip);
    on<OnboardingCompleteEvent>(_onComplete);
    on<OnboardingRequestMicrophonePermissionEvent>(_onRequestMicrophonePermission);
    on<OnboardingConnectGoogleCalendarEvent>(_onConnectGoogleCalendar);
  }

  void _onNextPage(
    OnboardingNextPageEvent event,
    Emitter<OnboardingState> emit,
  ) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      if (!currentState.isLastPage) {
        emit(currentState.copyWith(
          currentPage: currentState.currentPage + 1,
        ));
      }
    }
  }

  void _onPreviousPage(
    OnboardingPreviousPageEvent event,
    Emitter<OnboardingState> emit,
  ) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      if (!currentState.isFirstPage) {
        emit(currentState.copyWith(
          currentPage: currentState.currentPage - 1,
        ));
      }
    }
  }

  Future<void> _onSkip(
    OnboardingSkipEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    // Complete onboarding with default settings
    add(const OnboardingCompleteEvent());
  }

  Future<void> _onComplete(
    OnboardingCompleteEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    // Update settings with user preferences
    await manageSettingsUseCase.updateSettingsFields(
      enableLocalStorage: event.enableLocalStorage,
      enableEmailNotifications: event.enableEmailNotifications,
      enableMessengerNotifications: event.enableMessengerNotifications,
    );

    // Mark onboarding as completed
    final result = await manageSettingsUseCase.markOnboardingCompleted();

    result.fold(
      (failure) => emit(OnboardingError(message: failure.message)),
      (_) => emit(const OnboardingCompleted()),
    );
  }

  Future<void> _onRequestMicrophonePermission(
    OnboardingRequestMicrophonePermissionEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;

      final status = await Permission.microphone.request();

      emit(currentState.copyWith(
        microphonePermissionGranted: status.isGranted,
      ));

      // Auto-advance to next page if permission granted
      if (status.isGranted) {
        await Future.delayed(const Duration(milliseconds: 500));
        add(const OnboardingNextPageEvent());
      }
    }
  }

  Future<void> _onConnectGoogleCalendar(
    OnboardingConnectGoogleCalendarEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;

      final result = await manageCalendarUseCase.signInToGoogleCalendar();

      result.fold(
        (failure) {
          // Don't block onboarding on calendar connection failure
          // Just show that it's not connected
          emit(currentState.copyWith(googleCalendarConnected: false));
        },
        (email) {
          emit(currentState.copyWith(googleCalendarConnected: true));
          // Auto-advance to next page if connected
          Future.delayed(const Duration(milliseconds: 500), () {
            add(const OnboardingNextPageEvent());
          });
        },
      );
    }
  }
}
