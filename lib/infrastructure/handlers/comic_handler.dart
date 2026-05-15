import 'package:flutter/widgets.dart';

import '../../domain/document.dart';
import '../../presentation/readers/comic_reader.dart';
import 'document_handler.dart';

/// Phase 3 — only CBZ (zip) is supported. CBR (rar) is intentionally
/// skipped because RAR needs a proprietary native dependency.
class ComicHandler extends DocumentHandler {
  @override
  String get id => 'comic';

  @override
  bool canHandle(DocumentRef ref, {List<int>? headerBytes}) =>
      ref.extension == 'cbz';

  @override
  Future<Widget> buildReader(DocumentRef ref) async => ComicReader(ref: ref);

  @override
  Future<Thumbnail?> generateThumbnail(DocumentRef ref) async => null;

  @override
  Future<String?> extractText(DocumentRef ref) async => null;
}
