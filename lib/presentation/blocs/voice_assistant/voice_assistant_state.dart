import 'package:equatable/equatable.dart';
import '../../../domain/entities/event_entity.dart';

abstract class VoiceAssistantState extends Equatable {
  const VoiceAssistantState();

  @override
  List<Object?> get props => [];
}

/// Initial state - ready to start listening
class VoiceAssistantInitial extends VoiceAssistantState {
  const VoiceAssistantInitial();
}

/// Listening to voice input
class VoiceAssistantListening extends VoiceAssistantState {
  final String currentTranscription;

  const VoiceAssistantListening({
    this.currentTranscription = '',
  });

  @override
  List<Object?> get props => [currentTranscription];
}

/// Processing transcription with Gemini
class VoiceAssistantProcessing extends VoiceAssistantState {
  final String transcription;

  const VoiceAssistantProcessing({required this.transcription});

  @override
  List<Object?> get props => [transcription];
}

/// Event parsed successfully - awaiting user confirmation
class VoiceAssistantEventParsed extends VoiceAssistantState {
  final EventEntity event;
  final double confidenceScore;
  final String originalTranscription;

  const VoiceAssistantEventParsed({
    required this.event,
    required this.confidenceScore,
    required this.originalTranscription,
  });

  bool get isHighConfidence => confidenceScore >= 0.8;
  bool get isLowConfidence => confidenceScore < 0.7;

  @override
  List<Object?> get props => [event, confidenceScore, originalTranscription];
}

/// Saving event to database and calendar
class VoiceAssistantSaving extends VoiceAssistantState {
  final EventEntity event;

  const VoiceAssistantSaving({required this.event});

  @override
  List<Object?> get props => [event];
}

/// Event saved successfully
class VoiceAssistantSaved extends VoiceAssistantState {
  final EventEntity event;
  final int eventId;
  final bool calendarSynced;
  final String? syncWarning;

  const VoiceAssistantSaved({
    required this.event,
    required this.eventId,
    this.calendarSynced = true,
    this.syncWarning,
  });

  @override
  List<Object?> get props => [event, eventId, calendarSynced, syncWarning];
}

/// Error state
class VoiceAssistantError extends VoiceAssistantState {
  final String message;
  final String? originalTranscription;
  final bool canRetry;

  const VoiceAssistantError({
    required this.message,
    this.originalTranscription,
    this.canRetry = true,
  });

  @override
  List<Object?> get props => [message, originalTranscription, canRetry];
}

/// Permission denied state
class VoiceAssistantPermissionDenied extends VoiceAssistantState {
  const VoiceAssistantPermissionDenied();
}
