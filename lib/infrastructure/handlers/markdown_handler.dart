import 'dart:io';

import 'package:flutter/widgets.dart';

import '../../domain/document.dart';
import '../../presentation/readers/markdown_reader.dart';
import 'document_handler.dart';

class MarkdownHandler extends DocumentHandler {
  static const _exts = {'md', 'markdown', 'mdown', 'mkd'};

  @override
  String get id => 'markdown';

  @override
  bool canHandle(DocumentRef ref, {List<int>? headerBytes}) =>
      _exts.contains(ref.extension);

  @override
  Future<Widget> buildReader(DocumentRef ref) async => MarkdownReader(ref: ref);

  @override
  Future<Thumbnail?> generateThumbnail(DocumentRef ref) async => null;

  @override
  Future<String?> extractText(DocumentRef ref) async {
    final text = await File(ref.path).readAsString();
    return text.length > 200000 ? text.substring(0, 200000) : text;
  }
}
