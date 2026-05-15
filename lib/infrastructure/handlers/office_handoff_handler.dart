import '../../domain/document.dart';
import '_stub.dart';
import 'document_handler.dart';

/// Phase 2 entry point for Office formats. Recognises the extensions
/// today so the registry doesn't fall off the end on a `.docx`; the
/// real Phase 2 work is wiring `Intent.ACTION_VIEW` (Android) and
/// `UIDocumentInteractionController` / QuickLook (iOS).
class OfficeHandoffHandler extends DocumentHandler with HandlerStubMixin {
  static const _exts = {
    'doc', 'docx', 'odt', 'rtf',
    'xls', 'xlsx', 'ods',
    'ppt', 'pptx', 'odp',
  };

  @override
  String get id => 'office_handoff';

  @override
  bool canHandle(DocumentRef ref, {List<int>? headerBytes}) =>
      _exts.contains(ref.extension);
}
