import 'package:flutter/material.dart';
import 'package:safe_mama/api/config/env_config.dart';
import 'package:safe_mama/api/models/data_state.dart';
import 'package:safe_mama/injection_container.dart';
import 'package:safe_mama/repository/connection_repository.dart';
import 'package:safe_mama/repository/forum_repository.dart';
import 'package:safe_mama/models/forum_model.dart';
import 'package:safe_mama/ui/providers/safe_notifier.dart';

class ForumState {
  bool _loading = false;
  // final bool _isSuccess = false;
  String _errorMessage = '';
  int _errorType = 2;
  List<ForumModel> _forums = [];
  int _currentPage = EnvConfig.startPage;
  int _totalPages = 1;
  bool _isEndOfPage = false;
  bool _isRefreshing = false;

  bool get loading => _loading;
  String get errorMessage => _errorMessage;
  int get errorType => _errorType;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  List<ForumModel> get forums => _forums;
  bool get isRefreshing => _isRefreshing;
}

class ForumsViewModel extends ChangeNotifier with SafeNotifier {
  ForumState state = ForumState();
  ForumState get getState => state;

  late final ForumRepository forumRepository;
  late final ConnectionRepository connectionRepository;

  ForumsViewModel(this.forumRepository, this.connectionRepository);

  void refresh() {
    state._isRefreshing = true;
    safeNotifyListeners();
  }

  Future<void> fetchForums({int page = EnvConfig.startPage}) async {
    state._loading = true;
    state._forums = []; // reset
    state._currentPage = EnvConfig.startPage; // reset
    state._isEndOfPage = false; // reset
    safeNotifyListeners();

    try {
      final isConnected = await connectionRepository.checkInternetStatus();
      state._errorMessage = isConnected ? '' : 'No internet connection';
      if (!isConnected) {
        state._errorType = 1;
        safeNotifyListeners();
        return;
      }

      final result = await forumRepository.fetchForums(page: page);

      if (result is DataSuccess) {
        state._isRefreshing = false;
        state._totalPages = result.data?.total ?? 1;
        state._forums.addAll(result.data?.data
                ?.map((item) => ForumModel.fromApiModel(item))
                .toList() ??
            []);
        if (result.data != null &&
            result.data!.data != null &&
            result.data!.data!.isEmpty) {
          state._isEndOfPage = true;
        }
      }

      if (result is DataError) {
        state._isRefreshing = false;
        state._errorMessage = result.error ?? 'Error';
        state._errorType = 2;
      }
    } on Exception catch (err) {
      LOGGER.e(err);
    } finally {
      state._loading = false;
      safeNotifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (state._currentPage < state._totalPages && !state._isEndOfPage) {
      try {
        final isConnected = await connectionRepository.checkInternetStatus();
        state._errorMessage = isConnected ? '' : 'No internet connection';
        if (!isConnected) {
          state._errorType = 1;
          safeNotifyListeners();
          return;
        }

        final result = await forumRepository.fetchForums(
          page: ++state._currentPage,
        );

        if (result is DataSuccess) {
          state._isRefreshing = false;
          state._totalPages = result.data?.total ?? 1;
          state._forums.addAll(result.data?.data
                  ?.map((item) => ForumModel.fromApiModel(item))
                  .toList() ??
              []);
          if (result.data != null &&
              result.data!.data != null &&
              result.data!.data!.isEmpty) {
            state._isEndOfPage = true;
          }
        }

        if (result is DataError) {
          state._errorMessage = result.error ?? 'Error';
          state._errorType = 2;
          state._isRefreshing = false;
        }
      } on Exception catch (err) {
        LOGGER.e(err);
      } finally {
        state._loading = false;
        safeNotifyListeners();
      }
    }
  }
}
