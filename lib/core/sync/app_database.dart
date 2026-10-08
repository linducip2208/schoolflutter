import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Cached GET responses: key = endpoint + sorted query string.
class KvCache extends Table {
  TextColumn get key => text()();
  TextColumn get body => text()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {key};
}

/// Durable outbox for mutations created while offline.
/// De-duplicated server-side via [idempotencyKey] (sent as Idempotency-Key).
class MutationQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get method => text()();
  TextColumn get path => text()();
  TextColumn get body => text().nullable()();
  TextColumn get idempotencyKey => text().unique()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextRetryAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();
  // pending | failed (dead-letter, needs manual retry)
  TextColumn get status => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: <Type>[KvCache, MutationQueue])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_open());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
}

LazyDatabase _open() {
  return LazyDatabase(() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    return NativeDatabase.createInBackground(
        File(p.join(dir.path, 'eschool.sqlite')));
  });
}
