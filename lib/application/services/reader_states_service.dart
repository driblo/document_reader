import 'package:drift/drift.dart';

import '../../domain/reader_state.dart';
import '../../infrastructure/database/app_database.dart';

class ReaderStatesService {
  ReaderStatesService(this._db);
  final AppDatabase _db;

  Future<ReaderState?> load(String path) async {
    final row = await (_db.select(_db.readerStates)
          ..where((s) => s.documentPath.equals(path)))
        .getSingleOrNull();
    if (row == null) return null;
    return ReaderState(
      documentPath: row.documentPath,
      position: row.position,
      zoom: row.zoom,
      scrollOffset: row.scrollOffset,
      updatedAt: row.updatedAt,
    );
  }

  Future<void> save(
    String path, {
    required String position,
    double? zoom,
    double? scrollOffset,
  }) async {
    await _db.into(_db.readerStates).insertOnConflictUpdate(
          ReaderStatesCompanion(
            documentPath: Value(path),
            position: Value(position),
            zoom: Value(zoom),
            scrollOffset: Value(scrollOffset),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }
}
