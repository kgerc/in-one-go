import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/repositories/i_calendar_repository.dart';
import '../data_sources/remote/google_calendar_service.dart';

class CalendarRepository implements ICalendarRepository {
  final GoogleCalendarService calendarService;

  CalendarRepository({required this.calendarService});

  @override
  bool get isSignedIn => calendarService.isSignedIn;

  @override
  String? get currentUserEmail => calendarService.currentUserEmail;

  @override
  Future<Either<Failure, void>> initialize() async {
    try {
      await calendarService.initialize();
      return const Right(null);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } catch (e) {
      return Left(
        UnexpectedFailure(message: 'Failed to initialize calendar: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, String>> signIn() async {
    try {
      final account = await calendarService.signIn();
      return Right(account.email);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Failed to sign in: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await calendarService.signOut();
      return const Right(null);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Failed to sign out: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> addEventToCalendar(EventEntity event) async {
    try {
      final eventId = await calendarService.addEvent(event);
      return Right(eventId);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
        UnexpectedFailure(message: 'Failed to add event to calendar: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateEventInCalendar(
    String eventId,
    EventEntity event,
  ) async {
    try {
      await calendarService.updateEvent(eventId, event);
      return const Right(null);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
        UnexpectedFailure(message: 'Failed to update event in calendar: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteEventFromCalendar(String eventId) async {
    try {
      await calendarService.deleteEvent(eventId);
      return const Right(null);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
        UnexpectedFailure(message: 'Failed to delete event from calendar: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<String>>> syncEvents(
    List<EventEntity> events,
  ) async {
    try {
      final syncedIds = await calendarService.syncEvents(events);
      return Right(syncedIds);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Failed to sync events: $e'));
    }
  }
}
