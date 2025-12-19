import 'dart:convert';
import 'package:drift/drift.dart';
import '../../domain/entities/event_entity.dart';
import '../data_sources/local/app_database.dart';

extension EventMapper on Event {
  // Convert Drift Event to Domain EventEntity
  EventEntity toEntity() {
    return EventEntity(
      id: id,
      title: title,
      description: description,
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      location: location,
      attendees: _parseAttendees(attendees),
      eventType: EventType.fromString(eventType),
      priority: EventPriority.fromString(priority),
      isAllDay: isAllDay,
      googleCalendarEventId: googleCalendarEventId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isSynced: isSynced,
    );
  }

  static List<String> _parseAttendees(String? attendeesJson) {
    if (attendeesJson == null || attendeesJson.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> decoded = jsonDecode(attendeesJson);
      return decoded.map((e) => e.toString()).toList();
    } catch (e) {
      return [];
    }
  }
}

extension EventEntityMapper on EventEntity {
  // Convert Domain EventEntity to Drift EventsCompanion (for insert/update)
  EventsCompanion toCompanion() {
    return EventsCompanion(
      id: id != null ? Value(id!) : const Value.absent(),
      title: Value(title),
      description: Value(description),
      startDateTime: Value(startDateTime),
      endDateTime: Value(endDateTime),
      location: Value(location),
      attendees: Value(_attendeesToJson(attendees)),
      eventType: Value(eventType.name),
      priority: Value(priority.name),
      isAllDay: Value(isAllDay),
      googleCalendarEventId: Value(googleCalendarEventId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isSynced: Value(isSynced),
    );
  }

  // Convert Domain EventEntity to Drift Event (for update/replace)
  Event toModel() {
    return Event(
      id: id ?? 0,
      title: title,
      description: description,
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      location: location,
      attendees: _attendeesToJson(attendees),
      eventType: eventType.name,
      priority: priority.name,
      isAllDay: isAllDay,
      googleCalendarEventId: googleCalendarEventId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isSynced: isSynced,
    );
  }

  static String? _attendeesToJson(List<String> attendees) {
    if (attendees.isEmpty) return null;
    return jsonEncode(attendees);
  }
}

// Helper extensions for lists
extension EventListMapper on List<Event> {
  List<EventEntity> toEntities() {
    return map((event) => event.toEntity()).toList();
  }
}

extension EventEntityListMapper on List<EventEntity> {
  List<EventsCompanion> toCompanions() {
    return map((entity) => entity.toCompanion()).toList();
  }

  List<Event> toModels() {
    return map((entity) => entity.toModel()).toList();
  }
}
