import 'package:flutter/widgets.dart';

import '../../domain/document.dart';

/// Strategy interface — every supported format ships one implementation
/// and registers it with [HandlerRegistry]. Adding a new format means
/// creating a new class; existing handlers stay closed for modification.
abstract class DocumentHandler {
  /// Stable identifier (e.g. `pdf`, `markdown`) used in logs and
  /// preferences.
  String get id;

  /// Cheap synchronous check used to dispatch a [DocumentRef] to the
  /// right handler. Implementations should consider both file extension
  /// and, when meaningful, magic bytes (the registry passes a small
  /// header buffer when available).
  bool canHandle(DocumentRef ref, {List<int>? headerBytes});

  /// Builds the screen that renders the document. Must be safe to call
  /// repeatedly for the same ref.
  Future<Widget> buildReader(DocumentRef ref);

  /// Generates a thumbnail suitable for the recents list. May return
  /// null if the format has no meaningful preview.
  Future<Thumbnail?> generateThumbnail(DocumentRef ref);

  /// Extracts plain text for the FTS5 index. Long documents should be
  /// chunked by the caller, not here.
  Future<String?> extractText(DocumentRef ref);
}
