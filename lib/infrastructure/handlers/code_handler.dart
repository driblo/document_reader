import '../../domain/document.dart';
import '_stub.dart';
import 'document_handler.dart';

class CodeHandler extends DocumentHandler with HandlerStubMixin {
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
}
