import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import '../local_storage_service/local_storage_service.dart';
import 'db_setup.dart';

const _kDbPass = 'DB_PASS';

typedef RawQuery = ({String sql, List<Object> args});
typedef OnCreateRawQueryFn = String Function(int version);
typedef OnDatabaseVersionChangeQueryFn = String Function(int oldVersion, int newVersion);

/// This class serves a a blueprint for interacting with the sqflite engine
/// for Zamry applications, with an encryption-first approach to initialise the
/// database, ensuring it's safe and secure.
class SqliteDb {
  SqliteDb();

  Database? _db;

  @protected
  Database get db {
    if (_db == null) {
      throw StateError('Db instance cannot be found, did you fail to initialise it?');
    }

    return _db!;
  }

  /// This methods initialises the [SqliteDb] database
  /// encryption is paramount hence the dependence on [LocalStorageService]
  /// passed as [service] parameter to retrieve or set the db's password if not set.
  /// It also takes a [dbName] which is used to create/open the local db.
  /// [setup] takes an instance of [DBSetup] which is used to coordinate
  /// operations on the initialisation of the database with creation, upgrade,
  /// and downgrade scripts
  Future<void> initialise(
    LocalStorageService service, {
    String dbName = 'zamry',
    required DBSetup setup,
  }) async {
    if (_db != null) {
      throw ArgumentError('db already set');
    }

    var (path, password) = await (getDatabasesPath(), service.fetchString(_kDbPass)).wait;

    if (password == null || password.isEmpty) {
      password = base64Encode(Random.secure().nextBytes(32)); // generate random 32 bytes password
      await service.saveString(_kDbPass, password);
    }
    _db = await openDatabase(
      '$path/$dbName.db',
      password: password,
      onCreate: (db, version) async {
        if (setup.onCreate != null) {
          final cmd = [...setup.onCreate!(version).replaceAll('\n', '').split(';')]..remove('');
          await db.transaction((txn) async {
            for (var sql in [...cmd.map((s) => txn.execute(s))]) {
              await sql;
            }
          });
        }
      },
      onUpgrade: (db, old, newVersion) async {
        if (setup.onUpgrade != null) {
          final cmd = [...setup.onUpgrade!(old, newVersion).replaceAll('\n', '').split(';')]
            ..remove('');
          await db.transaction((txn) async {
            for (var sql in [...cmd.map((s) => txn.execute(s))]) {
              await sql;
            }
          });
        }
      },
      onDowngrade: (db, oldVersion, newVersion) async {
        if (setup.onDowngrade != null) {
          final cmd = [
            ...setup.onDowngrade!(oldVersion, newVersion).replaceAll('\n', '').split(';'),
          ]..remove('');
          await db.transaction((txn) async {
            for (var sql in [...cmd.map((s) => txn.execute(s))]) {
              await sql;
            }
          });
        }
      },
      version: setup.version,
    );
  }

  /// This method helps insert a map of [values]
  /// into the specified [table] and returns the
  /// id of the last inserted row.
  ///
  /// ```
  ///    var value = {
  ///      'age': 18,
  ///      'name': 'value'
  ///    };
  ///    int id = await db.insert(
  ///      'table',
  ///      value,
  ///      conflictAlgorithm: ConflictAlgorithm.replace,
  ///    );
  /// ```
  ///
  /// 0 could be returned for some specific conflict algorithms if not inserted.
  Future create(String table, Map<String, Object> fields) async {
    await db.transaction((txn) {
      return txn.insert(table, fields, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  /// This is a helper to query a table and return the items found. All optional
  /// clauses and filters are formatted as SQL queries
  /// excluding the clauses' names.
  ///
  /// [table] contains the table names to compile the query against.
  ///
  /// [distinct] when set to true ensures each row is unique.
  ///
  /// The [columns] list specify which columns to return. Passing null will
  /// return all columns, which is discouraged.
  ///
  /// [where] filters which rows to return. Passing null will return all rows
  /// for the given URL. '?'s are replaced with the items in the
  /// [whereArgs] field.
  ///
  /// [groupBy] declares how to group rows. Passing null
  /// will cause the rows to not be grouped.
  ///
  /// [having] declares which row groups to include in the cursor,
  /// if row grouping is being used. Passing null will cause
  /// all row groups to be included, and is required when row
  /// grouping is not being used.
  ///
  /// [orderBy] declares how to order the rows,
  /// Passing null will use the default sort order,
  /// which may be unordered.
  ///
  /// [limit] limits the number of rows returned by the query.
  ///
  /// [offset] specifies the starting index.
  ///
  /// [rawQuery] record that specifies a raw query, takes a [sql] String and
  /// [args] List<Object> arguments
  ///
  /// ```
  ///  List<Map> maps = await db.query(tableTodo,
  ///      columns: ['columnId', 'columnDone', 'columnTitle'],
  ///      where: 'columnId = ?',
  ///      whereArgs: [id]);
  /// ```
  Future<List<Map<String, Object?>>> retrieve(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
    RawQuery? rawQuery,
  }) {
    final nonNullRetrievalOption =
        distinct != null ||
        columns != null ||
        where != null ||
        whereArgs != null ||
        groupBy != null ||
        having != null ||
        orderBy != null ||
        limit != null ||
        offset != null;

    assert(
      nonNullRetrievalOption && rawQuery == null || rawQuery != null,
      'retrieval options have no effect when a raw query is passed',
    );

    if (rawQuery != null) {
      return db.rawQuery(rawQuery.sql, rawQuery.args);
    }

    return db.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  /// Convenience method for updating rows in the database. Returns
  /// the number of changes made
  ///
  /// Update [table] with [values], a map from column names to new column
  /// values. null is a valid value that will be translated to NULL.
  ///
  /// [where] is the optional WHERE clause to apply when updating.
  /// Passing null will update all rows.
  ///
  /// You may include ?s in the where clause, which will be replaced by the
  /// values from [whereArgs]
  ///
  /// [conflictAlgorithm] (optional) specifies algorithm to use in case of a
  /// conflict. See [ConflictAlgorithm] docs for more details
  ///
  /// ```
  /// int count = await db.update(tableTodo, todo.toMap(),
  ///    where: '$columnId = ?', whereArgs: [todo.id]);
  /// ```
  Future<int> update(
    String table,
    Map<String, Object> fields, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    return await db.transaction((txn) {
      return txn.update(
        table,
        fields,
        whereArgs: whereArgs,
        where: where,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  /// Convenience method for deleting rows in the database.
  ///
  /// Delete from [table]
  ///
  /// [where] is the optional WHERE clause to apply when updating. Passing null
  /// will delete all rows.
  ///
  /// You may include ?s in the where clause, which will be replaced by the
  /// values from [whereArgs]
  ///
  /// Returns the number of rows affected.
  /// ```
  ///  int count = await db.delete(tableTodo, where: 'columnId = ?', whereArgs: [id]);
  /// ```
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) async {
    return await db.transaction((txn) {
      return txn.delete(table, where: where, whereArgs: whereArgs);
    });
  }

  Future<void> close() => db.close();
}

extension on Random {
  /// Not part of public API
  Uint8List nextBytes(int bytes) {
    final buffer = Uint8List(bytes);
    for (var i = 0; i < bytes; i++) {
      buffer[i] = nextInt(0xFF + 1);
    }
    return buffer;
  }
}
