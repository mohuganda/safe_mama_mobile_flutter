import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:safe_mama/cache/events_datasource.dart';
import 'package:safe_mama/cache/preferences_datasource.dart';
import 'package:safe_mama/cache/publication_datasource.dart';
import 'package:safe_mama/cache/theme_datasource.dart';
import 'package:safe_mama/cache/user_datasource.dart';
import 'package:safe_mama/cache/utility_datasource.dart';
import 'package:safe_mama/repository/api_client_repository.dart';
import 'package:safe_mama/repository/auth_repository.dart';
import 'package:safe_mama/repository/color_theme_repository.dart';
import 'package:safe_mama/repository/communities_repository.dart';
import 'package:safe_mama/repository/connection_repository.dart';
import 'package:safe_mama/repository/courses_repository.dart';
import 'package:safe_mama/repository/event_repository.dart';
import 'package:safe_mama/repository/forum_repository.dart';
import 'package:safe_mama/repository/notifications_repository.dart';
import 'package:safe_mama/repository/publication_repository.dart';
import 'package:safe_mama/repository/theme_repository.dart';
import 'package:safe_mama/repository/utility_repository.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;
final LOGGER = Logger();

Future<void> init() async {
  LOGGER.d('Initializing DI');

// Repositories
  getIt.registerLazySingleton<PublicationRepository>(
      () => PublicationRepositoryImpl(apiClientRepository: getIt()));
  getIt.registerLazySingleton<ThemeRepository>(() => ThemeRepositoryImpl(
      apiClientRepository: getIt(), themeDatasource: getIt()));
  getIt.registerLazySingleton<ForumRepository>(
      () => ForumRepositoryImpl(getIt()));
  getIt.registerLazySingleton<NotificationRepository>(
      () => NotificationRepositoryImpl(apiClientRepository: getIt()));
  getIt.registerLazySingleton<ColorThemeRepository>(
      () => ColorThemeRepositoryImpl(preferences: getIt()));
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
      colorThemeRepository: getIt(),
      preferences: getIt(),
      apiClientRepository: getIt(),
      userDatasource: getIt()));
  getIt.registerLazySingleton<UtilityRepository>(
      () => UtilityRepositoryImpl(apiClientRepository: getIt()));
  getIt.registerLazySingleton<CommunitiesRepository>(
      () => CommunitiesRepositoryImpl(apiClientRepository: getIt()));
  getIt.registerLazySingleton<EventRepository>(
      () => EventRepositoryImpl(apiClientRepository: getIt()));
  getIt.registerLazySingleton<CoursesRepository>(
      () => CoursesRepositoryImpl(getIt()));
  getIt.registerLazySingleton<ApiClientRepository>(
      () => ApiClientRepositoryImpl(preferencesDatasource: getIt()));
  getIt.registerLazySingleton<ConnectionRepository>(
      () => ConnectionRepositoryImpl());

  // Data sources
  getIt.registerLazySingleton<UtilityDatasource>(
      () => UtilityDatasourceImpl(preferences: getIt()));
  getIt.registerLazySingleton<UserDatasource>(() => UserDatasourceImpl());
  getIt.registerLazySingleton<ThemeDatasource>(() => ThemeDataSourceImpl());
  getIt.registerLazySingleton<EventsDatasource>(() => EventsDataSourceImpl());
  getIt.registerLazySingleton<PreferencesDatasource>(
      () => PreferencesDatasourceImpl(preferences: getIt()));
  getIt.registerLazySingleton<PublicationDataSource>(
      () => PublicationDataSourceImpl());

// External Libs
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  getIt.registerLazySingleton(() => http.Client());
  getIt.registerLazySingleton(() => Logger());

  getIt.registerLazySingleton<GlobalKey<NavigatorState>>(
      () => GlobalKey<NavigatorState>());

  // API
  // final baseUrl = await _getBaseUrl();
  // getIt.registerLazySingleton<Dio>(() => initDio(baseUrl));
  // getIt.registerLazySingleton<APIClient>(() => APIClient(getIt()));
  // getIt.registerLazySingleton<AuthClient>(() => AuthClient(getIt()));
}

// Future<String> _getBaseUrl() async {
//   final pref = await SharedPreferences.getInstance();
//   final savedUrl = pref.getString(PreferencesDatasource.baseUrlKey);

//   return savedUrl ?? Config().baseUrl;
// }
