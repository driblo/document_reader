import 'dart:io';

import 'package:flutter/widgets.dart';

import '../../domain/document.dart';
import '../../presentation/readers/html_reader.dart';
import 'document_handler.dart';

class HtmlHandler extends DocumentHandler {
  static const _exts = {'html', 'htm', 'xhtml'};

  @override
  String get id => 'html';

  @override
  bool canHandle(DocumentRef ref, {List<int>? headerBytes}) =>
      _exts.contains(ref.extension);

  @override
  Future<Widget> buildReader(DocumentRef ref) async => HtmlReader(ref: ref);

  @override
  Future<Thumbnail?> generateThumbnail(DocumentRef ref) async => null;

  @override
  Future<String?> extractText(DocumentRef ref) async {
    final raw = await File(ref.path).readAsString();
    // Strip tags cheaply for indexing — full DOM parsing is overkill
    // for the FTS5 use case.
    final stripped = raw.replaceAll(RegExp(r'<[^>]+>'), ' ');
    final collapsed = stripped.replaceAll(RegExp(r'\s+'), ' ').trim();
    return collapsed.length > 200000
        ? collapsed.substring(0, 200000)
        : collapsed;
  }
}
