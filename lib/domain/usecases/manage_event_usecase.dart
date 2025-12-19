import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/event_entity.dart';
import '../repositories/i_event_repository.dart';

class ManageEventUseCase {
  final IEventRepository repository;

  ManageEventUseCase({required this.repository});

  Future<Either<Failure, int>> saveEvent(EventEntity event) {
    return repository.saveEvent(event);
  }

  Future<Either<Failure, void>> updateEvent(EventEntity event) {
    return repository.updateEvent(event);
  }

  Future<Either<Failure, void>> deleteEvent(int id) {
    return repository.deleteEvent(id);
  }

  Future<Either<Failure, EventEntity>> getEventById(int id) {
    return repository.getEventById(id);
  }

  Future<Either<Failure, void>> syncEventWithCalendar(EventEntity event) {
    return repository.syncEventWithCalendar(event);
  }
}
