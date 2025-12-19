class AppConstants {
  // App Info
  static const String appName = 'InOneGo';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Create events with your voice';

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // Border Radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 9999.0;

  // Icon Sizes
  static const double iconSizeSm = 16.0;
  static const double iconSizeMd = 24.0;
  static const double iconSizeLg = 32.0;
  static const double iconSizeXl = 48.0;
  static const double iconSizeXxl = 64.0;

  // Button Heights
  static const double buttonHeightSm = 40.0;
  static const double buttonHeightMd = 48.0;
  static const double buttonHeightLg = 56.0;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Voice Recognition
  static const int voiceListenDurationSeconds = 30;
  static const int voicePauseDurationSeconds = 3;
  static const String voiceLocale = 'pl_PL'; // Polish

  // Gemini API
  static const double geminiConfidenceThresholdHigh = 0.8;
  static const double geminiConfidenceThresholdLow = 0.7;

  // Event Defaults
  static const int defaultEventDurationMinutes = 60; // 1 hour
  static const int defaultReminderDurationMinutes = 30;

  // Pagination
  static const int defaultEventsLimit = 10;
  static const int maxEventsLimit = 50;

  // Storage Keys
  static const String storageKeyOnboardingComplete = 'onboarding_complete';
  static const String storageKeyFirstLaunch = 'first_launch';

  // API Timeouts
  static const Duration apiConnectTimeout = Duration(seconds: 15);
  static const Duration apiReceiveTimeout = Duration(seconds: 15);

  // Success Messages
  static const String msgEventCreated = 'Event created successfully!';
  static const String msgEventUpdated = 'Event updated successfully!';
  static const String msgEventDeleted = 'Event deleted successfully!';
  static const String msgCalendarSynced = 'Synced with Google Calendar';
  static const String msgSettingsSaved = 'Settings saved';

  // Error Messages
  static const String msgGenericError = 'Something went wrong. Please try again.';
  static const String msgNetworkError = 'No internet connection';
  static const String msgPermissionDenied = 'Permission denied';
  static const String msgMicrophonePermissionDenied =
      'Microphone permission is required to use voice commands';
  static const String msgNoSpeechDetected = 'No speech detected. Please try again.';
  static const String msgCalendarNotConnected =
      'Google Calendar not connected. Go to Settings to connect.';

  // Onboarding
  static const List<String> onboardingTitles = [
    'Welcome to InOneGo',
    'Voice Commands',
    'Microphone Permission',
    'Connect Google Calendar',
    'Notifications',
    'You\'re All Set!',
  ];

  static const List<String> onboardingDescriptions = [
    'Create calendar events instantly with your voice',
    'Just speak naturally: "Meeting with John tomorrow at 3 PM"',
    'We need microphone access to hear your voice commands',
    'Connect your Google Calendar to sync events automatically',
    'Get notified about your events via email or Messenger',
    'Start creating events with your voice!',
  ];

  // Example Voice Commands
  static const List<String> exampleVoiceCommands = [
    'Spotkanie z Janem jutro o 15:00',
    'Przypomnij mi o dentyscie w przyszły wtorek',
    'Lunch z zespołem w piątek w południe',
    'Prezentacja projektu pojutrze o 10',
  ];

  // URLs
  static const String privacyPolicyUrl = 'https://inonego.app/privacy';
  static const String termsOfServiceUrl = 'https://inonego.app/terms';
  static const String supportEmail = 'support@inonego.app';
}
