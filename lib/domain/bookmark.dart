class Bookmark {
  const Bookmark({
    required this.id,
    required this.documentPath,
    required this.label,
    required this.position,
    required this.createdAt,
  });

  final int id;
  final String documentPath;
  final String label;

  /// Format-agnostic position. PDF: page number. EPUB: CFI string.
  /// Text/Markdown: byte offset. Stored as a string so each handler can
  /// encode whatever it needs.
  final String position;

  final DateTime createdAt;
}
