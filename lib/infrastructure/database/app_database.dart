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
  TextColumn get handlerId => text().nullable()();
  BlobColumn get thumbnail => blob().nullable()();
  DateTimeColumn get lastOpenedAt => dateTime().nullable()();
  DateTimeColumn get indexedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {path};
}

class Recents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get documentPath => text().references(Documents, #path)();
  DateTimeColumn get openedAt => dateTime()();
}

@DataClassName('BookmarkRow')
class Bookmarks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get documentPath => text().references(Documents, #path)();
  TextColumn get label => text()();
  TextColumn get position => text()();
  DateTimeColumn get createdAt => dateTime()();
}

@DataClassName('ReaderStateRow')
class ReaderStates extends Table {
  TextColumn get documentPath => text().references(Documents, #path)();
  TextColumn get position => text()();
  RealColumn get zoom => real().nullable()();
  RealColumn get scrollOffset => real().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {documentPath};
}

@DriftDatabase(
  tables: [Documents, Recents, Bookmarks, ReaderStates],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_open());
  AppDatabase.forTesting(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await customStatement(
            'CREATE VIRTUAL TABLE IF NOT EXISTS search_index '
            'USING fts5(document_path, content, '
            'tokenize="unicode61 remove_diacritics 2")',
          );
        },
      );
}

LazyDatabase _open() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'document_reader.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
