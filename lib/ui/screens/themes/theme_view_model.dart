import 'package:flutter/cupertino.dart';
import 'package:safe_mama/api/models/data_state.dart';
import 'package:safe_mama/injection_container.dart';
import 'package:safe_mama/models/sub_theme_model.dart';
import 'package:safe_mama/models/theme_model.dart';
import 'package:safe_mama/repository/theme_repository.dart';
import 'package:safe_mama/utils/helpers.dart';
import 'package:safe_mama/ui/providers/safe_notifier.dart';

class ThemesState {
  bool _loading = false;
  String _errorMessage = '';
  final int _currentPage = 1;
  final int _totalPages = 1;
  List<ThemeModel> _themes = [];
  List<ThemeModel> _actionThemes = [];
  final List<SubThemeModel> _subThemes = [];

  bool get loading => _loading;
  String get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  List<ThemeModel> get themeList => _themes;
  List<ThemeModel> get actionThemeList => _actionThemes;
  List<SubThemeModel> get subThemeList => _subThemes;
}

class ThemeViewModel extends ChangeNotifier with SafeNotifier {
  late final ThemeRepository themeRepository;
  ThemesState state = ThemesState();
  ThemesState get getState => state;

  ThemeViewModel(this.themeRepository);

  Future<void> fetchThemes(bool isTablet) async {
    state._loading = true;
    safeNotifyListeners();

    try {
      final result = await themeRepository.fetchThemes();

      if (result is DataSuccess) {
        final list = result.data!;
        state._themes = list;
        final actionThemes = Helpers.pickNItems(list, isTablet ? 4 : 2);
        LOGGER.d('actionThemes: ${actionThemes.length}');
        actionThemes.add(ThemeModel(
            id: 100000,
            description: 'More',
            icon: 'fa-users',
            displayIndex: 1));
        state._actionThemes = actionThemes;
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
}
