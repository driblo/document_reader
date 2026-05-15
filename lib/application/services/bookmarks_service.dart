import 'package:drift/drift.dart';

import '../../domain/bookmark.dart';
import '../../infrastructure/database/app_database.dart';

class BookmarksService {
  BookmarksService(this._db);
  final AppDatabase _db;

  Future<List<Bookmark>> listFor(String path) async {
    final rows = await (_db.select(_db.bookmarks)
          ..where((b) => b.documentPath.equals(path))
          ..orderBy([(b) => OrderingTerm.desc(b.createdAt)]))
        .get();
    return [
      for (final b in rows)
        Bookmark(
          id: b.id,
          documentPath: b.documentPath,
          label: b.label,
          position: b.position,
          createdAt: b.createdAt,
        ),
    ];
  }

  Future<int> add({
    required String path,
    required String label,
    required String position,
  }) async {
    return _db.into(_db.bookmarks).insert(
          BookmarksCompanion.insert(
            documentPath: path,
            label: label,
            position: position,
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<void> remove(int id) async {
    await (_db.delete(_db.bookmarks)..where((b) => b.id.equals(id))).go();
  }
}
