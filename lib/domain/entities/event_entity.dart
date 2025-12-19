import 'package:equatable/equatable.dart';

class EventEntity extends Equatable {
  final int? id;
  final String title;
  final String? description;
  final DateTime startDateTime;
  final DateTime? endDateTime;
  final String? location;
  final List<String> attendees;
  final EventType eventType;
  final EventPriority priority;
  final bool isAllDay;
  final String? googleCalendarEventId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;

  const EventEntity({
    this.id,
    required this.title,
    this.description,
    required this.startDateTime,
    this.endDateTime,
    this.location,
    this.attendees = const [],
    this.eventType = EventType.meeting,
    this.priority = EventPriority.medium,
    this.isAllDay = false,
    this.googleCalendarEventId,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        startDateTime,
        endDateTime,
        location,
        attendees,
        eventType,
        priority,
        isAllDay,
        googleCalendarEventId,
        createdAt,
        updatedAt,
        isSynced,
      ];

  EventEntity copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? startDateTime,
    DateTime? endDateTime,
    String? location,
    List<String>? attendees,
    EventType? eventType,
    EventPriority? priority,
    bool? isAllDay,
    String? googleCalendarEventId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return EventEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      location: location ?? this.location,
      attendees: attendees ?? this.attendees,
      eventType: eventType ?? this.eventType,
      priority: priority ?? this.priority,
      isAllDay: isAllDay ?? this.isAllDay,
      googleCalendarEventId: googleCalendarEventId ?? this.googleCalendarEventId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  // Duration helper
  Duration? get duration {
    if (endDateTime == null) return null;
    return endDateTime!.difference(startDateTime);
  }

  // Check if event is in the past
  bool get isPast => startDateTime.isBefore(DateTime.now());

  // Check if event is today
  bool get isToday {
    final now = DateTime.now();
    final eventDate = startDateTime;
    return eventDate.year == now.year &&
        eventDate.month == now.month &&
        eventDate.day == now.day;
  }

  // Check if event is upcoming (future)
  bool get isUpcoming => startDateTime.isAfter(DateTime.now());
}

enum EventType {
  meeting,
  appointment,
  reminder,
  task;

  String get displayName {
    switch (this) {
      case EventType.meeting:
        return 'Meeting';
      case EventType.appointment:
        return 'Appointment';
      case EventType.reminder:
        return 'Reminder';
      case EventType.task:
        return 'Task';
    }
  }

  static EventType fromString(String value) {
    return EventType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => EventType.meeting,
    );
  }
}

enum EventPriority {
  low,
  medium,
  high,
  urgent;

  String get displayName {
    switch (this) {
      case EventPriority.low:
        return 'Low';
      case EventPriority.medium:
        return 'Medium';
      case EventPriority.high:
        return 'High';
      case EventPriority.urgent:
        return 'Urgent';
    }
  }

  static EventPriority fromString(String value) {
    return EventPriority.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => EventPriority.medium,
    );
  }
}
