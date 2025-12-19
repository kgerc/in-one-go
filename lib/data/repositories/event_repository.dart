import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/repositories/i_event_repository.dart';
import '../data_sources/local/app_database.dart';
import '../data_sources/remote/google_calendar_service.dart';
import '../models/event_model.dart';

class EventRepository implements IEventRepository {
  final AppDatabase database;
  final GoogleCalendarService calendarService;

  EventRepository({
    required this.database,
    required this.calendarService,
  });

  @override
  Future<Either<Failure, List<EventEntity>>> getAllEvents() async {
    try {
      final events = await database.getAllEvents();
      return Right(events.toEntities());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Failed to get events: $e'));
    }
  }

  @override
  Future<Either<Failure, EventEntity>> getEventById(int id) async {
    try {
      final event = await database.getEventById(id);
      if (event == null) {
        return const Left(CacheFailure(message: 'Event not found'));
      }
      return Right(event.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Failed to get event: $e'));
    }
  }

  @override
  Future<Either<Failure, List<EventEntity>>> getEventsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final events = await database.getEventsByDateRange(start, end);
      return Right(events.toEntities());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Failed to get events: $e'));
    }
  }

  @override
  Future<Either<Failure, List<EventEntity>>> getTodayEvents() async {
    try {
      final events = await database.getTodayEvents();
      return Right(events.toEntities());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Failed to get today\'s events: $e'));
    }
  }

  @override
  Future<Either<Failure, List<EventEntity>>> getUpcomingEvents({
    int limit = 10,
  }) async {
    try {
      final events = await database.getUpcomingEvents(limit: limit);
      return Right(events.toEntities());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Failed to get upcoming events: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> saveEvent(EventEntity event) async {
    try {
      final eventId = await database.insertEvent(event.toCompanion());
      return Right(eventId);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Failed to save event: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateEvent(EventEntity event) async {
    try {
      await database.updateEvent(event.toModel());
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Failed to update event: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEvent(int id) async {
    try {
      await database.deleteEvent(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Failed to delete event: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> syncEventWithCalendar(EventEntity event) async {
    try {
      if (!calendarService.isSignedIn) {
        return const Left(
          AuthenticationFailure(
            message: 'Not signed in to Google Calendar',
          ),
        );
      }

      String calendarEventId;
      if (event.googleCalendarEventId != null) {
        // Update existing event
        await calendarService.updateEvent(
          event.googleCalendarEventId!,
          event,
        );
        calendarEventId = event.googleCalendarEventId!;
      } else {
        // Create new event
        calendarEventId = await calendarService.addEvent(event);
      }

      // Mark as synced in local database
      if (event.id != null) {
        await database.markEventAsSynced(event.id!, calendarEventId);
      }

      return const Right(null);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Failed to sync event: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<EventEntity>>> watchAllEvents() {
    try {
      return database.watchAllEvents().map(
            (events) => Right<Failure, List<EventEntity>>(events.toEntities()),
          );
    } catch (e) {
      return Stream.value(
        Left(UnexpectedFailure(message: 'Failed to watch events: $e')),
      );
    }
  }

  @override
  Stream<Either<Failure, List<EventEntity>>> watchTodayEvents() {
    try {
      return database.watchTodayEvents().map(
            (events) => Right<Failure, List<EventEntity>>(events.toEntities()),
          );
    } catch (e) {
      return Stream.value(
        Left(UnexpectedFailure(message: 'Failed to watch today\'s events: $e')),
      );
    }
  }
}
