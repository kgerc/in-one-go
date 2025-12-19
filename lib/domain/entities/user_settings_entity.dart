import 'package:equatable/equatable.dart';

class UserSettingsEntity extends Equatable {
  final int? id;
  final bool enableLocalStorage;
  final bool enableEmailNotifications;
  final bool enableMessengerNotifications;
  final bool isGoogleCalendarConnected;
  final bool isFacebookConnected;
  final String? googleAccountEmail;
  final String? facebookUserId;
  final bool hasCompletedOnboarding;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserSettingsEntity({
    this.id,
    this.enableLocalStorage = true,
    this.enableEmailNotifications = false,
    this.enableMessengerNotifications = false,
    this.isGoogleCalendarConnected = false,
    this.isFacebookConnected = false,
    this.googleAccountEmail,
    this.facebookUserId,
    this.hasCompletedOnboarding = false,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        enableLocalStorage,
        enableEmailNotifications,
        enableMessengerNotifications,
        isGoogleCalendarConnected,
        isFacebookConnected,
        googleAccountEmail,
        facebookUserId,
        hasCompletedOnboarding,
        createdAt,
        updatedAt,
      ];

  UserSettingsEntity copyWith({
    int? id,
    bool? enableLocalStorage,
    bool? enableEmailNotifications,
    bool? enableMessengerNotifications,
    bool? isGoogleCalendarConnected,
    bool? isFacebookConnected,
    String? googleAccountEmail,
    String? facebookUserId,
    bool? hasCompletedOnboarding,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSettingsEntity(
      id: id ?? this.id,
      enableLocalStorage: enableLocalStorage ?? this.enableLocalStorage,
      enableEmailNotifications:
          enableEmailNotifications ?? this.enableEmailNotifications,
      enableMessengerNotifications:
          enableMessengerNotifications ?? this.enableMessengerNotifications,
      isGoogleCalendarConnected:
          isGoogleCalendarConnected ?? this.isGoogleCalendarConnected,
      isFacebookConnected: isFacebookConnected ?? this.isFacebookConnected,
      googleAccountEmail: googleAccountEmail ?? this.googleAccountEmail,
      facebookUserId: facebookUserId ?? this.facebookUserId,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper: Check if any notification is enabled
  bool get hasNotificationsEnabled =>
      enableEmailNotifications || enableMessengerNotifications;

  // Helper: Check if any external service is connected
  bool get hasExternalServicesConnected =>
      isGoogleCalendarConnected || isFacebookConnected;
}
