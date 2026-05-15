enum AnnotationKind { highlight, underline, note }

class Annotation {
  const Annotation({
    required this.id,
    required this.documentPath,
    required this.kind,
    required this.anchor,
    this.note,
    required this.createdAt,
  });

  final int id;
  final String documentPath;
  final AnnotationKind kind;

  /// Handler-specific anchor (e.g. PDF page + rect, EPUB CFI range,
  /// text byte range). Encoded as JSON by the writing handler.
  final String anchor;
  final String? note;
  final DateTime createdAt;
}
