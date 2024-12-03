import 'package:dio/dio.dart';
import 'package:safe_mama/api/controllers/api_client.dart';
import 'package:safe_mama/api/models/data_state.dart';
import 'package:safe_mama/api/models/responses/EventResponse.dart';
import 'package:safe_mama/repository/api_client_repository.dart';
import 'package:safe_mama/utils/helpers.dart';

abstract class EventRepository {
  Future<DataState<EventResponse>> getEvents();
}

class EventRepositoryImpl implements EventRepository {
  final ApiClientRepository apiClientRepository;

  EventRepositoryImpl({required this.apiClientRepository});

  APIClient _apiClient() {
    return apiClientRepository.buildClient();
  }

  @override
  Future<DataState<EventResponse>> getEvents() async {
    try {
      final Map<String, dynamic> queries = {};
      final response = await _apiClient().getEvents(queries);
      return DataSuccess(response);
    } on DioException catch (e) {
      return DataError(Helpers.resolveError(e));
    }
  }
}
