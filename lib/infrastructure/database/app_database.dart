import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class Documents extends Table {
  TextColumn get path => text()();
  TextColumn get displayName => text()();
  TextColumn get mimeType => text()();
  IntColumn get sizeBytes => integer()();
  DateTimeColumn get lastOpenedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {path};
}

class Recents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get documentPath => text().references(Documents, #path)();
  DateTimeColumn get openedAt => dateTime()();
}

class Bookmarks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get documentPath => text().references(Documents, #path)();
  TextColumn get label => text()();
  TextColumn get position => text()();
  DateTimeColumn get createdAt => dateTime()();
}

class ReaderStates extends Table {
  TextColumn get documentPath => text().references(Documents, #path)();
  TextColumn get position => text()();
  RealColumn get zoom => real().nullable()();
  RealColumn get scrollOffset => real().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {documentPath};
}

/// Full-text index over extracted document text. Drift creates the
/// underlying FTS5 virtual table from this declaration.
@DataClassName('SearchIndexEntry')
class SearchIndex extends Table {
  TextColumn get documentPath => text()();
  TextColumn get content => text()();
}

@DriftDatabase(
  tables: [Documents, Recents, Bookmarks, ReaderStates, SearchIndex],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_open());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _open() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'document_reader.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
