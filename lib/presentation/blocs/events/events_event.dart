import 'package:equatable/equatable.dart';

abstract class EventsEvent extends Equatable {
  const EventsEvent();

  @override
  List<Object?> get props => [];
}

/// Load all events
class LoadAllEventsEvent extends EventsEvent {
  const LoadAllEventsEvent();
}

/// Load today's events
class LoadTodayEventsEvent extends EventsEvent {
  const LoadTodayEventsEvent();
}

/// Load upcoming events
class LoadUpcomingEventsEvent extends EventsEvent {
  final int limit;

  const LoadUpcomingEventsEvent({this.limit = 10});

  @override
  List<Object?> get props => [limit];
}

/// Load events by date range
class LoadEventsByDateRangeEvent extends EventsEvent {
  final DateTime startDate;
  final DateTime endDate;

  const LoadEventsByDateRangeEvent({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

/// Delete event
class DeleteEventEvent extends EventsEvent {
  final int eventId;

  const DeleteEventEvent({required this.eventId});

  @override
  List<Object?> get props => [eventId];
}

/// Refresh events (pull to refresh)
class RefreshEventsEvent extends EventsEvent {
  const RefreshEventsEvent();
}
