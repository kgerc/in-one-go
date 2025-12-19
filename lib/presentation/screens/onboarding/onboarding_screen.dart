import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../injection_container.dart';
import '../../blocs/onboarding/onboarding_bloc.dart';
import '../../blocs/onboarding/onboarding_event.dart';
import '../../blocs/onboarding/onboarding_state.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<OnboardingBloc>(),
      child: const OnboardingView(),
    );
  }
}

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingCompleted) {
          context.go('/home');
        }
      },
      builder: (context, state) {
        if (state is OnboardingInProgress) {
          return Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingLg),
                child: Column(
                  children: [
                    // Progress indicator
                    LinearProgressIndicator(
                      value: (state.currentPage + 1) / state.totalPages,
                      backgroundColor: AppColors.divider,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingXl),

                    // Content
                    Expanded(
                      child: _buildPageContent(context, state),
                    ),

                    // Navigation buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (!state.isFirstPage)
                          TextButton(
                            onPressed: () {
                              context
                                  .read<OnboardingBloc>()
                                  .add(const OnboardingPreviousPageEvent());
                            },
                            child: const Text('Back'),
                          )
                        else
                          const SizedBox(),

                        ElevatedButton(
                          onPressed: () {
                            if (state.isLastPage) {
                              context
                                  .read<OnboardingBloc>()
                                  .add(const OnboardingCompleteEvent());
                            } else {
                              context
                                  .read<OnboardingBloc>()
                                  .add(const OnboardingNextPageEvent());
                            }
                          },
                          child: Text(state.isLastPage ? 'Get Started' : 'Next'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget _buildPageContent(BuildContext context, OnboardingInProgress state) {
    final currentPage = state.currentPage;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icon
        Icon(
          _getPageIcon(currentPage),
          size: 100,
          color: AppColors.primary,
        ),
        const SizedBox(height: AppConstants.spacingXl),

        // Title
        Text(
          AppConstants.onboardingTitles[currentPage],
          style: Theme.of(context).textTheme.displaySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.spacingMd),

        // Description
        Text(
          AppConstants.onboardingDescriptions[currentPage],
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.spacingXl),

        // Page-specific actions
        _buildPageAction(context, currentPage, state),
      ],
    );
  }

  IconData _getPageIcon(int page) {
    switch (page) {
      case 0:
        return Icons.waving_hand;
      case 1:
        return Icons.mic;
      case 2:
        return Icons.mic_none;
      case 3:
        return Icons.calendar_today;
      case 4:
        return Icons.notifications;
      case 5:
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }

  Widget _buildPageAction(
    BuildContext context,
    int page,
    OnboardingInProgress state,
  ) {
    switch (page) {
      case 2: // Microphone permission page
        if (state.microphonePermissionGranted) {
          return const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: AppColors.success),
              SizedBox(width: AppConstants.spacingSm),
              Text(
                'Permission granted',
                style: TextStyle(color: AppColors.success),
              ),
            ],
          );
        } else {
          return ElevatedButton.icon(
            onPressed: () {
              context
                  .read<OnboardingBloc>()
                  .add(const OnboardingRequestMicrophonePermissionEvent());
            },
            icon: const Icon(Icons.mic),
            label: const Text('Grant Permission'),
          );
        }

      case 3: // Google Calendar connection page
        if (state.googleCalendarConnected) {
          return const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: AppColors.success),
              SizedBox(width: AppConstants.spacingSm),
              Text(
                'Calendar connected',
                style: TextStyle(color: AppColors.success),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  context
                      .read<OnboardingBloc>()
                      .add(const OnboardingConnectGoogleCalendarEvent());
                },
                icon: const Icon(Icons.calendar_today),
                label: const Text('Connect Google Calendar'),
              ),
              const SizedBox(height: AppConstants.spacingSm),
              TextButton(
                onPressed: () {
                  context
                      .read<OnboardingBloc>()
                      .add(const OnboardingNextPageEvent());
                },
                child: const Text('Skip for now'),
              ),
            ],
          );
        }

      default:
        return const SizedBox();
    }
  }
}
