import 'package:flutter/foundation.dart';
import 'package:khub_mobile/cache/db_migrator/migration_config.dart';
import 'package:khub_mobile/cache/db_migrator/migrator.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final List<String> initialScript = [
  '''
  CREATE TABLE ${AppDatabase.fileTypeTable}(
    id INTEGER PRIMARY KEY NOT NULL,
    name TEXT NOT NULL,
    icon TEXT,
    isDownloadable INTEGER
  );
  ''',
  '''
  CREATE TABLE ${AppDatabase.fileCategoryTable}(
    id INTEGER PRIMARY KEY NOT NULL,
    name TEXT NOT NULL,
    icon TEXT,
    isDownloadable INTEGER
  );
  ''',
  '''
  CREATE TABLE ${AppDatabase.communityTable}(
    id INTEGER PRIMARY KEY NOT NULL,
    communityName TEXT,
    description TEXT,
    isActive INTEGER
  );
  ''',
  '''
   CREATE TABLE ${AppDatabase.jobTable}(
    id INTEGER PRIMARY KEY NOT NULL,
    jobId INTEGER,
    classificationId INTEGER,
    iscoId INTEGER,
    name TEXT
  );
  ''',
  '''
   CREATE TABLE ${AppDatabase.preferenceTable}(
    id INTEGER PRIMARY KEY NOT NULL,
    name TEXT
  );
  '''
];

final List<String> migrations = [
  '''
  CREATE TABLE ${AppDatabase.countryTable}(
    id INTEGER PRIMARY KEY NOT NULL,
    name TEXT,
    national TEXT,
    isoCode TEXT,
    phoneCode TEXT,
    color TEXT,
    regionId INTEGER,
    longitude REAL,
    latitude REAL
  );
  ''',
  '''
  CREATE TABLE ${AppDatabase.userTable}(
    id INTEGER PRIMARY KEY NOT NULL,
    name TEXT,
    firstName TEXT,
    lastName TEXT,
    email TEXT,
    photo TEXT,
    isApproved INTEGER,
    isVerified INTEGER,
    status INTEGER,
    jobTitle TEXT,
    phoneNumber TEXT,
    countryId INTEGER,
    organizationName TEXT,
    language TEXT,
    authorId INTEGER
  );
  ''',
  '''
  CREATE TABLE ${AppDatabase.userCountryTable}(
    id INTEGER PRIMARY KEY NOT NULL,
    userId INTEGER NOT NULL,
    name TEXT,
    national TEXT,
    isoCode TEXT,
    phoneCode TEXT,
    color TEXT,
    regionId INTEGER,
    longitude REAL,
    latitude REAL
  );
  ''',
  '''
  CREATE TABLE ${AppDatabase.themeTable}(
    id INTEGER PRIMARY KEY NOT NULL,
    description TEXT,
    icon TEXT,
    displayIndex INTEGER
  );
  ''',
  '''
  CREATE TABLE ${AppDatabase.userSettingsTable}(
    id INTEGER PRIMARY KEY NOT NULL,
    title TEXT,
    siteName TEXT,
    seoKeywords TEXT,
    siteDescription TEXT,
    address TEXT,
    email TEXT,
    phone TEXT,
    language TEXT,
    timezone TEXT,
    primaryColor TEXT,
    secondaryColor TEXT,
    logo TEXT,
    favicon TEXT,
    iconFontColor TEXT,
    primaryTextColor TEXT,
    linksActiveColor TEXT,
    spotlightBanner TEXT,
    bannerText TEXT,
    slogan TEXT
  );
  ''',
  '''
  ALTER TABLE ${AppDatabase.userSettingsTable}
  ADD COLUMN userId INTEGER;
  ''',
  '''
  CREATE TABLE ${AppDatabase.resourceCategoryTable}(
    id INTEGER PRIMARY KEY NOT NULL,
    categoryName TEXT
  );
  ''',
  '''
  CREATE TABLE ${AppDatabase.resourceTypeTable}(
    id INTEGER PRIMARY KEY NOT NULL,
    categoryName TEXT,
    showOnMenu INTEGER,
    slug TEXT
  );
  ''',
  '''
  ALTER TABLE ${AppDatabase.communityTable} RENAME COLUMN communityName TO name;
  ''',
  '''
  ALTER TABLE ${AppDatabase.countryTable} 
  ADD COLUMN isAppSupported INTEGER;
  ''',
  '''
  ALTER TABLE ${AppDatabase.countryTable} 
  ADD COLUMN baseUrl TEXT;
  ''',
  '''
  CREATE TABLE ${AppDatabase.userPreferenceTable}(
    id INTEGER PRIMARY KEY NOT NULL,
    userId INTEGER,
    preferenceId INTEGER
  );
  ''',
  '''
  ALTER TABLE ${AppDatabase.userPreferenceTable}
  RENAME COLUMN preferenceId TO description;
  ''',
  '''
  ALTER TABLE ${AppDatabase.userPreferenceTable}
  ADD COLUMN icon TEXT;
  ''',
  '''
  ALTER TABLE ${AppDatabase.preferenceTable}
  ADD COLUMN icon TEXT;
  ''',
];

class AppDatabase {
  static const String _appName = kReleaseMode ? 'khub.db' : 'khub_dev2.db';
  static const String fileTypeTable = 'file_type_table';
  static const String jobTable = 'job_table';
  static const String communityTable = 'community_table';
  static const String preferenceTable = 'preference_table';
  static const String fileCategoryTable = 'file_category_table';
  static const String countryTable = 'country_table';
  static const String userTable = 'user_table';
  static const String userSettingsTable = 'user_settings_table';
  static const String userCountryTable = 'user_country_table';
  static const String userPreferenceTable = 'user_preference_table';
  static const String themeTable = 'theme_table';
  static const String resourceTypeTable = 'resource_type_table';
  static const String resourceCategoryTable = 'resource_category_table';

  final config = MigrationConfig(
      initializationScript: initialScript, migrationScripts: migrations);

//Creating a database with name test.dn in your directory
  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _appName);
    final migrator = Migrator(config);

    return await openDatabase(path,
        version: config.migrationScripts.length + 1,
        onCreate: migrator.executeInitialization,
        onUpgrade: migrator.executeMigration);
  }
}
