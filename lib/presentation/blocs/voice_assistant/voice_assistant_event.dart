import 'package:equatable/equatable.dart';
import '../../../domain/entities/event_entity.dart';

abstract class VoiceAssistantEvent extends Equatable {
  const VoiceAssistantEvent();

  @override
  List<Object?> get props => [];
}

/// Start listening to voice input
class StartListeningEvent extends VoiceAssistantEvent {
  const StartListeningEvent();
}

/// Stop listening to voice input
class StopListeningEvent extends VoiceAssistantEvent {
  const StopListeningEvent();
}

/// Update transcription while listening
class TranscriptionUpdatedEvent extends VoiceAssistantEvent {
  final String transcription;

  const TranscriptionUpdatedEvent({required this.transcription});

  @override
  List<Object?> get props => [transcription];
}

/// Process the final transcription
class ProcessTranscriptionEvent extends VoiceAssistantEvent {
  final String transcription;

  const ProcessTranscriptionEvent({required this.transcription});

  @override
  List<Object?> get props => [transcription];
}

/// Confirm the parsed event
class ConfirmEventEvent extends VoiceAssistantEvent {
  final EventEntity event;
  final double confidenceScore;

  const ConfirmEventEvent({
    required this.event,
    required this.confidenceScore,
  });

  @override
  List<Object?> get props => [event, confidenceScore];
}

/// Edit the parsed event before confirmation
class EditEventEvent extends VoiceAssistantEvent {
  final EventEntity editedEvent;

  const EditEventEvent({required this.editedEvent});

  @override
  List<Object?> get props => [editedEvent];
}

/// Cancel the current operation
class CancelEventEvent extends VoiceAssistantEvent {
  const CancelEventEvent();
}

/// Reset to initial state
class ResetEvent extends VoiceAssistantEvent {
  const ResetEvent();
}

/// Retry after error
class RetryEvent extends VoiceAssistantEvent {
  const RetryEvent();
}
