import '../domain/document.dart';

/// Phase 0 surface; backed by [AppDatabase] in Phase 1. Kept as an
/// interface here so providers can depend on it without dragging in
/// `drift` until the generated bindings exist.
abstract class RecentFilesService {
  Future<List<DocumentRef>> list({int limit = 50});
  Future<void> recordOpen(DocumentRef ref);
  Future<void> remove(String path);
  Future<void> clear();
}

/// In-memory implementation used until the SQLite-backed one lands.
class InMemoryRecentFilesService implements RecentFilesService {
  final List<DocumentRef> _items = [];

  @override
  Future<List<DocumentRef>> list({int limit = 50}) async =>
      _items.take(limit).toList(growable: false);

  @override
  Future<void> recordOpen(DocumentRef ref) async {
    _items.removeWhere((r) => r.path == ref.path);
    _items.insert(0, ref);
  }

  @override
  Future<void> remove(String path) async {
    _items.removeWhere((r) => r.path == path);
  }

  @override
  Future<void> clear() async => _items.clear();
}
