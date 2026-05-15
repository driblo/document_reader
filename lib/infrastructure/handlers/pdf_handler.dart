import '../../domain/document.dart';
import '_stub.dart';
import 'document_handler.dart';

class PdfHandler extends DocumentHandler with HandlerStubMixin {
  @override
  String get id => 'pdf';

  @override
  bool canHandle(DocumentRef ref, {List<int>? headerBytes}) {
    if (ref.extension == 'pdf') return true;
    if (headerBytes != null && headerBytes.length >= 4) {
      // %PDF
      return headerBytes[0] == 0x25 &&
          headerBytes[1] == 0x50 &&
          headerBytes[2] == 0x44 &&
          headerBytes[3] == 0x46;
    }
    return false;
  }
}
