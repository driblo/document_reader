import 'dart:io';

import 'package:flutter/widgets.dart';

import '../core/errors/app_exception.dart';
import '../domain/document.dart';
import '../infrastructure/handlers/document_handler.dart';
import '../infrastructure/handlers/handler_registry.dart';
import '../infrastructure/mime/mime_detector.dart';

class OpenedDocument {
  const OpenedDocument({
    required this.ref,
    required this.handler,
    required this.reader,
  });
  final DocumentRef ref;
  final DocumentHandler handler;
  final Widget reader;
}

class DocumentOpener {
  DocumentOpener({
    required HandlerRegistry registry,
    MimeDetector mimeDetector = const MimeDetector(),
  })  : _registry = registry,
        _mime = mimeDetector;

  final HandlerRegistry _registry;
  final MimeDetector _mime;

  Future<OpenedDocument> open(String path) async {
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
    final widget = await handler.buildReader(ref);
    return OpenedDocument(ref: ref, handler: handler, reader: widget);
  }

  String _extOf(String path) {
    final i = path.lastIndexOf('.');
    return i == -1 ? '' : path.substring(i + 1);
  }
}
