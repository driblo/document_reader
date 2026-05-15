import 'dart:io';

import 'package:flutter/widgets.dart';

import '../core/errors/app_exception.dart';
import '../domain/document.dart';
import '../infrastructure/handlers/handler_registry.dart';
import '../infrastructure/mime/mime_detector.dart';

/// Entry point used by the UI: given a file path, figure out the right
/// handler, build its reader widget, and surface a typed error if no
/// handler claims the file.
class DocumentOpener {
  DocumentOpener({
    required HandlerRegistry registry,
    MimeDetector mimeDetector = const MimeDetector(),
  })  : _registry = registry,
        _mime = mimeDetector;

  final HandlerRegistry _registry;
  final MimeDetector _mime;

  Future<Widget> open(String path) async {
    final file = File(path);
    if (!file.existsSync()) {
      throw const FileMissingException('File no longer exists.');
    }

    final stat = await file.stat();
    final ref = DocumentRef(
      path: path,
      displayName: path.split(Platform.pathSeparator).last,
      mimeType: _mime.fromExtension(_extOf(path)),
      sizeBytes: stat.size,
      lastModified: stat.modified,
    );

    final header = await _mime.readHeader(file);
    final handler = _registry.resolve(ref, headerBytes: header);
    if (handler == null) {
      throw UnsupportedFormatException('No handler for ${ref.extension}.');
    }
    return handler.buildReader(ref);
  }

  String _extOf(String path) {
    final i = path.lastIndexOf('.');
    return i == -1 ? '' : path.substring(i + 1);
  }
}
