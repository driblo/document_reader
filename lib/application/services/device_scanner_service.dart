import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../domain/document.dart';

class DeviceScannerService {
  static const _extensions = {
    // Documents
    'pdf', 'epub',
    // Markup
    'md', 'markdown', 'html', 'htm',
    // Office
    'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'odt', 'ods', 'odp',
    // Images
    'jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp', 'heic', 'heif', 'tiff', 'tif',
    // Comics
    'cbz',
    // Text / code
    'txt', 'csv', 'log',
    'dart', 'py', 'js', 'ts', 'java', 'kt', 'swift', 'c', 'cpp', 'h',
    'go', 'rs', 'rb', 'php', 'sh', 'yaml', 'yml', 'json', 'xml', 'toml', 'sql',
  };

  Future<bool> requestPermission() async {
    if (!Platform.isAndroid) return true;
    // Android 13+ splits storage into granular media permissions.
    // READ_EXTERNAL_STORAGE still covers docs/downloads on ≤12.
    final results = await [
      Permission.storage,
      Permission.photos,
      Permission.videos,
    ].request();
    return results.values.any((s) => s.isGranted);
  }

  Future<bool> hasPermission() async {
    if (!Platform.isAndroid) return true;
    return await Permission.storage.isGranted ||
        await Permission.photos.isGranted;
  }

  Future<List<DocumentRef>> scan() async {
    final seen = <String>{};
    final results = <DocumentRef>[];

    for (final dir in await _searchDirectories()) {
      await _scanDir(dir, results, seen, depth: 0);
    }

    results.sort((a, b) =>
        (b.lastModified ?? DateTime(0)).compareTo(a.lastModified ?? DateTime(0)));
    return results;
  }

  Future<List<Directory>> _searchDirectories() async {
    final dirs = <Directory>[];

    if (Platform.isAndroid) {
      // Well-known Android shared storage paths.
      for (final p in const [
        '/storage/emulated/0/Download',
        '/storage/emulated/0/Downloads',
        '/storage/emulated/0/Documents',
        '/storage/emulated/0/DCIM',
        '/storage/emulated/0/Pictures',
        '/storage/emulated/0/Movies',
        '/storage/emulated/0/Music',
      ]) {
        dirs.add(Directory(p));
      }
      // External SD cards etc.
      try {
        final ext = await getExternalStorageDirectories();
        if (ext != null) dirs.addAll(ext);
      } catch (_) {}
    }

    // path_provider fallbacks (works on iOS / desktop too).
    try {
      final dl = await getDownloadsDirectory();
      if (dl != null) dirs.add(dl);
    } catch (_) {}
    try {
      dirs.add(await getApplicationDocumentsDirectory());
    } catch (_) {}

    return dirs;
  }

  Future<void> _scanDir(
    Directory dir,
    List<DocumentRef> out,
    Set<String> seen, {
    required int depth,
  }) async {
    if (depth > 5 || !dir.existsSync()) return;
    try {
      await for (final entity in dir.list(followLinks: false)) {
        if (entity is File) {
          final name = entity.uri.pathSegments.last;
          final dot = name.lastIndexOf('.');
          if (dot == -1) continue;
          final ext = name.substring(dot + 1).toLowerCase();
          if (!_extensions.contains(ext)) continue;
          final path = entity.path;
          if (!seen.add(path)) continue;
          try {
            final stat = await entity.stat();
            out.add(DocumentRef(
              path: path,
              displayName: name,
              mimeType: _mime(ext),
              sizeBytes: stat.size,
              lastModified: stat.modified,
            ));
          } catch (_) {}
        } else if (entity is Directory && depth < 5) {
          final name = entity.uri.pathSegments
              .lastWhere((s) => s.isNotEmpty, orElse: () => '');
          if (!name.startsWith('.')) {
            await _scanDir(entity, out, seen, depth: depth + 1);
          }
        }
      }
    } catch (_) {}
  }

  static String _mime(String ext) => switch (ext) {
        'pdf' => 'application/pdf',
        'epub' => 'application/epub+zip',
        'md' || 'markdown' => 'text/markdown',
        'html' || 'htm' => 'text/html',
        'jpg' || 'jpeg' => 'image/jpeg',
        'png' => 'image/png',
        'gif' => 'image/gif',
        'webp' => 'image/webp',
        'bmp' => 'image/bmp',
        'heic' || 'heif' => 'image/heic',
        'tiff' || 'tif' => 'image/tiff',
        'txt' => 'text/plain',
        'csv' => 'text/csv',
        'doc' || 'docx' => 'application/msword',
        'xls' || 'xlsx' => 'application/vnd.ms-excel',
        'ppt' || 'pptx' => 'application/vnd.ms-powerpoint',
        'json' => 'application/json',
        'xml' => 'application/xml',
        'cbz' => 'application/x-cbz',
        _ => 'application/octet-stream',
      };
}
