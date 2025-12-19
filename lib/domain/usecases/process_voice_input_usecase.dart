import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/event_entity.dart';
import '../repositories/i_gemini_repository.dart';
import '../repositories/i_event_repository.dart';
import '../repositories/i_calendar_repository.dart';
import '../repositories/i_settings_repository.dart';

class ProcessVoiceInputUseCase {
  final IGeminiRepository geminiRepository;
  final IEventRepository eventRepository;
  final ICalendarRepository calendarRepository;
  final ISettingsRepository settingsRepository;

  ProcessVoiceInputUseCase({
    required this.geminiRepository,
    required this.eventRepository,
    required this.calendarRepository,
    required this.settingsRepository,
  });

  /// Process voice transcription and create event
  /// Returns: (parsedEvent, savedEventId, confidenceScore)
  Future<Either<Failure, ProcessVoiceResult>> execute(
    String transcription,
  ) async {
    // Step 1: Parse transcription with Gemini
    final parseResult = await geminiRepository.parseEventFromText(transcription);

    return await parseResult.fold(
      (failure) => Left(failure),
      (parsedEvent) async {
        // Step 2: Save event locally
        final saveResult = await eventRepository.saveEvent(parsedEvent.event);

        return await saveResult.fold(
          (failure) => Left(failure),
          (eventId) async {
            EventEntity savedEvent = parsedEvent.event.copyWith(id: eventId);

            // Step 3: Get user settings
            final settingsResult = await settingsRepository.getSettings();

            return await settingsResult.fold(
              (failure) => Left(failure),
              (settings) async {
                // Step 4: Sync with Google Calendar if connected
                if (settings.isGoogleCalendarConnected &&
                    calendarRepository.isSignedIn) {
                  final syncResult =
                      await eventRepository.syncEventWithCalendar(savedEvent);

                  return syncResult.fold(
                    (failure) {
                      // Calendar sync failed, but event is saved locally
                      return Right(
                        ProcessVoiceResult(
                          event: savedEvent,
                          eventId: eventId,
                          confidenceScore: parsedEvent.confidenceScore,
                          calendarSyncFailed: true,
                          syncFailureMessage: failure.message,
                        ),
                      );
                    },
                    (_) {
                      // Successfully saved and synced
                      return Right(
                        ProcessVoiceResult(
                          event: savedEvent,
                          eventId: eventId,
                          confidenceScore: parsedEvent.confidenceScore,
                          calendarSyncFailed: false,
                        ),
                      );
                    },
                  );
                } else {
                  // Calendar not connected, only saved locally
                  return Right(
                    ProcessVoiceResult(
                      event: savedEvent,
                      eventId: eventId,
                      confidenceScore: parsedEvent.confidenceScore,
                      calendarSyncFailed: false,
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }
}

class ProcessVoiceResult {
  final EventEntity event;
  final int eventId;
  final double confidenceScore;
  final bool calendarSyncFailed;
  final String? syncFailureMessage;

  ProcessVoiceResult({
    required this.event,
    required this.eventId,
    required this.confidenceScore,
    required this.calendarSyncFailed,
    this.syncFailureMessage,
  });

  bool get isHighConfidence => confidenceScore >= 0.8;
  bool get isLowConfidence => confidenceScore < 0.7;
}
