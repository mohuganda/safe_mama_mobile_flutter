import 'package:flutter/material.dart';
import 'package:safe_mama/api/models/data_state.dart';
import 'package:safe_mama/api/models/responses/EventResponse.dart';
import 'package:safe_mama/cache/events_datasource.dart';
import 'package:safe_mama/injection_container.dart';
import 'package:safe_mama/models/event_model.dart';
import 'package:safe_mama/repository/connection_repository.dart';
import 'package:safe_mama/repository/event_repository.dart';

class EventsState {
  bool isSuccess = false;
  String errorMessage = '';
  List<EventModel> _events = [];

  EventsState();
  EventsState.success(this.isSuccess, this._events);
  EventsState.error(this.isSuccess, this.errorMessage);

  List<EventModel> get events => _events;
}

class EventsViewModel extends ChangeNotifier {
  final EventRepository eventRepository;
  final EventsDatasource eventsDatasource;
  final ConnectionRepository connectionRepository;
  final EventsState state = EventsState();

  EventsViewModel(
      {required this.eventRepository,
      required this.eventsDatasource,
      required this.connectionRepository});

  Future<EventsState> getEvents() async {
    final isConnected = await connectionRepository.checkInternetStatus();

    if (!isConnected) {
      final cached = await getEventsFromCache();
      return EventsState.success(true, cached);
    }

    return await _getRemoteEvents();
  }

  Future<List<EventModel>> getEventsFromCache() async {
    final events = await eventsDatasource.getEvents();
    return events;
  }

  Future<void> clearEventsFromCache() async {
    await eventsDatasource.clearEvents();
  }

  Future<void> saveEventsToCache(List<EventModel> events) async {
    await eventsDatasource.saveEvents(events);
  }

  Future<DataState<EventResponse>> _fetchRemoteEvents() async {
    final result = await eventRepository.getEvents();
    if (result is DataSuccess) {
      final list = result.data?.data
              ?.map((item) => EventModel.fromApiModel(item))
              .toList() ??
          [];
      await clearEventsFromCache(); // Clear existing
      saveEventsToCache(list); // Save new events
    }
    return result;
  }

  Future<EventsState> _getRemoteEvents() async {
    final cached = await getEventsFromCache();
    if (cached.isNotEmpty) {
      LOGGER.d('Connected but getting from the cache');
      _fetchRemoteEvents(); // Fetch remote to update cache
      return EventsState.success(true, cached);
    }

    LOGGER.d('Connected and getting from the remote');
    final result = await _fetchRemoteEvents();

    if (result is DataSuccess) {
      final list = result.data?.data
              ?.map((item) => EventModel.fromApiModel(item))
              .toList() ??
          [];
      return EventsState.success(true, list);
    }

    if (result is DataError) {
      return EventsState.error(false, result.error ?? 'Error occurred');
    }

    return EventsState();
  }
}
