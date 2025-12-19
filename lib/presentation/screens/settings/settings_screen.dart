import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../injection_container.dart';
import '../../blocs/settings/settings_bloc.dart';
import '../../blocs/settings/settings_event.dart';
import '../../blocs/settings/settings_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SettingsBloc>()..add(const LoadSettingsEvent()),
      child: const SettingsView(),
    );
  }
}

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is SettingsGoogleSignedIn) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Connected as ${state.email}'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is SettingsGoogleSignedOut) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Disconnected from Google Calendar'),
              ),
            );
          } else if (state is SettingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SettingsLoading ||
              state is SettingsGoogleSignInInProgress ||
              state is SettingsGoogleSignOutInProgress) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SettingsLoaded) {
            final settings = state.settings;

            return ListView(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              children: [
                // Google Calendar Section
                _buildSectionTitle(context, 'Google Calendar'),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.calendar_today,
                          color: AppColors.primary,
                        ),
                        title: const Text('Google Calendar'),
                        subtitle: Text(
                          settings.isGoogleCalendarConnected
                              ? 'Connected as ${settings.googleAccountEmail}'
                              : 'Not connected',
                        ),
                        trailing: settings.isGoogleCalendarConnected
                            ? const Icon(
                                Icons.check_circle,
                                color: AppColors.success,
                              )
                            : null,
                      ),
                      if (!settings.isGoogleCalendarConnected)
                        Padding(
                          padding: const EdgeInsets.all(AppConstants.spacingMd),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                context.read<SettingsBloc>().add(
                                      const SignInToGoogleCalendarEvent(),
                                    );
                              },
                              icon: const Icon(Icons.login),
                              label: const Text('Connect'),
                            ),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.all(AppConstants.spacingMd),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                _showDisconnectDialog(context);
                              },
                              icon: const Icon(Icons.logout),
                              label: const Text('Disconnect'),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.spacingLg),

                // Storage Section
                _buildSectionTitle(context, 'Storage'),
                Card(
                  child: SwitchListTile(
                    secondary: const Icon(Icons.storage),
                    title: const Text('Local Storage'),
                    subtitle: const Text('Save events to device'),
                    value: settings.enableLocalStorage,
                    onChanged: (value) {
                      context.read<SettingsBloc>().add(
                            ToggleLocalStorageEvent(enabled: value),
                          );
                    },
                  ),
                ),
                const SizedBox(height: AppConstants.spacingLg),

                // Notifications Section
                _buildSectionTitle(context, 'Notifications'),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        secondary: const Icon(Icons.email),
                        title: const Text('Email Notifications'),
                        subtitle: const Text('Get notified via email'),
                        value: settings.enableEmailNotifications,
                        onChanged: (value) {
                          context.read<SettingsBloc>().add(
                                ToggleEmailNotificationsEvent(enabled: value),
                              );
                        },
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        secondary: const Icon(Icons.messenger),
                        title: const Text('Messenger Notifications'),
                        subtitle: const Text('Get notified via Messenger'),
                        value: settings.enableMessengerNotifications,
                        onChanged: (value) {
                          context.read<SettingsBloc>().add(
                                ToggleMessengerNotificationsEvent(
                                  enabled: value,
                                ),
                              );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.spacingLg),

                // About Section
                _buildSectionTitle(context, 'About'),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.info),
                        title: const Text('Version'),
                        subtitle: Text(AppConstants.appVersion),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.privacy_tip),
                        title: const Text('Privacy Policy'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Open privacy policy
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.description),
                        title: const Text('Terms of Service'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Open terms of service
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppConstants.spacingSm,
        bottom: AppConstants.spacingSm,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  void _showDisconnectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Disconnect Google Calendar?'),
        content: const Text(
          'Events will no longer sync with your Google Calendar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context
                  .read<SettingsBloc>()
                  .add(const SignOutFromGoogleCalendarEvent());
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
  }
}
