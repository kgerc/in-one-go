import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../domain/usecases/process_voice_input_usecase.dart';
import 'voice_assistant_event.dart';
import 'voice_assistant_state.dart';

class VoiceAssistantBloc
    extends Bloc<VoiceAssistantEvent, VoiceAssistantState> {
  final ProcessVoiceInputUseCase processVoiceInputUseCase;
  final SpeechToText _speechToText;

  bool _isListening = false;
  String _currentTranscription = '';

  VoiceAssistantBloc({
    required this.processVoiceInputUseCase,
    SpeechToText? speechToText,
  })  : _speechToText = speechToText ?? SpeechToText(),
        super(const VoiceAssistantInitial()) {
    on<StartListeningEvent>(_onStartListening);
    on<StopListeningEvent>(_onStopListening);
    on<TranscriptionUpdatedEvent>(_onTranscriptionUpdated);
    on<ProcessTranscriptionEvent>(_onProcessTranscription);
    on<ConfirmEventEvent>(_onConfirmEvent);
    on<EditEventEvent>(_onEditEvent);
    on<CancelEventEvent>(_onCancelEvent);
    on<ResetEvent>(_onReset);
    on<RetryEvent>(_onRetry);
  }

  Future<void> _onStartListening(
    StartListeningEvent event,
    Emitter<VoiceAssistantState> emit,
  ) async {
    // Check microphone permission
    final permissionStatus = await Permission.microphone.status;
    if (!permissionStatus.isGranted) {
      final result = await Permission.microphone.request();
      if (!result.isGranted) {
        emit(const VoiceAssistantPermissionDenied());
        return;
      }
    }

    // Initialize speech recognition
    final available = await _speechToText.initialize(
      onError: (error) {
        add(const CancelEventEvent());
      },
      onStatus: (status) {
        if (status == 'done' && _isListening) {
          add(StopListeningEvent());
        }
      },
    );

    if (!available) {
      emit(const VoiceAssistantError(
        message: 'Speech recognition not available on this device',
        canRetry: false,
      ));
      return;
    }

    // Start listening
    _isListening = true;
    _currentTranscription = '';
    emit(const VoiceAssistantListening());

    await _speechToText.listen(
      onResult: (result) {
        _currentTranscription = result.recognizedWords;
        add(TranscriptionUpdatedEvent(transcription: _currentTranscription));
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      localeId: 'pl_PL', // Polish language
    );
  }

  Future<void> _onStopListening(
    StopListeningEvent event,
    Emitter<VoiceAssistantState> emit,
  ) async {
    if (_isListening) {
      await _speechToText.stop();
      _isListening = false;

      if (_currentTranscription.trim().isNotEmpty) {
        // Process the transcription
        add(ProcessTranscriptionEvent(transcription: _currentTranscription));
      } else {
        emit(const VoiceAssistantError(
          message: 'No speech detected. Please try again.',
          canRetry: true,
        ));
      }
    }
  }

  void _onTranscriptionUpdated(
    TranscriptionUpdatedEvent event,
    Emitter<VoiceAssistantState> emit,
  ) {
    _currentTranscription = event.transcription;
    emit(VoiceAssistantListening(
      currentTranscription: event.transcription,
    ));
  }

  Future<void> _onProcessTranscription(
    ProcessTranscriptionEvent event,
    Emitter<VoiceAssistantState> emit,
  ) async {
    emit(VoiceAssistantProcessing(transcription: event.transcription));

    // Use Gemini to parse the transcription
    final result = await processVoiceInputUseCase.execute(event.transcription);

    result.fold(
      (failure) {
        emit(VoiceAssistantError(
          message: _getErrorMessage(failure.message),
          originalTranscription: event.transcription,
          canRetry: true,
        ));
      },
      (processResult) {
        // Show parsed event for confirmation
        emit(VoiceAssistantEventParsed(
          event: processResult.event,
          confidenceScore: processResult.confidenceScore,
          originalTranscription: event.transcription,
        ));
      },
    );
  }

  Future<void> _onConfirmEvent(
    ConfirmEventEvent event,
    Emitter<VoiceAssistantState> emit,
  ) async {
    // Event is already saved by ProcessVoiceInputUseCase
    // Just show success state
    emit(VoiceAssistantSaved(
      event: event.event,
      eventId: event.event.id ?? 0,
      calendarSynced: event.event.isSynced,
    ));

    // Auto-reset after 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    if (state is VoiceAssistantSaved) {
      add(const ResetEvent());
    }
  }

  void _onEditEvent(
    EditEventEvent event,
    Emitter<VoiceAssistantState> emit,
  ) {
    // Update the parsed event with edited values
    if (state is VoiceAssistantEventParsed) {
      final currentState = state as VoiceAssistantEventParsed;
      emit(VoiceAssistantEventParsed(
        event: event.editedEvent,
        confidenceScore: currentState.confidenceScore,
        originalTranscription: currentState.originalTranscription,
      ));
    }
  }

  Future<void> _onCancelEvent(
    CancelEventEvent event,
    Emitter<VoiceAssistantState> emit,
  ) async {
    if (_isListening) {
      await _speechToText.stop();
      _isListening = false;
    }
    _currentTranscription = '';
    emit(const VoiceAssistantInitial());
  }

  void _onReset(
    ResetEvent event,
    Emitter<VoiceAssistantState> emit,
  ) {
    _currentTranscription = '';
    emit(const VoiceAssistantInitial());
  }

  void _onRetry(
    RetryEvent event,
    Emitter<VoiceAssistantState> emit,
  ) {
    String? transcription;
    if (state is VoiceAssistantError) {
      transcription = (state as VoiceAssistantError).originalTranscription;
    }

    if (transcription != null && transcription.isNotEmpty) {
      add(ProcessTranscriptionEvent(transcription: transcription));
    } else {
      emit(const VoiceAssistantInitial());
    }
  }

  String _getErrorMessage(String failureMessage) {
    if (failureMessage.contains('network') ||
        failureMessage.contains('connection')) {
      return 'No internet connection. Please check your network and try again.';
    } else if (failureMessage.contains('timeout')) {
      return 'Request timed out. Please try again.';
    } else if (failureMessage.contains('parse') ||
        failureMessage.contains('Gemini')) {
      return 'Could not understand your request. Please try rephrasing.';
    } else if (failureMessage.contains('authentication')) {
      return 'Not signed in to Google Calendar. Please sign in from Settings.';
    } else {
      return 'An error occurred: $failureMessage';
    }
  }

  @override
  Future<void> close() async {
    if (_isListening) {
      await _speechToText.stop();
    }
    return super.close();
  }
}
