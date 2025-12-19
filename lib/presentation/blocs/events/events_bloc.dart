import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_events_usecase.dart';
import '../../../domain/usecases/manage_event_usecase.dart';
import 'events_event.dart';
import 'events_state.dart';

class EventsBloc extends Bloc<EventsEvent, EventsState> {
  final GetEventsUseCase getEventsUseCase;
  final ManageEventUseCase manageEventUseCase;

  EventsBloc({
    required this.getEventsUseCase,
    required this.manageEventUseCase,
  }) : super(const EventsInitial()) {
    on<LoadAllEventsEvent>(_onLoadAllEvents);
    on<LoadTodayEventsEvent>(_onLoadTodayEvents);
    on<LoadUpcomingEventsEvent>(_onLoadUpcomingEvents);
    on<LoadEventsByDateRangeEvent>(_onLoadEventsByDateRange);
    on<DeleteEventEvent>(_onDeleteEvent);
    on<RefreshEventsEvent>(_onRefreshEvents);
  }

  Future<void> _onLoadAllEvents(
    LoadAllEventsEvent event,
    Emitter<EventsState> emit,
  ) async {
    emit(const EventsLoading());

    final result = await getEventsUseCase.getAllEvents();

    result.fold(
      (failure) => emit(EventsError(message: failure.message)),
      (events) {
        if (events.isEmpty) {
          emit(const EventsEmpty(currentFilter: EventsFilter.all));
        } else {
          emit(EventsLoaded(
            events: events,
            currentFilter: EventsFilter.all,
          ));
        }
      },
    );
  }

  Future<void> _onLoadTodayEvents(
    LoadTodayEventsEvent event,
    Emitter<EventsState> emit,
  ) async {
    emit(const EventsLoading());

    final result = await getEventsUseCase.getTodayEvents();

    result.fold(
      (failure) => emit(EventsError(message: failure.message)),
      (events) {
        if (events.isEmpty) {
          emit(const EventsEmpty(currentFilter: EventsFilter.today));
        } else {
          emit(EventsLoaded(
            events: events,
            currentFilter: EventsFilter.today,
          ));
        }
      },
    );
  }

  Future<void> _onLoadUpcomingEvents(
    LoadUpcomingEventsEvent event,
    Emitter<EventsState> emit,
  ) async {
    emit(const EventsLoading());

    final result = await getEventsUseCase.getUpcomingEvents(limit: event.limit);

    result.fold(
      (failure) => emit(EventsError(message: failure.message)),
      (events) {
        if (events.isEmpty) {
          emit(const EventsEmpty(currentFilter: EventsFilter.upcoming));
        } else {
          emit(EventsLoaded(
            events: events,
            currentFilter: EventsFilter.upcoming,
          ));
        }
      },
    );
  }

  Future<void> _onLoadEventsByDateRange(
    LoadEventsByDateRangeEvent event,
    Emitter<EventsState> emit,
  ) async {
    emit(const EventsLoading());

    final result = await getEventsUseCase.getEventsByDateRange(
      event.startDate,
      event.endDate,
    );

    result.fold(
      (failure) => emit(EventsError(message: failure.message)),
      (events) {
        if (events.isEmpty) {
          emit(const EventsEmpty());
        } else {
          emit(EventsLoaded(events: events));
        }
      },
    );
  }

  Future<void> _onDeleteEvent(
    DeleteEventEvent event,
    Emitter<EventsState> emit,
  ) async {
    final result = await manageEventUseCase.deleteEvent(event.eventId);

    result.fold(
      (failure) => emit(EventsError(message: failure.message)),
      (_) {
        emit(EventDeleted(eventId: event.eventId));
        // Reload events after deletion
        add(const LoadAllEventsEvent());
      },
    );
  }

  Future<void> _onRefreshEvents(
    RefreshEventsEvent event,
    Emitter<EventsState> emit,
  ) async {
    // Determine current filter and reload
    EventsFilter currentFilter = EventsFilter.all;
    if (state is EventsLoaded) {
      currentFilter = (state as EventsLoaded).currentFilter;
    } else if (state is EventsEmpty) {
      currentFilter = (state as EventsEmpty).currentFilter;
    }

    switch (currentFilter) {
      case EventsFilter.today:
        add(const LoadTodayEventsEvent());
        break;
      case EventsFilter.upcoming:
        add(const LoadUpcomingEventsEvent());
        break;
      default:
        add(const LoadAllEventsEvent());
    }
  }
}
