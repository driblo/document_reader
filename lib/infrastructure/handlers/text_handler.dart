import 'dart:io';

import 'package:flutter/widgets.dart';

import '../../domain/document.dart';
import '../../presentation/readers/text_reader.dart';
import '../text/charset_decoder.dart';
import 'document_handler.dart';

class TextHandler extends DocumentHandler {
  static const _exts = {'txt', 'log', 'csv', 'tsv', 'ini', 'conf', 'cfg'};

  @override
  String get id => 'text';

  @override
  bool canHandle(DocumentRef ref, {List<int>? headerBytes}) =>
      _exts.contains(ref.extension);

  @override
  Future<Widget> buildReader(DocumentRef ref) async => TextReader(ref: ref);

  @override
  Future<Thumbnail?> generateThumbnail(DocumentRef ref) async => null;

  @override
  Future<String?> extractText(DocumentRef ref) async {
    final bytes = await File(ref.path).readAsBytes();
    final decoded = const CharsetDecoder().decode(bytes);
    // Trim very large files; the FTS index doesn't need the full doc.
    return decoded.text.length > 200000
        ? decoded.text.substring(0, 200000)
        : decoded.text;
  }
}
