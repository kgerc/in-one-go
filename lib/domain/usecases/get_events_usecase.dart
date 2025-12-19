import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/event_entity.dart';
import '../repositories/i_event_repository.dart';

class GetEventsUseCase {
  final IEventRepository repository;

  GetEventsUseCase({required this.repository});

  Future<Either<Failure, List<EventEntity>>> getAllEvents() {
    return repository.getAllEvents();
  }

  Future<Either<Failure, List<EventEntity>>> getTodayEvents() {
    return repository.getTodayEvents();
  }

  Future<Either<Failure, List<EventEntity>>> getUpcomingEvents({
    int limit = 10,
  }) {
    return repository.getUpcomingEvents(limit: limit);
  }

  Future<Either<Failure, List<EventEntity>>> getEventsByDateRange(
    DateTime start,
    DateTime end,
  ) {
    return repository.getEventsByDateRange(start, end);
  }

  Stream<Either<Failure, List<EventEntity>>> watchAllEvents() {
    return repository.watchAllEvents();
  }

  Stream<Either<Failure, List<EventEntity>>> watchTodayEvents() {
    return repository.watchTodayEvents();
  }
}
