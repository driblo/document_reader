import '../../domain/document.dart';
import 'code_handler.dart';
import 'document_handler.dart';
import 'epub_handler.dart';
import 'html_handler.dart';
import 'image_handler.dart';
import 'markdown_handler.dart';
import 'office_handoff_handler.dart';
import 'pdf_handler.dart';
import 'text_handler.dart';

/// Holds the ordered list of handlers and resolves a [DocumentRef] to
/// the first one that claims it. Order matters: more specific handlers
/// (e.g. Markdown) must come before generic fallbacks (e.g. plain text).
class HandlerRegistry {
  HandlerRegistry(this._handlers);

  factory HandlerRegistry.defaults() {
    return HandlerRegistry(<DocumentHandler>[
      PdfHandler(),
      EpubHandler(),
      MarkdownHandler(),
      HtmlHandler(),
      CodeHandler(),
      ImageHandler(),
      TextHandler(),
      OfficeHandoffHandler(), // last-resort handoff for unknown office docs
    ]);
  }

  final List<DocumentHandler> _handlers;

  DocumentHandler? resolve(DocumentRef ref, {List<int>? headerBytes}) {
    for (final handler in _handlers) {
      if (handler.canHandle(ref, headerBytes: headerBytes)) return handler;
    }
    return null;
  }

  Iterable<DocumentHandler> get all => _handlers;
}
