import '../../domain/document.dart';
import '_stub.dart';
import 'document_handler.dart';

class MarkdownHandler extends DocumentHandler with HandlerStubMixin {
  static const _exts = {'md', 'markdown', 'mdown', 'mkd'};

  @override
  String get id => 'markdown';

  @override
  bool canHandle(DocumentRef ref, {List<int>? headerBytes}) =>
      _exts.contains(ref.extension);
}
