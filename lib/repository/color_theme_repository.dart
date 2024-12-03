import 'dart:ui';

import 'package:safe_mama/cache/preferences_datasource.dart';
import 'package:safe_mama/injection_container.dart';
import 'package:safe_mama/utils/helpers.dart';

abstract class ColorThemeRepository {
  Future<void> saveThemeColors(String primary, String secondary);
  Future<Color?> loadPrimaryColor();
  Future<Color?> loadSecondaryColor();
}

class ColorThemeRepositoryImpl extends ColorThemeRepository {
  final PreferencesDatasource preferences;

  ColorThemeRepositoryImpl({required this.preferences});

  @override
  Future<Color?> loadPrimaryColor() async {
    final colorString =
        preferences.getString(PreferencesDatasource.primaryColorKey);
    if (colorString.isNotEmpty) {
      return Helpers.hexToColor(colorString);
    }
    return null;
  }

  @override
  Future<Color?> loadSecondaryColor() async {
    final colorString =
        preferences.getString(PreferencesDatasource.secondaryColorKey);
    if (colorString.isNotEmpty) {
      return Helpers.hexToColor(colorString);
    }
    return null;
  }

  @override
  Future<void> saveThemeColors(String primary, String secondary) async {
    LOGGER.d('Saving theme colors: $primary, $secondary');
    await preferences.saveString(
        PreferencesDatasource.primaryColorKey, primary);
    await preferences.saveString(
        PreferencesDatasource.secondaryColorKey, secondary);
  }
}
