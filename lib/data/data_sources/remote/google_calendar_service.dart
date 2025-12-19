import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import '../../../core/errors/exceptions.dart';
import '../../../domain/entities/event_entity.dart';

class GoogleCalendarService {
  final GoogleSignIn _googleSignIn;
  calendar.CalendarApi? _calendarApi;
  GoogleSignInAccount? _currentUser;

  GoogleCalendarService({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: [
                'email',
                calendar.CalendarApi.calendarScope,
              ],
            );

  /// Check if user is currently signed in
  bool get isSignedIn => _currentUser != null;

  /// Get current user email
  String? get currentUserEmail => _currentUser?.email;

  /// Initialize and check for existing sign-in
  Future<void> initialize() async {
    try {
      _currentUser = await _googleSignIn.signInSilently();
      if (_currentUser != null) {
        await _initializeCalendarApi();
      }
    } catch (e) {
      // Silent sign-in failed, user needs to sign in manually
      _currentUser = null;
    }
  }

  /// Sign in with Google
  Future<GoogleSignInAccount> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        throw const AuthenticationException(
          message: 'Google Sign-In was cancelled by user',
        );
      }

      _currentUser = account;
      await _initializeCalendarApi();
      return account;
    } catch (e) {
      throw AuthenticationException(
        message: 'Failed to sign in with Google: $e',
      );
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _currentUser = null;
      _calendarApi = null;
    } catch (e) {
      throw AuthenticationException(
        message: 'Failed to sign out: $e',
      );
    }
  }

  /// Initialize Calendar API client
  Future<void> _initializeCalendarApi() async {
    try {
      final httpClient = await _googleSignIn.authenticatedClient();
      if (httpClient == null) {
        throw const AuthenticationException(
          message: 'Failed to get authenticated client',
        );
      }
      _calendarApi = calendar.CalendarApi(httpClient);
    } catch (e) {
      throw AuthenticationException(
        message: 'Failed to initialize Calendar API: $e',
      );
    }
  }

  /// Ensure user is authenticated and API is initialized
  void _ensureAuthenticated() {
    if (_calendarApi == null || _currentUser == null) {
      throw const AuthenticationException(
        message: 'User is not authenticated with Google Calendar',
      );
    }
  }

  /// Add event to Google Calendar
  Future<String> addEvent(EventEntity event) async {
    _ensureAuthenticated();

    try {
      final calendarEvent = _convertToCalendarEvent(event);
      final createdEvent = await _calendarApi!.events.insert(
        calendarEvent,
        'primary', // Use primary calendar
      );

      if (createdEvent.id == null) {
        throw const ServerException(
          message: 'Failed to create calendar event - no ID returned',
        );
      }

      return createdEvent.id!;
    } catch (e) {
      if (e is AuthenticationException || e is ServerException) {
        rethrow;
      }
      throw ServerException(
        message: 'Failed to add event to Google Calendar: $e',
      );
    }
  }

  /// Get upcoming events from Google Calendar
  Future<List<calendar.Event>> getUpcomingEvents({
    int maxResults = 10,
    DateTime? timeMin,
  }) async {
    _ensureAuthenticated();

    try {
      final events = await _calendarApi!.events.list(
        'primary',
        maxResults: maxResults,
        orderBy: 'startTime',
        singleEvents: true,
        timeMin: (timeMin ?? DateTime.now()).toUtc(),
      );

      return events.items ?? [];
    } catch (e) {
      if (e is AuthenticationException) {
        rethrow;
      }
      throw ServerException(
        message: 'Failed to fetch events from Google Calendar: $e',
      );
    }
  }

  /// Update event in Google Calendar
  Future<void> updateEvent(String eventId, EventEntity event) async {
    _ensureAuthenticated();

    try {
      final calendarEvent = _convertToCalendarEvent(event);
      await _calendarApi!.events.update(
        calendarEvent,
        'primary',
        eventId,
      );
    } catch (e) {
      if (e is AuthenticationException) {
        rethrow;
      }
      throw ServerException(
        message: 'Failed to update event in Google Calendar: $e',
      );
    }
  }

  /// Delete event from Google Calendar
  Future<void> deleteEvent(String eventId) async {
    _ensureAuthenticated();

    try {
      await _calendarApi!.events.delete('primary', eventId);
    } catch (e) {
      if (e is AuthenticationException) {
        rethrow;
      }
      throw ServerException(
        message: 'Failed to delete event from Google Calendar: $e',
      );
    }
  }

  /// Get event by ID from Google Calendar
  Future<calendar.Event?> getEventById(String eventId) async {
    _ensureAuthenticated();

    try {
      return await _calendarApi!.events.get('primary', eventId);
    } catch (e) {
      if (e is AuthenticationException) {
        rethrow;
      }
      return null;
    }
  }

  /// Sync local events with Google Calendar
  Future<List<String>> syncEvents(List<EventEntity> localEvents) async {
    _ensureAuthenticated();

    final syncedEventIds = <String>[];

    for (final event in localEvents) {
      try {
        if (event.googleCalendarEventId != null) {
          // Update existing event
          await updateEvent(event.googleCalendarEventId!, event);
          syncedEventIds.add(event.googleCalendarEventId!);
        } else {
          // Create new event
          final eventId = await addEvent(event);
          syncedEventIds.add(eventId);
        }
      } catch (e) {
        // Log error but continue with other events
        continue;
      }
    }

    return syncedEventIds;
  }

  /// Convert EventEntity to Google Calendar Event
  calendar.Event _convertToCalendarEvent(EventEntity event) {
    final calendarEvent = calendar.Event();

    calendarEvent.summary = event.title;
    calendarEvent.description = event.description;
    calendarEvent.location = event.location;

    // Set start time
    if (event.isAllDay) {
      calendarEvent.start = calendar.EventDateTime(
        date: calendar.Date(
          event.startDateTime.year,
          event.startDateTime.month,
          event.startDateTime.day,
        ),
      );
    } else {
      calendarEvent.start = calendar.EventDateTime(
        dateTime: event.startDateTime.toUtc(),
      );
    }

    // Set end time
    if (event.endDateTime != null) {
      if (event.isAllDay) {
        calendarEvent.end = calendar.EventDateTime(
          date: calendar.Date(
            event.endDateTime!.year,
            event.endDateTime!.month,
            event.endDateTime!.day,
          ),
        );
      } else {
        calendarEvent.end = calendar.EventDateTime(
          dateTime: event.endDateTime!.toUtc(),
        );
      }
    } else {
      // Default to 1 hour duration if no end time
      final defaultEndTime = event.startDateTime.add(const Duration(hours: 1));
      if (event.isAllDay) {
        calendarEvent.end = calendar.EventDateTime(
          date: calendar.Date(
            defaultEndTime.year,
            defaultEndTime.month,
            defaultEndTime.day,
          ),
        );
      } else {
        calendarEvent.end = calendar.EventDateTime(
          dateTime: defaultEndTime.toUtc(),
        );
      }
    }

    // Set attendees
    if (event.attendees.isNotEmpty) {
      calendarEvent.attendees = event.attendees
          .map((email) => calendar.EventAttendee()..email = email)
          .toList();
    }

    // Set color/category based on event type
    calendarEvent.colorId = _getColorIdForEventType(event.eventType);

    return calendarEvent;
  }

  /// Get Google Calendar color ID based on event type
  String _getColorIdForEventType(EventType type) {
    switch (type) {
      case EventType.meeting:
        return '9'; // Blue
      case EventType.appointment:
        return '10'; // Green
      case EventType.reminder:
        return '5'; // Yellow
      case EventType.task:
        return '11'; // Red
    }
  }

  /// Convert Google Calendar Event to EventEntity
  EventEntity convertToEventEntity(calendar.Event calendarEvent) {
    final now = DateTime.now();

    DateTime startDateTime;
    DateTime? endDateTime;
    bool isAllDay = false;

    if (calendarEvent.start?.dateTime != null) {
      startDateTime = calendarEvent.start!.dateTime!.toLocal();
    } else if (calendarEvent.start?.date != null) {
      final date = calendarEvent.start!.date!;
      startDateTime = DateTime(date.year, date.month, date.day);
      isAllDay = true;
    } else {
      startDateTime = now;
    }

    if (calendarEvent.end?.dateTime != null) {
      endDateTime = calendarEvent.end!.dateTime!.toLocal();
    } else if (calendarEvent.end?.date != null) {
      final date = calendarEvent.end!.date!;
      endDateTime = DateTime(date.year, date.month, date.day);
    }

    return EventEntity(
      title: calendarEvent.summary ?? 'Untitled Event',
      description: calendarEvent.description,
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      location: calendarEvent.location,
      attendees: calendarEvent.attendees
              ?.map((a) => a.email ?? '')
              .where((email) => email.isNotEmpty)
              .toList() ??
          [],
      eventType: EventType.meeting, // Default type from Google Calendar
      priority: EventPriority.medium,
      isAllDay: isAllDay,
      googleCalendarEventId: calendarEvent.id,
      createdAt: now,
      updatedAt: now,
      isSynced: true,
    );
  }
}
