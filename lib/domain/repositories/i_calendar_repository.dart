import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/event_entity.dart';

abstract class ICalendarRepository {
  /// Check if user is signed in to Google Calendar
  bool get isSignedIn;

  /// Get current user email
  String? get currentUserEmail;

  /// Initialize Google Calendar service
  Future<Either<Failure, void>> initialize();

  /// Sign in with Google
  Future<Either<Failure, String>> signIn();

  /// Sign out from Google
  Future<Either<Failure, void>> signOut();

  /// Add event to Google Calendar
  Future<Either<Failure, String>> addEventToCalendar(EventEntity event);

  /// Update event in Google Calendar
  Future<Either<Failure, void>> updateEventInCalendar(
    String eventId,
    EventEntity event,
  );

  /// Delete event from Google Calendar
  Future<Either<Failure, void>> deleteEventFromCalendar(String eventId);

  /// Sync local events with Google Calendar
  Future<Either<Failure, List<String>>> syncEvents(List<EventEntity> events);
}
