import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// Events Table
class Events extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().nullable()();
  DateTimeColumn get startDateTime => dateTime()();
  DateTimeColumn get endDateTime => dateTime().nullable()();
  TextColumn get location => text().nullable()();
  TextColumn get attendees => text().nullable()(); // JSON string array
  TextColumn get eventType => text().withLength(min: 1, max: 50)(); // meeting|appointment|reminder|task
  TextColumn get priority => text().withLength(min: 1, max: 20)(); // low|medium|high|urgent
  BoolColumn get isAllDay => boolean().withDefault(const Constant(false))();
  TextColumn get googleCalendarEventId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

// UserSettings Table
class UserSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  BoolColumn get enableLocalStorage => boolean().withDefault(const Constant(true))();
  BoolColumn get enableEmailNotifications => boolean().withDefault(const Constant(false))();
  BoolColumn get enableMessengerNotifications => boolean().withDefault(const Constant(false))();
  BoolColumn get isGoogleCalendarConnected => boolean().withDefault(const Constant(false))();
  BoolColumn get isFacebookConnected => boolean().withDefault(const Constant(false))();
  TextColumn get googleAccountEmail => text().nullable()();
  TextColumn get facebookUserId => text().nullable()();
  BoolColumn get hasCompletedOnboarding => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// Database Class
@DriftDatabase(tables: [Events, UserSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Future migrations will go here
      },
    );
  }

  // ========== EVENTS OPERATIONS ==========

  // Get all events
  Future<List<Event>> getAllEvents() => select(events).get();

  // Get event by ID
  Future<Event?> getEventById(int id) =>
      (select(events)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  // Get events by date range
  Future<List<Event>> getEventsByDateRange(DateTime start, DateTime end) {
    return (select(events)
          ..where((tbl) =>
              tbl.startDateTime.isBiggerOrEqualValue(start) &
              tbl.startDateTime.isSmallerOrEqualValue(end))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.startDateTime)]))
        .get();
  }

  // Get today's events
  Future<List<Event>> getTodayEvents() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return getEventsByDateRange(startOfDay, endOfDay);
  }

  // Get upcoming events
  Future<List<Event>> getUpcomingEvents({int limit = 10}) {
    return (select(events)
          ..where((tbl) => tbl.startDateTime.isBiggerOrEqualValue(DateTime.now()))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.startDateTime)])
          ..limit(limit))
        .get();
  }

  // Get unsynced events
  Future<List<Event>> getUnsyncedEvents() =>
      (select(events)..where((tbl) => tbl.isSynced.equals(false))).get();

  // Insert event
  Future<int> insertEvent(EventsCompanion event) =>
      into(events).insert(event);

  // Update event
  Future<bool> updateEvent(Event event) => update(events).replace(event);

  // Delete event
  Future<int> deleteEvent(int id) =>
      (delete(events)..where((tbl) => tbl.id.equals(id))).go();

  // Delete all events
  Future<int> deleteAllEvents() => delete(events).go();

  // Mark event as synced
  Future<int> markEventAsSynced(int id, String googleCalendarEventId) {
    return (update(events)..where((tbl) => tbl.id.equals(id))).write(
      EventsCompanion(
        googleCalendarEventId: Value(googleCalendarEventId),
        isSynced: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // Watch all events (reactive stream)
  Stream<List<Event>> watchAllEvents() => select(events).watch();

  // Watch today's events
  Stream<List<Event>> watchTodayEvents() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return (select(events)
          ..where((tbl) =>
              tbl.startDateTime.isBiggerOrEqualValue(startOfDay) &
              tbl.startDateTime.isSmallerOrEqualValue(endOfDay))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.startDateTime)]))
        .watch();
  }

  // ========== USER SETTINGS OPERATIONS ==========

  // Get user settings (there should only be one record)
  Future<UserSetting?> getUserSettings() =>
      select(userSettings).getSingleOrNull();

  // Initialize default settings
  Future<int> initializeSettings() {
    return into(userSettings).insert(
      UserSettingsCompanion.insert(),
    );
  }

  // Update settings
  Future<bool> updateSettings(UserSetting setting) =>
      update(userSettings).replace(setting);

  // Update specific setting fields
  Future<int> updateSettingsFields({
    bool? enableLocalStorage,
    bool? enableEmailNotifications,
    bool? enableMessengerNotifications,
    bool? isGoogleCalendarConnected,
    bool? isFacebookConnected,
    String? googleAccountEmail,
    String? facebookUserId,
    bool? hasCompletedOnboarding,
  }) {
    return (update(userSettings)..where((tbl) => tbl.id.equals(1))).write(
      UserSettingsCompanion(
        enableLocalStorage: enableLocalStorage != null
            ? Value(enableLocalStorage)
            : const Value.absent(),
        enableEmailNotifications: enableEmailNotifications != null
            ? Value(enableEmailNotifications)
            : const Value.absent(),
        enableMessengerNotifications: enableMessengerNotifications != null
            ? Value(enableMessengerNotifications)
            : const Value.absent(),
        isGoogleCalendarConnected: isGoogleCalendarConnected != null
            ? Value(isGoogleCalendarConnected)
            : const Value.absent(),
        isFacebookConnected: isFacebookConnected != null
            ? Value(isFacebookConnected)
            : const Value.absent(),
        googleAccountEmail: googleAccountEmail != null
            ? Value(googleAccountEmail)
            : const Value.absent(),
        facebookUserId:
            facebookUserId != null ? Value(facebookUserId) : const Value.absent(),
        hasCompletedOnboarding: hasCompletedOnboarding != null
            ? Value(hasCompletedOnboarding)
            : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // Mark onboarding as completed
  Future<int> markOnboardingCompleted() {
    return updateSettingsFields(hasCompletedOnboarding: true);
  }

  // Connect Google Calendar
  Future<int> connectGoogleCalendar(String email) {
    return updateSettingsFields(
      isGoogleCalendarConnected: true,
      googleAccountEmail: email,
    );
  }

  // Disconnect Google Calendar
  Future<int> disconnectGoogleCalendar() {
    return updateSettingsFields(
      isGoogleCalendarConnected: false,
      googleAccountEmail: null,
    );
  }

  // Watch user settings
  Stream<UserSetting?> watchUserSettings() =>
      select(userSettings).watchSingleOrNull();
}

// Connection helper
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'inonego.db'));
    return NativeDatabase.createInBackground(file);
  });
}
