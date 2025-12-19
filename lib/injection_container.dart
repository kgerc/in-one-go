import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Data Sources
import 'data/data_sources/local/app_database.dart';
import 'data/data_sources/remote/gemini_api_service.dart';
import 'data/data_sources/remote/google_calendar_service.dart';

// Repositories
import 'data/repositories/event_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/gemini_repository.dart';
import 'data/repositories/calendar_repository.dart';
import 'domain/repositories/i_event_repository.dart';
import 'domain/repositories/i_settings_repository.dart';
import 'domain/repositories/i_gemini_repository.dart';
import 'domain/repositories/i_calendar_repository.dart';

// Use Cases
import 'domain/usecases/process_voice_input_usecase.dart';
import 'domain/usecases/get_events_usecase.dart';
import 'domain/usecases/manage_event_usecase.dart';
import 'domain/usecases/manage_calendar_usecase.dart';
import 'domain/usecases/manage_settings_usecase.dart';

// BLoCs
import 'presentation/blocs/voice_assistant/voice_assistant_bloc.dart';
import 'presentation/blocs/events/events_bloc.dart';
import 'presentation/blocs/settings/settings_bloc.dart';
import 'presentation/blocs/onboarding/onboarding_bloc.dart';

final sl = GetIt.instance; // Service Locator

Future<void> initializeDependencies() async {
  // ========== External Dependencies ==========

  // Dio (HTTP Client)
  sl.registerLazySingleton<Dio>(() => Dio());

  // Google Sign In
  sl.registerLazySingleton<GoogleSignIn>(
    () => GoogleSignIn(
      scopes: [
        'email',
        'https://www.googleapis.com/auth/calendar',
      ],
    ),
  );

  // Speech to Text
  sl.registerFactory<SpeechToText>(() => SpeechToText());

  // Database
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // ========== Data Sources ==========

  // Gemini API Service
  sl.registerLazySingleton<GeminiApiService>(
    () => GeminiApiService(
      apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
      dio: sl<Dio>(),
    ),
  );

  // Google Calendar Service
  sl.registerLazySingleton<GoogleCalendarService>(
    () => GoogleCalendarService(
      googleSignIn: sl<GoogleSignIn>(),
    ),
  );

  // ========== Repositories ==========

  // Event Repository
  sl.registerLazySingleton<IEventRepository>(
    () => EventRepository(
      database: sl<AppDatabase>(),
      calendarService: sl<GoogleCalendarService>(),
    ),
  );

  // Settings Repository
  sl.registerLazySingleton<ISettingsRepository>(
    () => SettingsRepository(
      database: sl<AppDatabase>(),
    ),
  );

  // Gemini Repository
  sl.registerLazySingleton<IGeminiRepository>(
    () => GeminiRepository(
      apiService: sl<GeminiApiService>(),
    ),
  );

  // Calendar Repository
  sl.registerLazySingleton<ICalendarRepository>(
    () => CalendarRepository(
      calendarService: sl<GoogleCalendarService>(),
    ),
  );

  // ========== Use Cases ==========

  // Process Voice Input Use Case (main orchestrator)
  sl.registerLazySingleton<ProcessVoiceInputUseCase>(
    () => ProcessVoiceInputUseCase(
      geminiRepository: sl<IGeminiRepository>(),
      eventRepository: sl<IEventRepository>(),
      calendarRepository: sl<ICalendarRepository>(),
      settingsRepository: sl<ISettingsRepository>(),
    ),
  );

  // Get Events Use Case
  sl.registerLazySingleton<GetEventsUseCase>(
    () => GetEventsUseCase(
      repository: sl<IEventRepository>(),
    ),
  );

  // Manage Event Use Case
  sl.registerLazySingleton<ManageEventUseCase>(
    () => ManageEventUseCase(
      repository: sl<IEventRepository>(),
    ),
  );

  // Manage Calendar Use Case
  sl.registerLazySingleton<ManageCalendarUseCase>(
    () => ManageCalendarUseCase(
      calendarRepository: sl<ICalendarRepository>(),
      settingsRepository: sl<ISettingsRepository>(),
    ),
  );

  // Manage Settings Use Case
  sl.registerLazySingleton<ManageSettingsUseCase>(
    () => ManageSettingsUseCase(
      repository: sl<ISettingsRepository>(),
    ),
  );

  // ========== BLoCs (Factory - new instance each time) ==========

  // Voice Assistant BLoC
  sl.registerFactory<VoiceAssistantBloc>(
    () => VoiceAssistantBloc(
      processVoiceInputUseCase: sl<ProcessVoiceInputUseCase>(),
      speechToText: sl<SpeechToText>(),
    ),
  );

  // Events BLoC
  sl.registerFactory<EventsBloc>(
    () => EventsBloc(
      getEventsUseCase: sl<GetEventsUseCase>(),
      manageEventUseCase: sl<ManageEventUseCase>(),
    ),
  );

  // Settings BLoC
  sl.registerFactory<SettingsBloc>(
    () => SettingsBloc(
      manageSettingsUseCase: sl<ManageSettingsUseCase>(),
      manageCalendarUseCase: sl<ManageCalendarUseCase>(),
    ),
  );

  // Onboarding BLoC
  sl.registerFactory<OnboardingBloc>(
    () => OnboardingBloc(
      manageSettingsUseCase: sl<ManageSettingsUseCase>(),
      manageCalendarUseCase: sl<ManageCalendarUseCase>(),
    ),
  );
}

/// Cleanup method (optional - for testing)
Future<void> resetDependencies() async {
  await sl.reset();
}
