import '../../domain/document.dart';
import '_stub.dart';
import 'document_handler.dart';

class TextHandler extends DocumentHandler with HandlerStubMixin {
  static const _exts = {'txt', 'log', 'csv', 'tsv', 'ini', 'conf', 'cfg'};

  @override
  String get id => 'text';

  @override
  bool canHandle(DocumentRef ref, {List<int>? headerBytes}) =>
      _exts.contains(ref.extension);
}
