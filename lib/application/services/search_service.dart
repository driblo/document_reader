import 'package:drift/drift.dart';

import '../../infrastructure/database/app_database.dart';
import '../../infrastructure/handlers/handler_registry.dart';
import '../../domain/document.dart';

class SearchHit {
  const SearchHit({required this.documentPath, required this.snippet, required this.score});
  final String documentPath;
  final String snippet;
  final double score;
}

class SearchService {
  SearchService(this._db, this._registry);
  final AppDatabase _db;
  final HandlerRegistry _registry;

  /// Indexes a document's extracted text in the FTS5 table. Safe to call
  /// repeatedly — previous entries for the same path are removed first.
  Future<void> indexDocument(DocumentRef ref) async {
    final handler = _registry.resolve(ref);
    if (handler == null) return;
    final text = await handler.extractText(ref);
    if (text == null || text.isEmpty) return;

    await _db.transaction(() async {
      await _db.customStatement(
        'DELETE FROM search_index WHERE document_path = ?',
        [ref.path],
      );
      await _db.customStatement(
        'INSERT INTO search_index (document_path, content) VALUES (?, ?)',
        [ref.path, text],
      );
      await (_db.update(_db.documents)
            ..where((d) => d.path.equals(ref.path)))
          .write(DocumentsCompanion(indexedAt: Value(DateTime.now())));
    });
  }

  /// Phrase query against FTS5; ranks results by BM25 (lower = better).
  Future<List<SearchHit>> search(String query, {int limit = 50}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];
    final rows = await _db.customSelect(
      'SELECT document_path, '
      "snippet(search_index, 1, '[', ']', '…', 16) AS snippet, "
      'bm25(search_index) AS rank '
      'FROM search_index WHERE search_index MATCH ? '
      'ORDER BY rank LIMIT ?',
      variables: [Variable.withString(trimmed), Variable.withInt(limit)],
      readsFrom: {},
    ).get();
    return [
      for (final r in rows)
        SearchHit(
          documentPath: r.read<String>('document_path'),
          snippet: r.read<String>('snippet'),
          score: r.read<double>('rank'),
        ),
    ];
  }
}
