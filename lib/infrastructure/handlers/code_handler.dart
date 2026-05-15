import 'dart:io';

import 'package:flutter/widgets.dart';

import '../../domain/document.dart';
import '../../presentation/readers/code_reader.dart';
import '../text/charset_decoder.dart';
import 'document_handler.dart';

class CodeHandler extends DocumentHandler {
  static const _exts = {
    'dart', 'java', 'kt', 'kts', 'swift', 'm', 'mm',
    'c', 'h', 'cc', 'cpp', 'hpp', 'cxx',
    'cs', 'go', 'rs', 'rb', 'py', 'php', 'pl', 'lua', 'sh', 'bash', 'zsh',
    'js', 'mjs', 'cjs', 'ts', 'tsx', 'jsx',
    'json', 'yaml', 'yml', 'toml', 'xml', 'sql', 'r', 'scala', 'groovy',
  };

  @override
  String get id => 'code';

  @override
  bool canHandle(DocumentRef ref, {List<int>? headerBytes}) =>
      _exts.contains(ref.extension);

  @override
  Future<Widget> buildReader(DocumentRef ref) async => CodeReader(ref: ref);

  @override
  Future<Thumbnail?> generateThumbnail(DocumentRef ref) async => null;

  @override
  Future<String?> extractText(DocumentRef ref) async {
    final bytes = await File(ref.path).readAsBytes();
    final decoded = const CharsetDecoder().decode(bytes);
    return decoded.text.length > 200000
        ? decoded.text.substring(0, 200000)
        : decoded.text;
  }
}
