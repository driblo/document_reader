import 'package:flutter/widgets.dart';

import '../../domain/document.dart';
import '../../presentation/readers/epub_reader.dart';
import 'document_handler.dart';

class EpubHandler extends DocumentHandler {
  @override
  String get id => 'epub';

  @override
  bool canHandle(DocumentRef ref, {List<int>? headerBytes}) =>
      ref.extension == 'epub';

  @override
  Future<Widget> buildReader(DocumentRef ref) async => EpubReader(ref: ref);

  @override
  Future<Thumbnail?> generateThumbnail(DocumentRef ref) async => null;

  /// EPUB text extraction would require unpacking the archive and
  /// stripping XHTML — deferred to Phase 3.
  @override
  Future<String?> extractText(DocumentRef ref) async => null;
}
