import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../injection_container.dart';
import '../../blocs/events/events_bloc.dart';
import '../../blocs/events/events_event.dart';
import '../../blocs/events/events_state.dart';

class EventsListScreen extends StatelessWidget {
  const EventsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<EventsBloc>()..add(const LoadUpcomingEventsEvent()),
      child: const EventsListView(),
    );
  }
}

class EventsListView extends StatelessWidget {
  const EventsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<EventsBloc>().add(const RefreshEventsEvent());
            },
          ),
        ],
      ),
      body: BlocBuilder<EventsBloc, EventsState>(
        builder: (context, state) {
          if (state is EventsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is EventsEmpty) {
            return _buildEmptyView(context);
          } else if (state is EventsLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<EventsBloc>().add(const RefreshEventsEvent());
                await Future.delayed(const Duration(seconds: 1));
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(AppConstants.spacingMd),
                itemCount: state.events.length,
                itemBuilder: (context, index) {
                  final event = state.events[index];
                  return Dismissible(
                    key: Key(event.id.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(
                        right: AppConstants.spacingLg,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMd),
                      ),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    onDismissed: (direction) {
                      if (event.id != null) {
                        context
                            .read<EventsBloc>()
                            .add(DeleteEventEvent(eventId: event.id!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Event deleted'),
                          ),
                        );
                      }
                    },
                    child: Card(
                      margin: const EdgeInsets.only(
                        bottom: AppConstants.spacingMd,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getEventTypeColor(event.eventType),
                          child: Icon(
                            _getEventTypeIcon(event.eventType),
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          event.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: AppConstants.spacingXs),
                            Text(
                              DateFormat('EEE, MMM d - HH:mm')
                                  .format(event.startDateTime),
                            ),
                            if (event.location != null) ...[
                              const SizedBox(height: AppConstants.spacingXs),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: AppColors.textTertiary,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      event.location!,
                                      style: const TextStyle(
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                        trailing: event.isSynced
                            ? const Icon(
                                Icons.cloud_done,
                                color: AppColors.success,
                              )
                            : const Icon(
                                Icons.cloud_off,
                                color: AppColors.textTertiary,
                              ),
                      ),
                    ),
                  );
                },
              ),
            );
          } else if (state is EventsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.spacingLg),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<EventsBloc>()
                          .add(const LoadUpcomingEventsEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.event_available,
            size: 100,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppConstants.spacingLg),
          Text(
            'No events yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: AppConstants.spacingSm),
          const Text(
            'Create your first event using voice commands',
            style: TextStyle(color: AppColors.textTertiary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getEventTypeColor(dynamic eventType) {
    final typeName = eventType.toString().split('.').last;
    switch (typeName) {
      case 'meeting':
        return AppColors.eventMeeting;
      case 'appointment':
        return AppColors.eventAppointment;
      case 'reminder':
        return AppColors.eventReminder;
      case 'task':
        return AppColors.eventTask;
      default:
        return AppColors.primary;
    }
  }

  IconData _getEventTypeIcon(dynamic eventType) {
    final typeName = eventType.toString().split('.').last;
    switch (typeName) {
      case 'meeting':
        return Icons.group;
      case 'appointment':
        return Icons.event;
      case 'reminder':
        return Icons.notifications;
      case 'task':
        return Icons.task_alt;
      default:
        return Icons.event;
    }
  }
}
