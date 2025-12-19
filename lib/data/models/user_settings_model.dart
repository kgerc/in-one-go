import 'package:drift/drift.dart';
import '../../domain/entities/user_settings_entity.dart';
import '../data_sources/local/app_database.dart';

extension UserSettingsMapper on UserSetting {
  // Convert Drift UserSetting to Domain UserSettingsEntity
  UserSettingsEntity toEntity() {
    return UserSettingsEntity(
      id: id,
      enableLocalStorage: enableLocalStorage,
      enableEmailNotifications: enableEmailNotifications,
      enableMessengerNotifications: enableMessengerNotifications,
      isGoogleCalendarConnected: isGoogleCalendarConnected,
      isFacebookConnected: isFacebookConnected,
      googleAccountEmail: googleAccountEmail,
      facebookUserId: facebookUserId,
      hasCompletedOnboarding: hasCompletedOnboarding,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension UserSettingsEntityMapper on UserSettingsEntity {
  // Convert Domain UserSettingsEntity to Drift UserSettingsCompanion (for insert/update)
  UserSettingsCompanion toCompanion() {
    return UserSettingsCompanion(
      id: id != null ? Value(id!) : const Value.absent(),
      enableLocalStorage: Value(enableLocalStorage),
      enableEmailNotifications: Value(enableEmailNotifications),
      enableMessengerNotifications: Value(enableMessengerNotifications),
      isGoogleCalendarConnected: Value(isGoogleCalendarConnected),
      isFacebookConnected: Value(isFacebookConnected),
      googleAccountEmail: Value(googleAccountEmail),
      facebookUserId: Value(facebookUserId),
      hasCompletedOnboarding: Value(hasCompletedOnboarding),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  // Convert Domain UserSettingsEntity to Drift UserSetting (for update/replace)
  UserSetting toModel() {
    return UserSetting(
      id: id ?? 1,
      enableLocalStorage: enableLocalStorage,
      enableEmailNotifications: enableEmailNotifications,
      enableMessengerNotifications: enableMessengerNotifications,
      isGoogleCalendarConnected: isGoogleCalendarConnected,
      isFacebookConnected: isFacebookConnected,
      googleAccountEmail: googleAccountEmail,
      facebookUserId: facebookUserId,
      hasCompletedOnboarding: hasCompletedOnboarding,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
