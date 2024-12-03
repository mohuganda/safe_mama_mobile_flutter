import 'package:flutter/cupertino.dart';
import 'package:khub_mobile/api/config/config.dart';
import 'package:khub_mobile/api/models/data_state.dart';
import 'package:khub_mobile/injection_container.dart';
import 'package:khub_mobile/models/forum_model.dart';
import 'package:khub_mobile/repository/forum_repository.dart';
import 'package:khub_mobile/repository/publication_repository.dart';
import 'package:khub_mobile/models/publication_model.dart';
import 'package:khub_mobile/ui/providers/safe_notifier.dart';

class SearchState {
  bool _loading = false;
  bool _loadingMore = false;
  String _errorMessage = '';
  int _currentPage = Config.startPage;
  int _totalPages = 1;
  bool _isEndOfPage = false;
  List<PublicationModel> _publications = [];
  List<ForumModel> _forums = [];

  bool get loading => _loading;
  String get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  List<PublicationModel> get publications => _publications;
  List<ForumModel> get forums => _forums;
}

class SearchViewModel extends ChangeNotifier with SafeNotifier {
  final PublicationRepository publicationRepository;
  final ForumRepository forumRepository;
  SearchState state = SearchState();
  SearchState get getState => state;

  SearchViewModel(this.publicationRepository, this.forumRepository);

  Future<void> fetchPublications(
      {String term = '', int page = Config.startPage}) async {
    state._loading = true;
    state._publications = []; // reset
    state._currentPage = Config.startPage; // reset
    state._isEndOfPage = false; // reset
    safeNotifyListeners();

    try {
      final result =
          await publicationRepository.fetchPublications(term: term, page: page);

      if (result is DataSuccess) {
        state._totalPages = result.data?.total ?? 1;
        state._publications = result.data?.data
                ?.map((item) => PublicationModel.fromApiModel(item))
                .toList() ??
            [];
        if (result.data != null &&
            result.data!.data != null &&
            result.data!.data!.isEmpty) {
          state._isEndOfPage = true;
        }
      }

      if (result is DataError) {
        state._errorMessage = result.error ?? 'Error';
      }
    } on Exception catch (err) {
      LOGGER.e(err);
    } finally {
      state._loading = false;
      safeNotifyListeners();
    }
  }

  Future<void> loadMorePublications({String searchTerm = ''}) async {
    if (state._currentPage < state._totalPages && !state._isEndOfPage) {
      state._loadingMore = true;

      try {
        final result = await publicationRepository.fetchPublications(
            term: searchTerm, page: ++state._currentPage);

        if (result is DataSuccess) {
          state._totalPages = result.data?.total ?? 1;
          state._publications.addAll(result.data?.data
                  ?.map((item) => PublicationModel.fromApiModel(item))
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
        }
      } on Exception catch (err) {
        LOGGER.e(err);
      } finally {
        state._loadingMore = false;
        safeNotifyListeners();
      }
    }
  }

  Future<void> fetchForums(
      {String term = '', int page = Config.startPage}) async {
    state._loading = true;
    state._forums = []; // reset
    state._currentPage = Config.startPage; // reset
    state._isEndOfPage = false; // reset
    safeNotifyListeners();

    try {
      final result = await forumRepository.fetchForums(term: term, page: page);

      if (result is DataSuccess) {
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
      }
    } on Exception catch (err) {
      LOGGER.e(err);
    } finally {
      state._loading = false;
      safeNotifyListeners();
    }
  }

  Future<void> loadMoreForums({String searchTerm = ''}) async {
    if (state._currentPage < state._totalPages && !state._isEndOfPage) {
      state._loadingMore = true;
      try {
        final result = await forumRepository.fetchForums(
          term: searchTerm,
          page: ++state._currentPage,
        );

        if (result is DataSuccess) {
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
        }
      } on Exception catch (err) {
        LOGGER.e(err);
      } finally {
        state._loadingMore = false;
        safeNotifyListeners();
      }
    }
  }
}
