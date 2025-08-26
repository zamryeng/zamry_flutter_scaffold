import 'sqflite_db_service.dart';

abstract interface class LocalDbSetup {
  static const LocalDbSetup instance = _V1LocalDbSetup();

  String onCreate(int version);

  OnDatabaseVersionChangeQueryFn? get onUpgrade;

  OnDatabaseVersionChangeQueryFn? get onDowngrade;

  int get version;
}

// TODO(LocalDbSetup): implement v1 setup
final class _V1LocalDbSetup implements LocalDbSetup {
  const _V1LocalDbSetup();

  @override
  String onCreate(int version) => '''
CREATE TABLE countries (country_code VARCHAR(2) PRIMARY KEY, name VARCHAR(100) NOT NULL, phone_code VARCHAR(2) NOT NULL);

CREATE TABLE owners (
  owner_id VARCHAR(50) PRIMARY KEY,
  alias VARCHAR(100),
  device_alias VARCHAR(100),
  country_code VARCHAR(2),
  language_code VARCHAR(5),
  metatags TEXT,
  created_at TEXT,
  updated_at TEXT,
  FOREIGN KEY(country_code) REFERENCES countries(country_code)
);
''';

  @override
  OnDatabaseVersionChangeQueryFn? get onDowngrade => null;

  @override
  OnDatabaseVersionChangeQueryFn? get onUpgrade => null;

  @override
  int get version => 1;
}
