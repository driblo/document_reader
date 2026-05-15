import '../../domain/document.dart';
import '_stub.dart';
import 'document_handler.dart';

class HtmlHandler extends DocumentHandler with HandlerStubMixin {
  static const _exts = {'html', 'htm', 'xhtml'};

  @override
  String get id => 'html';

  @override
  bool canHandle(DocumentRef ref, {List<int>? headerBytes}) =>
      _exts.contains(ref.extension);
}
