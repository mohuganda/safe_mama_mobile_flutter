import 'package:dio/dio.dart';
import 'package:safe_mama/api/config/env_config.dart';
import 'package:safe_mama/api/controllers/api_client.dart';
import 'package:safe_mama/api/models/data_state.dart';
import 'package:safe_mama/api/models/responses/UtilityResponse.dart';
import 'package:safe_mama/injection_container.dart';
import 'package:safe_mama/repository/api_client_repository.dart';
import 'package:safe_mama/utils/helpers.dart';

abstract class CommunitiesRepository {
  Future<DataState<CommunityResponse>> fetchCommunities({
    String? term,
    int? page,
    int? pageSize,
  });
  Future<DataState<dynamic>> joinCommunity(int communityId, int userId);
  Future<DataState<dynamic>> leaveCommunity(int communityId, int userId);
}

class CommunitiesRepositoryImpl implements CommunitiesRepository {
  final ApiClientRepository apiClientRepository;

  CommunitiesRepositoryImpl({required this.apiClientRepository});

  APIClient _apiClient() {
    return apiClientRepository.buildClient();
  }

  @override
  Future<DataState<CommunityResponse>> fetchCommunities({
    String? term,
    int? page,
    int? pageSize,
  }) async {
    try {
      Map<String, dynamic> request = {
        'page': page ?? EnvConfig.startPage,
        'page_size': pageSize ?? EnvConfig.pageSize
      };
      if (term != null) request['term'] = term;

      final response = await _apiClient().fetchCommunityList(request);
      return DataSuccess(response);
    } on DioException catch (err) {
      LOGGER.e(err);
      return DataError(Helpers.resolveError(err));
    }
  }

  @override
  Future<DataState<dynamic>> joinCommunity(int communityId, int userId) async {
    try {
      Map<String, dynamic> request = {
        'user_id': userId,
      };
      final response = await _apiClient().joinCommunity(communityId, request);
      return DataSuccess(response);
    } on DioException catch (err) {
      LOGGER.e(err);
      return DataError(Helpers.resolveError(err));
    }
  }

  @override
  Future<DataState<dynamic>> leaveCommunity(int communityId, int userId) async {
    try {
      final response = await _apiClient().leaveCommunity(communityId, userId);
      return DataSuccess(response);
    } on DioException catch (err) {
      LOGGER.e(err);
      return DataError(Helpers.resolveError(err));
    }
  }
}