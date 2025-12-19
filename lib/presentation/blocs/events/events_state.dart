import 'package:equatable/equatable.dart';
import '../../../domain/entities/event_entity.dart';

abstract class EventsState extends Equatable {
  const EventsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class EventsInitial extends EventsState {
  const EventsInitial();
}

/// Loading events
class EventsLoading extends EventsState {
  const EventsLoading();
}

/// Events loaded successfully
class EventsLoaded extends EventsState {
  final List<EventEntity> events;
  final EventsFilter currentFilter;

  const EventsLoaded({
    required this.events,
    this.currentFilter = EventsFilter.all,
  });

  @override
  List<Object?> get props => [events, currentFilter];
}

/// Events empty
class EventsEmpty extends EventsState {
  final EventsFilter currentFilter;

  const EventsEmpty({this.currentFilter = EventsFilter.all});

  @override
  List<Object?> get props => [currentFilter];
}

/// Error loading events
class EventsError extends EventsState {
  final String message;

  const EventsError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Event deleted successfully
class EventDeleted extends EventsState {
  final int eventId;

  const EventDeleted({required this.eventId});

  @override
  List<Object?> get props => [eventId];
}

/// Filter enum for events
enum EventsFilter {
  all,
  today,
  upcoming,
  thisWeek,
  thisMonth,
}
