import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../injection_container.dart';
import '../../blocs/voice_assistant/voice_assistant_bloc.dart';
import '../../blocs/voice_assistant/voice_assistant_event.dart';
import '../../blocs/voice_assistant/voice_assistant_state.dart';
import 'package:intl/intl.dart';

class VoiceAssistantScreen extends StatelessWidget {
  const VoiceAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<VoiceAssistantBloc>(),
      child: const VoiceAssistantView(),
    );
  }
}

class VoiceAssistantView extends StatelessWidget {
  const VoiceAssistantView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('InOneGo'),
        centerTitle: true,
      ),
      body: BlocConsumer<VoiceAssistantBloc, VoiceAssistantState>(
        listener: (context, state) {
          if (state is VoiceAssistantError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                action: state.canRetry
                    ? SnackBarAction(
                        label: 'Retry',
                        textColor: Colors.white,
                        onPressed: () {
                          context
                              .read<VoiceAssistantBloc>()
                              .add(const RetryEvent());
                        },
                      )
                    : null,
              ),
            );
          } else if (state is VoiceAssistantPermissionDenied) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(AppConstants.msgMicrophonePermissionDenied),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingLg),
              child: Column(
                children: [
                  // Header
                  _buildHeader(context),
                  const SizedBox(height: AppConstants.spacingXl),

                  // Main content based on state
                  Expanded(
                    child: _buildContent(context, state),
                  ),

                  // Microphone button
                  _buildMicrophoneButton(context, state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Text(
          'What would you like to do?',
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.spacingSm),
        Text(
          'Tap the microphone and speak naturally',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, VoiceAssistantState state) {
    if (state is VoiceAssistantListening) {
      return _buildListeningView(context, state);
    } else if (state is VoiceAssistantProcessing) {
      return _buildProcessingView(context);
    } else if (state is VoiceAssistantEventParsed) {
      return _buildEventParsedView(context, state);
    } else if (state is VoiceAssistantSaving) {
      return _buildSavingView(context);
    } else if (state is VoiceAssistantSaved) {
      return _buildSavedView(context, state);
    } else {
      return _buildInitialView(context);
    }
  }

  Widget _buildInitialView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.mic_none,
          size: 100,
          color: AppColors.textTertiary,
        ),
        const SizedBox(height: AppConstants.spacingLg),
        Text(
          'Tap to start',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textTertiary,
              ),
        ),
        const SizedBox(height: AppConstants.spacingXl),
        // Example commands
        _buildExampleCommands(context),
      ],
    );
  }

  Widget _buildListeningView(
    BuildContext context,
    VoiceAssistantListening state,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated microphone icon
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 1.0, end: 1.2),
          duration: const Duration(milliseconds: 500),
          builder: (context, double value, child) {
            return Transform.scale(
              scale: value,
              child: const Icon(
                Icons.mic,
                size: 100,
                color: AppColors.primary,
              ),
            );
          },
          onEnd: () {},
        ),
        const SizedBox(height: AppConstants.spacingLg),
        const Text(
          'Listening...',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppConstants.spacingXl),
        // Transcription
        if (state.currentTranscription.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              border: Border.all(color: AppColors.divider),
            ),
            child: Text(
              state.currentTranscription,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Widget _buildProcessingView(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: AppConstants.spacingLg),
        Text(
          'Processing your request...',
          style: TextStyle(
            fontSize: 18,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEventParsedView(
    BuildContext context,
    VoiceAssistantEventParsed state,
  ) {
    final event = state.event;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Confidence indicator
          if (state.isLowConfidence)
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingSm),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusSm),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: AppColors.warning, size: 20),
                  SizedBox(width: AppConstants.spacingSm),
                  Expanded(
                    child: Text(
                      'Low confidence - please review details',
                      style: TextStyle(color: AppColors.warning),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppConstants.spacingLg),

          // Event details card
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingLg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  'Event Preview',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Divider(height: AppConstants.spacingLg),

                _buildDetailRow(context, 'Title', event.title),
                if (event.description != null)
                  _buildDetailRow(context, 'Description', event.description!),
                _buildDetailRow(
                  context,
                  'Start',
                  DateFormat('EEE, MMM d, y - HH:mm')
                      .format(event.startDateTime),
                ),
                if (event.endDateTime != null)
                  _buildDetailRow(
                    context,
                    'End',
                    DateFormat('EEE, MMM d, y - HH:mm')
                        .format(event.endDateTime!),
                  ),
                if (event.location != null)
                  _buildDetailRow(context, 'Location', event.location!),
                _buildDetailRow(context, 'Type', event.eventType.displayName),
                _buildDetailRow(
                  context,
                  'Priority',
                  event.priority.displayName,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacingXl),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context
                        .read<VoiceAssistantBloc>()
                        .add(const CancelEventEvent());
                  },
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<VoiceAssistantBloc>().add(
                          ConfirmEventEvent(
                            event: event,
                            confidenceScore: state.confidenceScore,
                          ),
                        );
                  },
                  child: const Text('Confirm & Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingView(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: AppConstants.spacingLg),
        Text(
          'Saving event...',
          style: TextStyle(
            fontSize: 18,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSavedView(BuildContext context, VoiceAssistantSaved state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.check_circle,
          size: 100,
          color: AppColors.success,
        ),
        const SizedBox(height: AppConstants.spacingLg),
        const Text(
          'Event created!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: AppConstants.spacingSm),
        if (state.calendarSynced)
          const Text(
            'Synced with Google Calendar',
            style: TextStyle(color: AppColors.textSecondary),
          )
        else if (state.syncWarning != null)
          Text(
            state.syncWarning!,
            style: const TextStyle(color: AppColors.warning),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }

  Widget _buildExampleCommands(BuildContext context) {
    return Column(
      children: [
        Text(
          'Try saying:',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.textTertiary,
              ),
        ),
        const SizedBox(height: AppConstants.spacingSm),
        ...AppConstants.exampleVoiceCommands.take(3).map(
              (command) => Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.spacingXs,
                ),
                child: Text(
                  '"$command"',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                        fontStyle: FontStyle.italic,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildMicrophoneButton(
    BuildContext context,
    VoiceAssistantState state,
  ) {
    final bool isListening = state is VoiceAssistantListening;
    final bool isDisabled = state is VoiceAssistantProcessing ||
        state is VoiceAssistantSaving ||
        state is VoiceAssistantSaved;

    return GestureDetector(
      onTap: isDisabled
          ? null
          : () {
              if (isListening) {
                context
                    .read<VoiceAssistantBloc>()
                    .add(const StopListeningEvent());
              } else {
                context
                    .read<VoiceAssistantBloc>()
                    .add(const StartListeningEvent());
              }
            },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDisabled
              ? AppColors.disabled
              : (isListening ? AppColors.error : AppColors.primary),
          boxShadow: [
            BoxShadow(
              color: (isListening ? AppColors.error : AppColors.primary)
                  .withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: isListening ? 10 : 0,
            ),
          ],
        ),
        child: Icon(
          isListening ? Icons.stop : Icons.mic,
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }
}
