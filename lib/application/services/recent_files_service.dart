import 'dart:typed_data';

import 'package:drift/drift.dart';

import '../../domain/document.dart';
import '../../infrastructure/database/app_database.dart';

class RecentFilesService {
  RecentFilesService(this._db);
  final AppDatabase _db;

  Future<void> recordOpen(DocumentRef ref, {String? handlerId}) async {
    final now = DateTime.now();
    await _db.into(_db.documents).insertOnConflictUpdate(
          DocumentsCompanion(
            path: Value(ref.path),
            displayName: Value(ref.displayName),
            mimeType: Value(ref.mimeType),
            sizeBytes: Value(ref.sizeBytes),
            handlerId: Value(handlerId),
            lastOpenedAt: Value(now),
          ),
        );
    await _db.into(_db.recents).insert(
          RecentsCompanion.insert(
            documentPath: ref.path,
            openedAt: now,
          ),
        );
  }

  Future<List<DocumentRef>> list({int limit = 50}) async {
    final rows = await (_db.select(_db.documents)
          ..orderBy([
            (d) => OrderingTerm(
                  expression: d.lastOpenedAt,
                  mode: OrderingMode.desc,
                ),
          ])
          ..limit(limit))
        .get();
    return [
      for (final d in rows)
        DocumentRef(
          path: d.path,
          displayName: d.displayName,
          mimeType: d.mimeType,
          sizeBytes: d.sizeBytes,
          lastModified: d.lastOpenedAt,
        ),
    ];
  }

  Future<void> remove(String path) async {
    await (_db.delete(_db.recents)..where((r) => r.documentPath.equals(path)))
        .go();
    await (_db.delete(_db.documents)..where((d) => d.path.equals(path))).go();
  }

  Future<void> clear() async {
    await _db.delete(_db.recents).go();
    await _db.delete(_db.documents).go();
  }

  Future<void> saveThumbnail(String path, List<int> bytes) async {
    await (_db.update(_db.documents)..where((d) => d.path.equals(path))).write(
      DocumentsCompanion(thumbnail: Value(Uint8List.fromList(bytes))),
    );
  }

  Future<List<int>?> loadThumbnail(String path) async {
    final row = await (_db.select(_db.documents)
          ..where((d) => d.path.equals(path)))
        .getSingleOrNull();
    final blob = row?.thumbnail;
    return blob == null ? null : List<int>.from(blob);
  }
}
