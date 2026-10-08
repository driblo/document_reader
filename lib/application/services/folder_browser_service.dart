import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../domain/fs_entry.dart';

/// Lists directories one level at a time, like a system file manager —
/// as opposed to [DeviceScannerService], which recursively indexes
/// everything up front for the flat "Library" search.
class FolderBrowserService {
  Future<List<StorageVolume>> volumes() async {
    final result = <StorageVolume>[];

    if (Platform.isAndroid) {
      const primary = '/storage/emulated/0';
      if (Directory(primary).existsSync()) {
        result.add(const StorageVolume(label: 'Internal storage', path: primary));
      }
      try {
        final ext = await getExternalStorageDirectories();
        if (ext != null) {
          for (final dir in ext) {
            final root = _volumeRootFor(dir.path);
            if (root == null || root == primary) continue;
            if (result.any((v) => v.path == root)) continue;
            if (!Directory(root).existsSync()) continue;
            result.add(StorageVolume(label: 'SD card', path: root));
          }
        }
      } catch (_) {}
    } else {
      try {
        final docs = await getApplicationDocumentsDirectory();
        result.add(StorageVolume(label: 'Documents', path: docs.path));
      } catch (_) {}
    }

    return result;
  }

  /// path_provider's external dirs point at the app-specific sandbox
  /// (`/storage/XXXX-XXXX/Android/data/<pkg>/files`) — walk back up to
  /// the volume root so the whole card can be browsed, not just that.
  String? _volumeRootFor(String appSpecificPath) {
    const marker = '/Android/data/';
    final idx = appSpecificPath.indexOf(marker);
    if (idx == -1) return null;
    return appSpecificPath.substring(0, idx);
  }

  Future<List<FsEntry>> list(String dirPath) async {
    final dir = Directory(dirPath);
    if (!dir.existsSync()) return const [];

    final dirs = <FsEntry>[];
    final files = <FsEntry>[];

    try {
      await for (final entity in dir.list(followLinks: false)) {
        final name = entity.uri.pathSegments
            .lastWhere((s) => s.isNotEmpty, orElse: () => '');
        if (name.isEmpty || name.startsWith('.')) continue;
        try {
          final stat = await entity.stat();
          if (entity is Directory) {
            dirs.add(
              FsEntry(
                path: entity.path,
                name: name,
                isDirectory: true,
                lastModified: stat.modified,
              ),
            );
          } else if (entity is File) {
            files.add(
              FsEntry(
                path: entity.path,
                name: name,
                isDirectory: false,
                sizeBytes: stat.size,
                lastModified: stat.modified,
              ),
            );
          }
        } catch (_) {
          // Unreadable entry (permission, dangling symlink, ...) — skip it.
        }
      }
    } catch (_) {
      // Directory itself not listable — return whatever was gathered.
    }

    int byName(FsEntry a, FsEntry b) =>
        a.name.toLowerCase().compareTo(b.name.toLowerCase());
    dirs.sort(byName);
    files.sort(byName);
    return [...dirs, ...files];
  }
}
