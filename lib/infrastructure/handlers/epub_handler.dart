import '../../domain/document.dart';
import '_stub.dart';
import 'document_handler.dart';

class EpubHandler extends DocumentHandler with HandlerStubMixin {
  @override
  String get id => 'epub';

  @override
  bool canHandle(DocumentRef ref, {List<int>? headerBytes}) =>
      ref.extension == 'epub';
}
