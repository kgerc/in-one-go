import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/event_entity.dart';

abstract class IEventRepository {
  /// Get all events from local database
  Future<Either<Failure, List<EventEntity>>> getAllEvents();

  /// Get event by ID
  Future<Either<Failure, EventEntity>> getEventById(int id);

  /// Get events by date range
  Future<Either<Failure, List<EventEntity>>> getEventsByDateRange(
    DateTime start,
    DateTime end,
  );

  /// Get today's events
  Future<Either<Failure, List<EventEntity>>> getTodayEvents();

  /// Get upcoming events
  Future<Either<Failure, List<EventEntity>>> getUpcomingEvents({int limit = 10});

  /// Save event locally
  Future<Either<Failure, int>> saveEvent(EventEntity event);

  /// Update event
  Future<Either<Failure, void>> updateEvent(EventEntity event);

  /// Delete event
  Future<Either<Failure, void>> deleteEvent(int id);

  /// Sync event with Google Calendar
  Future<Either<Failure, void>> syncEventWithCalendar(EventEntity event);

  /// Watch all events (stream)
  Stream<Either<Failure, List<EventEntity>>> watchAllEvents();

  /// Watch today's events (stream)
  Stream<Either<Failure, List<EventEntity>>> watchTodayEvents();
}
